//
//  String+Emoji.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/2.
//

import Foundation

extension String {
    
    /// 字符串是否是一个 emoji 字符
    func isEmojiCharacter() -> Bool {
        if self.count == 1, let scalar = self.unicodeScalars.first, scalar.properties.isEmoji {
            return true
        }
        
        return false
    }
    
    /// 生成一个随机的 emoji 字符串
    static func randomEmoji() -> String {
        let emoji = Character.randomEmoji()
        return String(emoji)
    }
}
