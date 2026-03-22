//
//  HabitTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

class HabitTask: NSObject, Sortable {

    /// 排序因子
    var order: Int64
    
    // MARK: - 内容属性
    
    /// 任务唯一标识
    let identifier: String

    /// 表情符号
    let emoji: String
    
    /// 名称
    let name: String?

    /// 颜色
    let color: UIColor
    
    /// 时间范围
    let dateRange: DateRange
    
    /// 目标
    let goal: HabitGoal
    
    /// 时间选项
    let timeOption: HabitTimeOption
    
    /// 备注
    let note: String?

    /// 修改日期
    let modificationDate: Date?
    
    /// 是否已归档
    let isArchived: Bool
    
    /// 时间计划规则 JSON 字符串
    let timePlanRuleJSON: String?

    /// 是否提醒
    let shouldRemind: Bool

    /// 提醒 JSON 字符串
    let reminderJSON: String?

    /// 时间计划
    private(set) lazy var timePlan: HabitTimePlan = {
        if let json = timePlanRuleJSON {
            let regularRule = HabitTimePlanRegularRule.model(with: json)
            return HabitTimePlan(regularRule: regularRule)
        }
        
        return HabitTimePlan()
    }()
    
    /// 习惯提醒
    private(set) lazy var reminder: HabitReminder? = {
        if let json = reminderJSON {
            return HabitReminder.model(with: json)
        }
        
        return nil
    }()

    // MARK: - 只读属性
    /// 图标
    var icon: TPIcon {
        return TPIcon(text: emoji)
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
    
    init(content: CDHabitTask) {
        self.identifier = content.identifier ?? UUID().uuidString
        self.order = content.order
        self.emoji = content.emoji
        self.name = content.name
        self.color = content.color ?? kHabitTaskDefaultColor
        self.dateRange = content.dateRange
        self.timeOption = HabitTimeOption(rawValue: Int(content.timeOption)) ?? .anytime
        self.shouldRemind = content.shouldRemind
        self.note = content.note
        self.modificationDate = content.modificationDate
        self.goal = content.goal
        self.isArchived = content.isArchived
        self.timePlanRuleJSON = content.timePlanRuleJSON
        self.reminderJSON = content.reminderJSON
        super.init()
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? HabitTask {
            return self.identifier == other.identifier
        }
        
        return false
    }
}
