//
//  String+ASAttributed.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/24.
//

import Foundation
import UIKit

extension Array where Element == String {
    
    /// 将普通文本数组转换成富文本数组
    var attributedStrings: [ASAttributedString] {
        return self.map{ return $0.attributedString }
    }
}

extension String {
    
    func attributedString(textColor: UIColor) -> ASAttributedString {
        return ASAttributedString(string: self, with: [.foreground(textColor)])
    }
    
    var attributedString: ASAttributedString {
        return ASAttributedString(string: self)
    }
    
    func byAppend(badge: String) -> ASAttributedString {
        return byAppend(badge: badge, color: .secondaryLabel)
    }
    
    func byAppend(badge: String, color: UIColor) -> ASAttributedString {
        let string = ASAttributedString(string: self)
        return string.byAppend(badge: badge, color: color)
    }
    
    func byAppend(badge: String,
                  baselineOffset: CGFloat,
                  font: UIFont,
                  color: UIColor = .white) -> ASAttributedString {
        let string = ASAttributedString(string: self)
        return string.byAppend(badge: badge,
                               baselineOffset: baselineOffset,
                               font: font,
                               color: color)
    }
    
    
}
