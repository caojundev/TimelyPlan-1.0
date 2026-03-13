//
//  CDHabitTask+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import UIKit

extension CDHabitTask: TPHexColorConvertible {
    
    static var defaultColor: UIColor {
        return kHabitTaskDefaultColor
    }
    
    var emoji: String {
        if let iconName = iconName {
            return iconName
        }
        
        /// 任务名称首字符
        return name?.first?.stringValue ?? "C"
    }
    
    /// 根据编辑任务创建新任务
    static func newTask(with editingTask: HabitEditingTask) -> CDHabitTask {
        let task = CDHabitTask.createEntity(in: .defaultContext)
        task.identifier = UUID().uuidString ///新创建任务设置标识
        task.creationDate = .now
        task.isArchived = false
        task.update(with: editingTask)
        return task
    }
    
    func update(with editingTask: HabitEditingTask) {
        self.iconName = editingTask.emoji
        self.name = editingTask.name
        self.colorHex = editingTask.color.hexString
        
        /// 时间范围
        self.startDate = editingTask.dateRange.startDate
        self.endDate = editingTask.dateRange.endDate
 
        /// 目标
        let goal = editingTask.goal
        self.goalMode = Int16(goal.mode.rawValue)
        self.goalTargetAmount = goal.validatedTargetAmount
        self.goalUnit = goal.unit
        self.goalRecordType = Int16(goal.recordType?.rawValue ?? 0)
        self.goalRecordAmount = goal.recordAmount ?? 0
    
        /// 频率
        let timePlan = editingTask.timePlan
        self.timePlanType = Int16(timePlan.type.rawValue)
        self.timePlanRuleJSON = timePlan.regularRule?.jsonString()
        /// 时间选项
        self.timeOption = Int16(editingTask.timeOption.rawValue)
        
        /// 提醒
        self.shouldRemind = editingTask.shouldRemind
        self.reminderJSON = editingTask.reminder?.jsonString()
        
        self.note = editingTask.note
        self.modificationDate = .now
    }
}
