//
//  Language.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/13.
//

import Foundation

class Language {
    
    /// 判断系统语言是否为中文环境
    static var isChinese: Bool {
        return hasPrefix("zh")
    }
    
    /// 判断系统语言是否为英文环境
    static var isEnglish: Bool {
        return hasPrefix("en")
    }

    private static func hasPrefix(_ prefix: String) -> Bool {
        if let preferredLanguage = NSLocale.preferredLanguages.first {
            return preferredLanguage.hasPrefix(prefix)
        }
        
        return false
    }
}
