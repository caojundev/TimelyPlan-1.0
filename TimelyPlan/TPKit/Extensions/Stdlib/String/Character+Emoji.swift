//
//  Character+Emoji.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/18.
//

import Foundation

extension Character {
    
    /// 生成一个随机的 emoji 字符
    static func randomEmoji() -> Character {
        let emojiStartRange: UInt32 = 0x1F600
        let emojiEndRange: UInt32 = 0x1F64F
        let scalarValue = Unicode.Scalar(Int.random(in: Int(emojiStartRange)...Int(emojiEndRange)))!
        let emojiCharacter = Character(scalarValue)
        return emojiCharacter
    }
    
    /// 获取字符对应的字符串
    var stringValue: String? {
        return String(self)
    }
}
