//
//  FocusTimer+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/27.
//

import Foundation

struct FocusTimerKey {
    static var name: String = "name"
    static var identifier: String = "identifier"
    static var isArchived: String = "isArchived"
}

extension FocusTimer: FocusTimerRepresentable {
    
    var timerColor: UIColor {
        return color ?? kFocusTimerDefaultColor
    }
    
    var timerType: FocusTimerType {
        return config?.timerType ?? .defaultType
    }
    
    var timerDescription: String? {
        let config = self.config ?? FocusTimerConfig()
        return config.summary
    }
    
    var timerConfig: FocusTimerConfig? {
        return self.config
    }
    
    /// 计时器信息
    var timerInfo: TextRepresentable? {
        let timerName = self.name ?? resGetString("Untitled")
        let timerColor = self.color ?? kFocusTimerDefaultColor
        let attributedInfo: ASAttributedString = "\("●", .foreground(timerColor)) \(timerName)"
        return attributedInfo
    }
}

extension FocusTimer: Sortable, TPHexColorConvertible {
    
    /// 获取计时器特征
    var feature: TimerFeature? {
        if let identifier = self.identifier {
            return TimerFeature(identifier: identifier)
        }
        
        return nil
    }
    
    // MARK: - TPHexColorConvertible
    static var defaultColor: UIColor  {
        return kFocusTimerDefaultColor
    }
}
