import Foundation

public actor MSDLAPIClient {
    public static let shared = MSDLAPIClient()

    private let baseURL = "https://api.msdl.tech-latest.com"
    private let session: URLSession

    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 25
        self.session = URLSession(configuration: config)
    }

    public func fetchLanguages(productID: String) async throws -> [WindowsLanguage] {
        guard let url = URL(string: "\(baseURL)/skuinfo?product_id=\(productID)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        struct SkuResponse: Decodable {
            struct Sku: Decodable {
                let Id: String
                let Language: String
                let LocalizedLanguage: String?
            }
            let Skus: [Sku]?
            let error: String?
        }

        let decoded = try JSONDecoder().decode(SkuResponse.self, from: data)
        if let err = decoded.error {
            throw NSError(domain: "MSDLAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: err])
        }

        guard let skus = decoded.Skus, !skus.isEmpty else {
            throw NSError(domain: "MSDLAPI", code: 2, userInfo: [NSLocalizedDescriptionKey: "No languages in MSDL response"])
        }

        return skus.map {
            WindowsLanguage(
                id: $0.Id,
                englishName: $0.Language,
                localizedName: $0.LocalizedLanguage ?? $0.Language
            )
        }
    }

    public func fetchDownloadLinks(productID: String, skuID: String) async throws -> [ResolvedDownloadOption] {
        guard let url = URL(string: "\(baseURL)/proxy?product_id=\(productID)&sku_id=\(skuID)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        struct ProxyResponse: Decodable {
            struct Option: Decodable {
                let Uri: String
                let Architecture: String?
                let DownloadType: Int?
            }
            let ProductDownloadOptions: [Option]?
            let error: String?
        }

        let decoded = try JSONDecoder().decode(ProxyResponse.self, from: data)
        if let err = decoded.error {
            throw NSError(domain: "MSDLAPI", code: 3, userInfo: [NSLocalizedDescriptionKey: err])
        }

        guard let options = decoded.ProductDownloadOptions, !options.isEmpty else {
            throw NSError(domain: "MSDLAPI", code: 4, userInfo: [NSLocalizedDescriptionKey: "No links returned from MSDL proxy"])
        }

        return options.map { opt in
            var arch = WindowsArchitecture.from(string: opt.Architecture ?? "")
            if arch == .x64, let dt = opt.DownloadType {
                if dt == 0 { arch = .x86 }
                else if dt == 2 { arch = .arm64 }
            }
            return ResolvedDownloadOption(
                uri: opt.Uri,
                architecture: arch,
                expiresAt: Date().addingTimeInterval(86400),
                isCached: true
            )
        }
    }
}
