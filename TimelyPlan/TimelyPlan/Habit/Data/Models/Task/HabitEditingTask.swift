//
//  HabitEditTask.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/17.
//

import Foundation
import UIKit

/// 习惯编辑任务
struct HabitEditingTask: Equatable {
    
    /// 图标
    var emoji: String? = Character.randomEmoji().stringValue
    
    /// 名称
    var name: String?

    /// 颜色
    var color: UIColor = .randomHabitTaskColor
    
    /// 时间范围
    var dateRange: DateRange = DateRange()
    
    /// 目标
    var goal: HabitGoal = HabitGoal()
    
    /// 频率
    var timePlan: TaskTimePlanRegularRule = TaskTimePlanRegularRule()
    
    /// 是否添加到我的一天
    var isAddedToMyDay: Bool = false

    /// 时间选项
    var timeOption: HabitTimeOption = .anytime
    
    /// 开始时间
    var startTime: Int64 = 0
    
    /// 持续时长
    var duration: Int64 = 0
        
    /// 是否提醒
    var shouldRemind: Bool = false
    
    /// 习惯提醒
    var reminder: ScheduledReminder?
    
    /// 备注
    var note: String?
    
    /// 图标
    var icon: TPIcon {
        get { return TPIcon(text: emoji ?? "C") }
        set { self.emoji = newValue.text }
    }
    
    var validatedStartTime: Int64 {
        guard timeOption != .anytime else {
            return 0
        }
        
        if startTime == 0, duration == 0 {
            return Int64(timeOption.presetHour * SECONDS_PER_HOUR)
        }
        
        return startTime
    }
    
    var validatedDuration: Int64 {
        guard timeOption != .anytime else {
            return 0
        }
        
        if duration < SECONDS_PER_MINUTE {
            return Int64(SECONDS_PER_MINUTE)
        }
        
        return duration
    }

}
