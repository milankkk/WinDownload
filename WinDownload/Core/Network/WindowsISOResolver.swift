import Foundation

public actor WindowsISOResolver {
    public static let shared = WindowsISOResolver()

    private var activeSessionID: String?

    public init() {}

    public func resolveLanguages(for product: WindowsProduct) async throws -> [WindowsLanguage] {
        if product.isEvaluation {
            // Evaluation ISOs are multilingual or have bundled language
            return [
                WindowsLanguage(id: "eval-en", englishName: "English (US)", localizedName: "English (US)"),
                WindowsLanguage(id: "eval-intl", englishName: "Multilingual", localizedName: "Multilingual")
            ]
        }

        // Try direct Microsoft session first
        do {
            let sessionID = await MicrosoftSessionClient.shared.initializeSession()
            self.activeSessionID = sessionID
            let langs = try await MicrosoftSessionClient.shared.fetchLanguages(
                productID: product.id,
                sessionID: sessionID
            )
            if !langs.isEmpty {
                return langs
            }
        } catch {
            // Fallback to MSDL API cache
            if let msdlLanguages = try? await MSDLAPIClient.shared.fetchLanguages(productID: product.id) {
                return msdlLanguages
            }
            throw error
        }

        return WindowsLanguage.defaultList
    }

    public func resolveDownloadLink(
        for product: WindowsProduct,
        language: WindowsLanguage,
        architecture: WindowsArchitecture
    ) async throws -> ResolvedDownloadOption {
        if product.isEvaluation, let evalURL = product.evalURL {
            let evalOptions = try await EvaluationScraper.shared.fetchEvaluationLinks(evalURL: evalURL)
            if let matched = evalOptions.first(where: { $0.architecture == architecture }) {
                return matched
            }
            if let first = evalOptions.first {
                return first
            }
            throw NSError(
                domain: "WindowsISOResolver",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No evaluation link found for \(architecture.rawValue)"]
            )
        }

        // Try direct Microsoft API
        let sessionID = activeSessionID ?? (await MicrosoftSessionClient.shared.initializeSession())
        do {
            let options = try await MicrosoftSessionClient.shared.fetchDownloadLinks(
                productID: product.id,
                skuID: language.id,
                sessionID: sessionID
            )

            if let matched = options.first(where: { $0.architecture == architecture }) {
                return matched
            }
            if let first = options.first {
                return first
            }
        } catch {
            // Fallback to MSDL API
            let msdlOptions = try await MSDLAPIClient.shared.fetchDownloadLinks(
                productID: product.id,
                skuID: language.id
            )
            if let matched = msdlOptions.first(where: { $0.architecture == architecture }) {
                return matched
            }
            if let first = msdlOptions.first {
                return first
            }
            throw error
        }

        throw NSError(
            domain: "WindowsISOResolver",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Could not resolve download link for \(product.name)"]
        )
    }
}
