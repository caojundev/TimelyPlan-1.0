//
//  AppSettingUtil.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/24.
//

import Foundation

class AppSettingUtil {
    
    /// 打开设置页
    static func openSettings() {
        if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettingsURL) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: - 语言
    /// App 当前实际使用的语言标识符（BCP-47，如 "zh-Hans"、"en"、"ja"）
    static var currentLanguage: String {
        Bundle.main.preferredLocalizations.first ?? "en"
    }
    
    /// App 当前语言的显示名称（本地化后的，如 "简体中文"、"English"）
    static var currentLanguageDisplayName: String {
        let lang = currentLanguage
        return Locale.current.localizedString(forIdentifier: lang) ?? lang
    }
    
    /// App 支持的所有语言列表
    static var supportedLanguages: [String] {
        Bundle.main.localizations
    }
}
