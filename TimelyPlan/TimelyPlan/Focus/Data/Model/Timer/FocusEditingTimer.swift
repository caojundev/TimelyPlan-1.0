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
    var color: UIColor = FocusConstant.timerDefaultColor
    
    /// 备注
    var note: String?
    
    /// 专注计时器
    var config: FocusTimerConfig?
    
    /// 是否添加到我的一天
    var isAddedToMyDay: Bool = false
    
    /// 开始日期
    var startDate: Date?
    
    /// 结束日期
    var endDate: Date?
    
    /// 开始时间
    var startTime: Int64 = -1
    
    /// 时间计划
    var timePlan: TaskTimePlan?

    /// 日期范围
    var dateRange: DateRange {
        get {
            return DateRange(startDate: startDate ?? .now, endDate: endDate)
        }
        
        set {
            self.startDate = newValue.startDate
            self.endDate = newValue.endDate
        }
    }
}
