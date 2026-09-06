import Foundation

public actor EvaluationScraper {
    public static let shared = EvaluationScraper()

    private let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36"
    private let session: URLSession

    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 25
        config.timeoutIntervalForResource = 35
        self.session = URLSession(configuration: config)
    }

    public func fetchEvaluationLinks(evalURL: String) async throws -> [ResolvedDownloadOption] {
        guard let url = URL(string: evalURL) else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        req.setValue("text/html,application/xhtml+xml", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
              let html = String(data: data, encoding: .utf8) else {
            throw URLError(.badServerResponse)
        }

        let fwlinks = extractFwlinks(from: html)
        if fwlinks.isEmpty {
            throw NSError(
                domain: "EvaluationScraper",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No fwlinks found on evaluation page"]
            )
        }

        var options: [ResolvedDownloadOption] = []
        for fw in fwlinks {
            if let directURL = await resolveDirectISO(fwlink: fw) {
                let arch = WindowsArchitecture.from(string: directURL)
                let opt = ResolvedDownloadOption(
                    uri: directURL,
                    architecture: arch,
                    expiresAt: nil,
                    isCached: false
                )
                if !options.contains(where: { $0.uri == opt.uri }) {
                    options.append(opt)
                }
            }
        }

        if options.isEmpty {
            throw NSError(
                domain: "EvaluationScraper",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Could not resolve direct ISO download links for evaluation product"]
            )
        }

        return options
    }

    private func extractFwlinks(from html: String) -> [String] {
        let pattern = "https://go\\.microsoft\\.com/fwlink/[^\"'\\s<>]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsString = html as NSString
        let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsString.length))

        var seen = Set<String>()
        var results: [String] = []

        for match in matches {
            let link = nsString.substring(with: match.range)
            if !seen.contains(link) {
                seen.insert(link)
                results.append(link)
            }
        }

        return results
    }

    private func resolveDirectISO(fwlink: String) async -> String? {
        guard let url = URL(string: fwlink) else { return nil }
        var req = URLRequest(url: url)
        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        req.httpMethod = "HEAD"

        if let (_, response) = try? await session.data(for: req),
           let finalURL = response.url?.absoluteString,
           finalURL.lowercased().contains(".iso") {
            return finalURL
        }

        return nil
    }
}
