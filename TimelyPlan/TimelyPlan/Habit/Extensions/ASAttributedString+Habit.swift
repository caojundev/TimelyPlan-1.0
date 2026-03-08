//
//  ASAttributedString+Habit.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/7.
//

import Foundation
import UIKit

extension ASAttributedString {
    
    /// 备注
    static var logIndicator: ASAttributedString {
        return logIndicator(color: nil)
    }
    
    static func logIndicator(color: UIColor?) -> ASAttributedString {
        var image = resGetImage("habit_indicator_log_16")!
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
        var image = resGetImage("habit_indicator_status_checked_16")!
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
        var image = resGetImage("habit_indicator_status_skipped_16")!
        if let color = color {
            image = image.withTintColor(color)
        }

        return .string(image: image, imageSize: .size(3), trailingText: reason)
    }
    
    /// 失败
    static func failIndicator() -> ASAttributedString {
        return failIndicator(reason: nil, color: nil)
    }
    
    static func failIndicator(reason: String?, color: UIColor) -> ASAttributedString {
        return failIndicator(reason: reason, color: nil)
    }
    
    static func failIndicator(color: UIColor) -> ASAttributedString {
        return failIndicator(reason: nil, color: color)
    }
    
    static func failIndicator(reason: String?,
                              color: UIColor?) -> ASAttributedString {
        var image = resGetImage("habit_indicator_status_failed_16")!
        if let color = color {
            image = image.withTintColor(color)
        }

        return .string(image: image, imageSize: .size(3), trailingText: reason)
    }
}
