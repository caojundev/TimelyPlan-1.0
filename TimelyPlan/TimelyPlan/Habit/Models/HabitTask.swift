//
//  HabitTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

class HabitTask: NSObject {
    
    /// 任务唯一标识
    var identifier: String = UUID().uuidString
    
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
        return TPIcon(text: emoji ?? "C")
    }
    
    /// 是否有提醒
    var hasAlarm: Bool {
        guard shouldRemind, let reminder = reminder, reminder.hasAlarm else {
            return false
        }
        
        return true
    }
    
    /// 任务所处阶段
    var phase: HabitPhase {
        guard let startDate = dateRange.startDate else {
            return .inProgress
        }
        
        let currentDate = Date()
        if currentDate < startDate {
            return .notStarted
        }
        
        if let endDate = dateRange.endDate, endDate < currentDate {
            return .finished
        }
        
        /// 在时间区间内
        return .inProgress
    }

    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? HabitTask {
            #warning("比较修改日期")
            return self.identifier == object.identifier
        }
        
        return false
    }
}

// MARK: - 编辑任务
extension HabitTask {
    
    /// 获取编辑任务
    var editingTask: HabitEditingTask {
        var task = HabitEditingTask()
        task.emoji = emoji
        task.name = name
        task.color = color
        task.goal = goal
        task.dateRange = dateRange
        task.timePlan = (timePlan.copy() as? HabitTimePlan) ?? HabitTimePlan()
        task.timeOption = timeOption
        task.shouldRemind = shouldRemind
        task.reminder = reminder?.copy() as? HabitReminder
        task.autoShowLog = autoShowLog
        task.note = note
        return task
    }
    
    /// 判断编辑任务内容是否与当前任务相同
    func isSameEditingTask(as other: HabitEditingTask) -> Bool {
        return editingTask == other
    }
}

// MARK: - 描述信息
extension HabitTask {
    
    // MARK: -  任务富文本信息
    var attributedInfo: ASAttributedString {
        var indicators = [ASAttributedString]()
        /// 提醒
        if hasAlarm {
            indicators.append(bellIndicator)
        }
        
        /// 所处阶段
        indicators.append("\(phase.title)")
        
        /// 时间计划
        if let timePlanIndicator = timePlanIndicator {
            indicators.append(timePlanIndicator)
        }
        
        return indicators.joined(separator: " • ")
    }
    
    /// 提醒闹铃图标
    var bellIndicator: ASAttributedString {
        let image = UIImage(named: "BellFill_16pt")!
        return .string(with: image)
    }
    
    /// 时间计划富文本信息
    var timePlanIndicator: ASAttributedString? {
        let title = timePlan.title ?? ""
        guard let subtitle = timePlan.subtitle else {
            return "\(title)"
        }
        
        return "\(title)(\(subtitle))"
    }
    
    /// 备注图标信息
    var logIndicator: ASAttributedString {
        return .logIndicator
    }
    
    /// 跳过指示信息
    func skipIndicator(reason: String?) -> ASAttributedString {
        return .skipIndicator(reason: reason)
    }
    
    /// 失败指示信息
    func failIndicator(reason: String?) -> ASAttributedString {
        return .failIndicator(reason: reason)
    }
}
