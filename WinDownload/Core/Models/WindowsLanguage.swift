import Foundation

public struct WindowsLanguage: Identifiable, Hashable, Codable {
    public let id: String
    public let englishName: String
    public let localizedName: String

    public init(id: String, englishName: String, localizedName: String? = nil) {
        self.id = id
        self.englishName = englishName
        self.localizedName = localizedName ?? englishName
    }

    public var displayName: String {
        if localizedName.isEmpty || localizedName == englishName {
            return englishName
        }
        return "\(englishName) (\(localizedName))"
    }

    public static let fallbackEnglish = WindowsLanguage(
        id: "19672",
        englishName: "English",
        localizedName: "English"
    )

    public static let defaultList: [WindowsLanguage] = [
        WindowsLanguage(id: "19672", englishName: "English", localizedName: "English"),
        WindowsLanguage(id: "19673", englishName: "English International", localizedName: "English International"),
        WindowsLanguage(id: "19688", englishName: "Polish", localizedName: "Polski"),
        WindowsLanguage(id: "19676", englishName: "German", localizedName: "Deutsch"),
        WindowsLanguage(id: "19674", englishName: "French", localizedName: "Français"),
        WindowsLanguage(id: "19693", englishName: "Spanish", localizedName: "Español"),
        WindowsLanguage(id: "19680", englishName: "Italian", localizedName: "Italiano"),
        WindowsLanguage(id: "19665", englishName: "Brazilian Portuguese", localizedName: "Português (Brasil)"),
        WindowsLanguage(id: "19689", englishName: "Portuguese", localizedName: "Português (Portugal)"),
        WindowsLanguage(id: "19681", englishName: "Japanese", localizedName: "日本語"),
        WindowsLanguage(id: "19682", englishName: "Korean", localizedName: "한국어"),
        WindowsLanguage(id: "19668", englishName: "Chinese (Simplified)", localizedName: "简体中文"),
        WindowsLanguage(id: "19669", englishName: "Chinese (Traditional)", localizedName: "繁體中文"),
        WindowsLanguage(id: "19690", englishName: "Russian", localizedName: "Русский"),
        WindowsLanguage(id: "19697", englishName: "Ukrainian", localizedName: "Українська"),
        WindowsLanguage(id: "19695", englishName: "Turkish", localizedName: "Türkçe"),
        WindowsLanguage(id: "19664", englishName: "Arabic", localizedName: "العربية"),
        WindowsLanguage(id: "19670", englishName: "Czech", localizedName: "Čeština"),
        WindowsLanguage(id: "19671", englishName: "Danish", localizedName: "Dansk"),
        WindowsLanguage(id: "19675", englishName: "Finnish", localizedName: "Suomi"),
        WindowsLanguage(id: "19677", englishName: "Greek", localizedName: "Ελληνικά"),
        WindowsLanguage(id: "19678", englishName: "Hebrew", localizedName: "עברית"),
        WindowsLanguage(id: "19679", englishName: "Hungarian", localizedName: "Magyar"),
        WindowsLanguage(id: "19683", englishName: "Norwegian", localizedName: "Norsk"),
        WindowsLanguage(id: "19684", englishName: "Dutch", localizedName: "Nederlands"),
        WindowsLanguage(id: "19691", englishName: "Slovak", localizedName: "Slovenčina"),
        WindowsLanguage(id: "19692", englishName: "Slovenian", localizedName: "Slovenščina"),
        WindowsLanguage(id: "19694", englishName: "Swedish", localizedName: "Svenska"),
        WindowsLanguage(id: "19696", englishName: "Thai", localizedName: "ไทย")
    ]
}
