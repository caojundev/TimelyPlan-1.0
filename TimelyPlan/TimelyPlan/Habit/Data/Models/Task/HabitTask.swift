//
//  HabitTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

class HabitTask: NSObject, SortableIdentifiable {

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
    
    /// 开始时间
    let startTime: Int64
    
    /// 持续时长
    let duration: Int64
    
    /// 是否添加到我的一天
    let isAddedToMyDay: Bool
    
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

    /// 显示标题（emoji + displayName）
    var displayTitle: String {
        return emoji + displayName
    }
    
    var displayName: String {
        return name ?? resGetString("Untitled Habit")
    }
    
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

    // MARK: - SortableIdentifiable
    /// 排序因子
    var order: Int64
    
    var identifiableKey: String {
        return identifier
    }
    
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
    
    init?(content: CDHabitTask) {
        guard let identifier = content.identifier else {
            return nil
        }
        
        self.identifier = identifier
        self.order = content.order
        self.emoji = content.emoji
        self.name = content.name
        self.color = content.color ?? HabitConstant.taskDefaultColor
        self.dateRange = content.dateRange
        self.isAddedToMyDay = content.isAddedToMyDay
        self.timeOption = HabitTimeOption(rawValue: Int(content.timeOption)) ?? .anytime
        self.startTime = content.startTime
        self.duration = content.duration
        self.shouldRemind = content.shouldRemind
        self.note = content.note
        self.modificationDate = content.modificationDate
        self.goal = content.goal
        self.isArchived = content.isArchived
        self.timePlanRuleJSON = content.timePlanRuleJSON
        self.reminderJSON = content.reminderJSON
        super.init()
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
    
    func isReminderChanged(_ editingTask: HabitEditingTask) -> Bool {
        if shouldRemind != editingTask.shouldRemind {
            return true
        }
        
        return reminder != editingTask.reminder   
    }
    
    // MARK: - 计划日期
    func nextPlanDates(from date: Date = .now, count: Int = 3) -> [Date] {
        var dates = Set<Date>()
        var referenceDate: Date = date
        for _ in 1...count {
            guard let planDate = nextPlanDate(from: referenceDate) else {
               break
            }
            
            dates.insert(planDate)
            if let nextReferenceDate = planDate.dateByAddingDays(1) {
                referenceDate = nextReferenceDate
            } else {
                break
            }
        }
        
        return dates.sorted{ $0 < $1}
    }
    
    func nextPlanDate(from date: Date) -> Date? {
        guard let startDate = dateRange.startDate else {
            return nil
        }
        
        let endDate = dateRange.endDate
        return timePlan.nextPlanDate(from: date,
                                     startDate: startDate,
                                     endDate: endDate)
    }
}
