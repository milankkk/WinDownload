import Foundation

public actor WindowsISOResolver {
    public static let shared = WindowsISOResolver()

    private var activeSessionID: String?

    public init() {}

    /// Resolves available languages for a product, falling back to MSDL API cache if direct Microsoft session fails.
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

    /// Resolves the official ISO download link from Microsoft direct CDN or evaluation mirrors.
    public func resolveDownloadLink(
        for product: WindowsProduct,
        language: WindowsLanguage,
        architecture: WindowsArchitecture
    ) async throws -> ResolvedDownloadOption {
        // 1. Check for direct ISO URL or evaluation link
        if product.isEvaluation {
            if let direct = product.directISOURL, !direct.isEmpty {
                return ResolvedDownloadOption(
                    uri: direct,
                    architecture: architecture,
                    expiresAt: nil,
                    isCached: false
                )
            }
            if let evalURL = product.evalURL {
                let evalOptions = try await EvaluationScraper.shared.fetchEvaluationLinks(evalURL: evalURL)
                if let matched = evalOptions.first(where: { $0.architecture == architecture }) {
                    return matched
                }
                if let first = evalOptions.first {
                    return first
                }
            }
            throw NSError(
                domain: "WindowsISOResolver",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No evaluation link found for \(architecture.rawValue)"]
            )
        }

        // 2. Resolve architecture-specific product variant (e.g. 3113 -> 3131 for ARM64)
        let effectiveProduct = WindowsCatalog.shared.resolveProduct(for: product, architecture: architecture)

        // 3. Ensure valid SKU ID for the effective product
        var targetSKU = language.id
        if targetSKU.isEmpty || targetSKU.hasPrefix("eval-") {
            let langs = try await resolveLanguages(for: effectiveProduct)
            if let match = langs.first(where: { $0.englishName.localizedCaseInsensitiveCompare(language.englishName) == .orderedSame }) {
                targetSKU = match.id
            } else if let match = langs.first(where: { $0.englishName.localizedCaseInsensitiveContains("English") && !$0.englishName.localizedCaseInsensitiveContains("International") }) {
                targetSKU = match.id
            } else if let first = langs.first {
                targetSKU = first.id
            }
        }

        // 4. Try direct Microsoft API first
        let sessionID: String
        if let activeSessionID {
            sessionID = activeSessionID
        } else {
            sessionID = await MicrosoftSessionClient.shared.initializeSession()
        }

        do {
            let options = try await MicrosoftSessionClient.shared.fetchDownloadLinks(
                productID: effectiveProduct.id,
                skuID: targetSKU,
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
                productID: effectiveProduct.id,
                skuID: targetSKU
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
