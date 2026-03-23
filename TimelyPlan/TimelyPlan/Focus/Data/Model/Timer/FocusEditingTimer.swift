//
//  FocusEditingTimer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/26.
//

import Foundation
import UIKit

/// 专注编辑任务
struct FocusEditingTimer: Equatable {
    
    /// 名称
    var name: String?
    
    /// 颜色
    var color: UIColor = kFocusTimerDefaultColor
    
    /// 备注
    var note: String?
    
    /// 专注计时器
    var config: FocusTimerConfig?
    
    // MARK: - Equatable
    static func == (lhs: FocusEditingTimer, rhs: FocusEditingTimer) -> Bool {
        return lhs.name == rhs.name &&
                lhs.color == rhs.color &&
                lhs.note == rhs.note &&
                lhs.config == rhs.config
    }
}
