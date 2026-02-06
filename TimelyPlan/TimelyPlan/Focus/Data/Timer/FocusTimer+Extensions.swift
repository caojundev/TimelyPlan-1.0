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
    
    var timerType: FocusTimerType {
        return config?.timerType ?? .defaultType
    }
    
    var timerInfo: String? {
        let config = self.config ?? FocusTimerConfig()
        return config.summary
    }
    
    var timerConfig: FocusTimerConfig? {
        return self.config
    }
}

extension FocusTimer: Sortable, TPHexColorConvertible {
    
    /// 获取计时器特征
    var feature: TimerFeature? {
        if let identifier = self.identifier {
            return TimerFeature(identifier: identifier, timerType: timerType, shotName: name)
        }
        
        return nil
    }
    
    // MARK: - TPHexColorConvertible
    var defaultColor: UIColor {
        return kFocusTimerDefaultColor
    }
}
