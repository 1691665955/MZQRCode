//
//  Localized.swift
//  MZAuthorization
//
//  Created by macmini_zl on 2023/7/18.
//

import Foundation

extension String {
    
    func localized(
        _ language: Language = .current,
        value: String? = nil,
        table: String = "Localizable"
    ) -> String {
        guard let path = Bundle.authorizeBundle?.path(forResource: language.rawValue, ofType: "lproj") else {
            return self
        }
        return Bundle(path: path)?.localizedString(forKey: self, value: value, table: table) ?? self
    }
}

enum Language: String {
    case en
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case ja
    
    public static var current: Language = {
        guard let language = Locale.preferredLanguages.first else { return .en }
        
        if language.contains("ja") { return .ja }
        
        if language.contains("zh-HK") { return .zhHant }
        
        if language.contains("zh-Hant") { return .zhHant }
        
        if language.contains("zh-Hans") { return .zhHans }
        
        return Language(rawValue: language) ?? .en
    }()
}

extension Bundle {
    static let authorizeBundle: Bundle? = {
        let containnerBundle = Bundle(for: MZAuthorizationTool.self)
        return Bundle(path: containnerBundle.path(forResource: "MZAuthorization", ofType: "bundle")!) ?? .main
    }()
}
