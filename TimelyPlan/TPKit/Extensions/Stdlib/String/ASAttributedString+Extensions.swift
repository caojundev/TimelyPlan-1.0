//
//  ASAttributedString+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/19.
//

import Foundation
import UIKit

extension ASAttributedString {
    
    /// 高亮文本
    static func string(with string: String, textColor: UIColor = .primary) -> ASAttributedString {
        let color: ASAttributedString.Attribute = .foreground(textColor)
        let string: ASAttributedString = "\(string, color)"
        return string
    }
    
    static func string(format: String,
                       stringParameters: [String],
                       highlightedColor: UIColor = .primary) -> ASAttributedString {
    
        var attributedParameters = [ASAttributedString]()
        for stringParameter in stringParameters {
            let attributedParameter = ASAttributedString.string(with: stringParameter,
                                                                textColor: .primary)
            attributedParameters.append(attributedParameter)
        }
        
        return .string(format: format, attributedParameters: attributedParameters)
    }
    
    static func string(format: String, attributedParameters: [ASAttributedString]) -> ASAttributedString {
        let components = format.components(separatedBy: "%@")
        guard components.count > 1 else {
            return format.attributedString
        }
        
        var attributedString: ASAttributedString = ""
        for (index, string) in components.enumerated() {
            attributedString += string
            if index < attributedParameters.count {
                attributedString += attributedParameters[index]
            }
        }
        
        return attributedString
    }
    
    /// 创建图标以及尾随文本的富文本
    static func string(image: UIImage,
                       imageSize: CGSize? = nil,
                       imageColor: UIColor? = nil,
                       trailingText: String? = nil,
                       separator: String? = nil) -> ASAttributedString {
        var image = image
        if let imageColor = imageColor {
            image = image.withTintColor(imageColor)
        }
        
        let imageSize = imageSize ?? image.size
        let imageString: ASAttributedString = "\(.image(image, .custom(.center, size: imageSize)))"
        var strings = [imageString]
        if let trailingText = trailingText {
            strings.append("\(trailingText)")
        }
        
        let separator = separator ?? ""
        return strings.joined(separator: separator)
    }
}

extension ASAttributedString {
    
    func byAppend(badge: String) -> ASAttributedString {
        return byAppend(badge: badge,
                        baselineOffset: 5.0,
                        font: UIFont.boldSystemFont(ofSize: 6.0),
                        color: .secondaryLabel)
    }
    
    func byAppend(badge: String, color: UIColor) -> ASAttributedString {
        return byAppend(badge: badge,
                        baselineOffset: 5.0,
                        font: UIFont.boldSystemFont(ofSize: 6.0),
                        color: color)
    }
    
    func byAppend(badge: String, font: UIFont, color: UIColor) -> ASAttributedString {
        return byAppend(badge: badge,
                        baselineOffset: 5.0,
                        font: font,
                        color: color)
    }
    
    func byAppend(badge: String,
                  baselineOffset: CGFloat,
                  font: UIFont,
                  color: UIColor) -> ASAttributedString {
        let badgeString: ASAttributedString = "\(badge, .baselineOffset(baselineOffset), .foreground(color), .font(font))"
        return self + badgeString
    }
    
    static func string(with image: UIImage,
                       trailingText: String? = nil) -> ASAttributedString {
        return string(image: image,
                      imageSize: kIndicatorMediumSize,
                      trailingText: trailingText)
    }
    
    static func string(with icons: [UIImage], size: CGSize, separator: String? = nil) -> ASAttributedString {
        var strings = [ASAttributedString]()
        for icon in icons {
            let string: ASAttributedString = "\(.image(icon, .custom(.center, size: size)))"
            strings.append(string)
        }
        
        let separator = separator ?? ""
        return strings.joined(separator: separator)
    }
}

extension Array where Element == ASAttributedString {
    
    func joined(separator: String) -> ASAttributedString {
        var result: ASAttributedString = ""
        for (index, element) in self.enumerated() {
            result += element
            if index < self.count - 1 {
                result += separator
            }
        }
        
        return result
    }
}
