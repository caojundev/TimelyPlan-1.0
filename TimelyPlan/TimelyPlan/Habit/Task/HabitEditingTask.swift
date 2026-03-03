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
    var timePlan: HabitTimePlan = HabitTimePlan()
    
    /// 时间选项
    var timeOption: HabitTimeOption = .morning
    
    /// 是否提醒
    var shouldRemind: Bool = false
    
    /// 习惯提醒
    var reminder: HabitReminder?
    
    /// 自动显示日志弹窗
    var autoShowLog: Bool = false
    
    /// 备注
    var note: String?
    
    /// 图标
    var icon: TPIcon {
        get {
            return TPIcon(text: emoji ?? "C")
        }
        
        set {
            self.emoji = newValue.text
        }
    }
    
    // MARK: - Equatable
    static func == (lhs: HabitEditingTask, rhs: HabitEditingTask) -> Bool {
        return lhs.emoji == rhs.emoji &&
        lhs.name == rhs.name &&
        lhs.color == rhs.color &&
        lhs.dateRange == rhs.dateRange &&
        lhs.shouldRemind == rhs.shouldRemind &&
        lhs.note == rhs.note
    }
}
