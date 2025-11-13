import Foundation

public enum LanguageSpecifier: String, LanguageSpecifying {
    case english
    case dutch
    case hebrew
    case german
    case italian
    case japanese

    public static let table: [LanguageSpecifier: LanguageData] = [
        .english  :  LanguageData(abbreviation: "en", locales: ["en_US", "en_GB"]),
        .dutch    :  LanguageData(abbreviation: "nl", locales: ["nl_NL", "nl_BE"]),
        .hebrew   :  LanguageData(abbreviation: "he", locales: ["he_IL"]),
        .german   :  LanguageData(abbreviation: "de", locales: ["de_DE", "de_AT", "de_CH"]),
        .italian  :  LanguageData(abbreviation: "it", locales: ["it_IT", "it_CH"]),
        .japanese :  LanguageData(abbreviation: "ja", locales: ["ja_JP"]),
    ]
}

// extension LanguageSpecifier: PreparableContent {}
