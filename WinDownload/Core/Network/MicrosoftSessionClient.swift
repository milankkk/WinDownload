import Foundation

public actor MicrosoftSessionClient {
    public static let shared = MicrosoftSessionClient()

    private let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36"
    private let profile = "606624d44113"
    private let locale = "en-US"
    private let orgID = "y6jn8c31"
    private let customerID = "560dc9f3-1aa5-4a2f-b63c-9e18f8d0e175"

    private let session: URLSession

    public init() {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    private func referer(for productID: String) -> String {
        guard let id = Int(productID) else {
            return "https://www.microsoft.com/en-us/software-download/windows8ISO"
        }
        if id >= 2935 {
            return "https://www.microsoft.com/en-us/software-download/windows11"
        } else if id >= 2618 {
            return "https://www.microsoft.com/en-us/software-download/windows10ISO"
        }
        return "https://www.microsoft.com/en-us/software-download/windows8ISO"
    }

    public func initializeSession() async -> String {
        let sessionID = UUID().uuidString.lowercased()

        // Step 1: tags
        if var tagsURL = URLComponents(string: "https://vlscppe.microsoft.com/tags") {
            tagsURL.queryItems = [
                URLQueryItem(name: "org_id", value: orgID),
                URLQueryItem(name: "session_id", value: sessionID)
            ]
            if let url = tagsURL.url {
                var req = URLRequest(url: url)
                req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                _ = try? await session.data(for: req)
            }
        }

        // Step 2: mdt.js
        if var mdtURL = URLComponents(string: "https://ov-df.microsoft.com/mdt.js") {
            mdtURL.queryItems = [
                URLQueryItem(name: "instanceId", value: customerID),
                URLQueryItem(name: "PageId", value: "si"),
                URLQueryItem(name: "session_id", value: sessionID)
            ]
            if let url = mdtURL.url {
                var req = URLRequest(url: url)
                req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                if let (data, _) = try? await session.data(for: req),
                   let body = String(data: data, encoding: .utf8) {
                    // Extract tokens w and rticks if present
                    let wToken = extractPattern(pattern: "[&?]w=([^&\"'\\s]+)", from: body)
                    let rticks = extractPattern(pattern: "rticks[=\"]+\\+?\\s*(\\d{10,})", from: body)
                    if let w = wToken, let rt = rticks,
                       var pingURL = URLComponents(string: "https://ov-df.microsoft.com/") {
                        pingURL.queryItems = [
                            URLQueryItem(name: "session_id", value: sessionID),
                            URLQueryItem(name: "CustomerId", value: customerID),
                            URLQueryItem(name: "PageId", value: "si"),
                            URLQueryItem(name: "w", value: w),
                            URLQueryItem(name: "mdt", value: String(Int64(Date().timeIntervalSince1970 * 1000))),
                            URLQueryItem(name: "rticks", value: rt)
                        ]
                        if let pURL = pingURL.url {
                            var pReq = URLRequest(url: pURL)
                            pReq.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                            _ = try? await session.data(for: pReq)
                        }
                    }
                }
            }
        }

        return sessionID
    }

    public func fetchLanguages(productID: String, sessionID: String) async throws -> [WindowsLanguage] {
        guard var components = URLComponents(string: "https://www.microsoft.com/software-download-connector/api/getskuinformationbyproductedition") else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "profile", value: profile),
            URLQueryItem(name: "productEditionId", value: productID),
            URLQueryItem(name: "SKU", value: "undefined"),
            URLQueryItem(name: "friendlyFileName", value: "undefined"),
            URLQueryItem(name: "Locale", value: locale),
            URLQueryItem(name: "sessionID", value: sessionID)
        ]

        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(referer(for: productID), forHTTPHeaderField: "Referer")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try parseLanguagesResponse(data: data)
    }

    public func fetchDownloadLinks(
        productID: String,
        skuID: String,
        sessionID: String
    ) async throws -> [ResolvedDownloadOption] {
        guard var components = URLComponents(string: "https://www.microsoft.com/software-download-connector/api/GetProductDownloadLinksBySku") else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "profile", value: profile),
            URLQueryItem(name: "productEditionId", value: "undefined"),
            URLQueryItem(name: "SKU", value: skuID),
            URLQueryItem(name: "friendlyFileName", value: "undefined"),
            URLQueryItem(name: "Locale", value: locale),
            URLQueryItem(name: "sessionID", value: sessionID)
        ]

        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(referer(for: productID), forHTTPHeaderField: "Referer")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try parseDownloadLinksResponse(data: data)
    }

    private func parseLanguagesResponse(data: Data) throws -> [WindowsLanguage] {
        struct SKUResponse: Decodable {
            struct SKUItem: Decodable {
                let Id: String
                let Language: String
                let LocalizedLanguage: String?
            }
            struct MSError: Decodable {
                let Type: Double?
                let Value: String?
            }
            let Skus: [SKUItem]?
            let Errors: [MSError]?
        }

        let raw = unwrapJSONStringIfNeeded(data)
        let decoder = JSONDecoder()
        let result = try decoder.decode(SKUResponse.self, from: raw)

        if let errors = result.Errors, !errors.isEmpty, let msg = errors.first?.Value, !msg.isEmpty {
            throw NSError(domain: "MicrosoftAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        guard let skus = result.Skus, !skus.isEmpty else {
            throw NSError(domain: "MicrosoftAPI", code: 2, userInfo: [NSLocalizedDescriptionKey: "No languages returned for product"])
        }

        return skus.map {
            WindowsLanguage(
                id: $0.Id,
                englishName: $0.Language,
                localizedName: $0.LocalizedLanguage ?? $0.Language
            )
        }
    }

    private func parseDownloadLinksResponse(data: Data) throws -> [ResolvedDownloadOption] {
        struct DownloadOptionResponse: Decodable {
            struct OptionItem: Decodable {
                let Uri: String
                let Architecture: String?
                let DownloadType: Int?
            }
            struct MSError: Decodable {
                let Type: Double?
                let Value: String?
            }
            let ProductDownloadOptions: [OptionItem]?
            let Errors: [MSError]?
        }

        let raw = unwrapJSONStringIfNeeded(data)
        let decoder = JSONDecoder()
        let result = try decoder.decode(DownloadOptionResponse.self, from: raw)

        if let errors = result.Errors, !errors.isEmpty, let msg = errors.first?.Value, !msg.isEmpty {
            throw NSError(domain: "MicrosoftAPI", code: 3, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        guard let options = result.ProductDownloadOptions, !options.isEmpty else {
            throw NSError(domain: "MicrosoftAPI", code: 4, userInfo: [NSLocalizedDescriptionKey: "No download links returned for this language"])
        }

        return options.map { opt in
            var arch = WindowsArchitecture.from(string: opt.Architecture ?? "")
            if arch == .x64, let dt = opt.DownloadType {
                if dt == 0 { arch = .x86 }
                else if dt == 2 { arch = .arm64 }
            }
            let expiry = parseExpiry(from: opt.Uri)
            return ResolvedDownloadOption(
                uri: opt.Uri,
                architecture: arch,
                expiresAt: expiry,
                isCached: false
            )
        }
    }

    private func parseExpiry(from uri: String) -> Date? {
        guard let comps = URLComponents(string: uri),
              let seValue = comps.queryItems?.first(where: { $0.name == "se" })?.value else {
            return Date().addingTimeInterval(86400) // Default Microsoft 24h
        }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: seValue) ?? Date().addingTimeInterval(86400)
    }

    private func unwrapJSONStringIfNeeded(_ data: Data) -> Data {
        guard let str = String(data: data, encoding: .utf8), str.hasPrefix("\""), str.hasSuffix("\"") else {
            return data
        }
        if let unescaped = try? JSONDecoder().decode(String.self, from: data),
           let innerData = unescaped.data(using: .utf8) {
            return innerData
        }
        return data
    }

    private func extractPattern(pattern: String, from text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsString = text as NSString
        guard let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsString.length)),
              match.numberOfRanges > 1 else { return nil }
        return nsString.substring(with: match.range(at: 1))
    }
}
