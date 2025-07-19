//
//  LanguageModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 19.07.2025.
//

import Foundation
import Combine

enum Language: String, CaseIterable, Identifiable {
    case ru
    case en

    var id: String { rawValue }
    var displayName: String {
            switch self {
            case .ru: return "EN"
            case .en: return "RU"
            }
        }
    var localeIdentifier: String {
        switch self {
        case .ru: return "ru"
        case .en: return "en"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "appLanguage"), let lang = Language(rawValue: saved) {
            currentLanguage = lang
        } else {
            currentLanguage = .ru // default
        }
    }

    func setLanguage(_ lang: Language) {
        currentLanguage = lang
    }
}

extension Bundle {
    private static var bundleKey: UInt8 = 0

    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            object_setClass(Bundle.main, Bundle.self)
            return
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    static var localized: Bundle {
        if let bundle = objc_getAssociatedObject(Bundle.main, &bundleKey) as? Bundle {
            return bundle
        }
        return Bundle.main
    }
}

func LocalizedString(_ key: String, comment: String = "") -> String {
    return Bundle.localized.localizedString(forKey: key, value: nil, table: nil)
}
