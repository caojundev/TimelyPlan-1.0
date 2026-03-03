//
//  ASAttributedString+Habit.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/7.
//

import Foundation

extension ASAttributedString {
    
    /// 备注
    static var logIndicator: ASAttributedString {
        return logIndicator(color: nil)
    }
    
    static func logIndicator(color: UIColor?) -> ASAttributedString {
        var image = resGetImage("bell_fill_16")!
//        var image = UIImage(named: "IndicatorLogSmall")!
        if let color = color {
            image = image.withTintColor(color)
        }
        
        return .string(image: image, imageSize: .size(3))
    }
    
    // MARK: - 已打卡
    static var checkedInIndicator: ASAttributedString {
        return checkedInIndicator(color: nil)
    }
    
    static func checkedInIndicator(color: UIColor?) -> ASAttributedString {
        var image = resGetImage("bell_fill_16")!
//        var image = UIImage(named: "IndicatorCheckedInSmall")!
        if let color = color {
            image = image.withTintColor(color)
        }

        return .string(image: image, imageSize: .size(3))
    }
    
    
    /// 跳过
    static func skipIndicator() -> ASAttributedString {
        return skipIndicator(reason: nil, color: nil)
    }
    
    static func skipIndicator(reason: String?) -> ASAttributedString {
        return skipIndicator(reason: reason, color: nil)
    }
    
    static func skipIndicator(color: UIColor) -> ASAttributedString {
        return skipIndicator(reason: nil, color: color)
    }
    
    static func skipIndicator(reason: String?,
                              color: UIColor?) -> ASAttributedString {
        var image = resGetImage("bell_fill_16")!
//        var image = UIImage(named: "IndicatorSkippedSmall")!
        if let color = color {
            image = image.withTintColor(color)
        }

        return .string(image: image, imageSize: .size(3), trailingText: reason)
    }
    
    /// 失败
    static func failIndicator() -> ASAttributedString {
        return failIndicator(reason: nil, color: nil)
    }
    
    static func failIndicator(reason: String?) -> ASAttributedString {
        return failIndicator(reason: reason, color: nil)
    }
    
    static func failIndicator(color: UIColor) -> ASAttributedString {
        return failIndicator(reason: nil, color: color)
    }
    
    static func failIndicator(reason: String?,
                              color: UIColor?) -> ASAttributedString {
        var image = resGetImage("bell_fill_16")!
//        UIImage(named: "IndicatorFailedSmall")!
        if let color = color {
            image = image.withTintColor(color)
        }

        return .string(image: image, imageSize: .size(3), trailingText: reason)
    }
}
