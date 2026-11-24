//
//  String+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/23.
//

import Foundation

extension String {
    
    /// 是否包含换行符
    var containsNewlineCharacter: Bool {
        if self.range(of: "\n") != nil {
            return true
        }
        
        return false
    }
    
    /// 是否为换行符
    var isNewlineCharacter: Bool {
        return self == "\n"
    }

    /// 换行符替换为空白
    var newlineReplacedWithWhiteSpaceString: String {
        return self.replacingOccurrences(of: "\n", with: " ")
    }
    
    /// 是否是整型字符串
    var isIntValue: Bool {
        return Int(self) != nil
    }
    
    /// 清除两端的空白和新行
    var whitespacesAndNewlinesTrimmedString: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// 字符串首字母大写
    func capitalizedFirstLetter() -> String {
        guard let firstChar = self.first else {
            return self
        }
    
        return String(firstChar).uppercased() + self.dropFirst()
    }
    
    /// 从字符串中截取前缀之后的字符串
    func substring(after prefix: String) -> String? {
        guard let range = self.range(of: prefix) else { return nil }
        // 确保前缀是从开头开始的
        guard range.lowerBound == self.startIndex else { return nil }
        let afterIndex = range.upperBound
        return String(self[afterIndex...])
    }
    
    /// 将字符串的首字母转换为小写
    func lowercasingFirst() -> String {
        guard let first = self.first else { return self }
        return first.lowercased() + self.dropFirst()
    }
}
