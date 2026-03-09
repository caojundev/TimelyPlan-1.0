//
//  HabitTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

class HabitTask: NSObject, Sortable {
    
    /// 任务唯一标识
    var identifier: String
    
    /// 表情符号
    var emoji: String!
    
    /// 名称
    var name: String?

    /// 颜色
    var color: UIColor!
    
    /// 时间范围
    var dateRange: DateRange!
    
    /// 目标
    var goal: HabitGoal!
    
    /// 时间选项
    var timeOption: HabitTimeOption = .anytime
    
    /// 是否提醒
    var shouldRemind: Bool = false

    /// 自动显示日志弹窗
    var autoShowLog: Bool = false
    
    /// 备注
    var note: String?

    /// 时间计划
    private(set) lazy var timePlan: HabitTimePlan = {
        let type = HabitTimePlanType(rawValue: Int(content.timePlanType)) ?? .regularly
        if let jsonString = content.timePlanRuleJSON {
            if type == .randomly {
                let randomRule = HabitTimePlanRandomRule.model(with: jsonString)
                return HabitTimePlan(type: type, regularRule: nil, randomRule: randomRule)
            } else {
                let regularRule = HabitTimePlanRegularRule.model(with: jsonString)
                return HabitTimePlan(type: type, regularRule: regularRule, randomRule: nil)
            }
        }
        
        return HabitTimePlan()
    }()
    
    /// 习惯提醒
    private(set) lazy var reminder: HabitReminder? = {
        if let jsonString = content.reminderJSON {
            return HabitReminder.model(with: jsonString)
        }
        
        return nil
    }()
    
    var isArchived: Bool {
        get { return content.isArchived }
        set { content.isArchived = newValue }
    }
    
    /// 排序因子
    var order: Int64 {
        get { return content.order }
        set { content.order = newValue }
    }
    
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

    private(set) var content: CDHabitTask
    
    /// 修改日期
    var modificationDate: Date?
    
    init(content: CDHabitTask) {
        self.content = content
        self.identifier = content.identifier ?? UUID().uuidString
        super.init()
        self.updateNormalProperties()
    }
    
    /// 更新属性
    private func updateNormalProperties() {
        self.emoji = content.emoji
        self.name = content.name
        self.color = content.color ?? kHabitTaskDefaultColor
        self.dateRange = DateRange(startDate: content.startDate ?? .now, endDate: content.endDate)
        self.timeOption = HabitTimeOption(rawValue: Int(content.timeOption)) ?? .anytime
        self.shouldRemind = content.shouldRemind
        self.autoShowLog = content.autoShowLog
        self.note = content.note
        self.modificationDate = content.modificationDate
        
        let targetMode = HabitGoal.TargetMode(rawValue: Int(content.goalMode)) ?? .checkin
        let recordType = HabitGoal.RecordType(rawValue: Int(content.goalRecordType)) ?? .completeAll
        self.goal = HabitGoal(mode: targetMode,
                              targetAmount: content.goalTargetAmount,
                              unit: content.goalUnit,
                              recordType: recordType,
                              recordAmount: content.goalRecordAmount)
    }
    
    // MARK: - Update
    func update(with editingTask: HabitEditingTask) {
        self.content.update(with: editingTask)
        self.updateNormalProperties()
        
        /// 更新懒加载属性
        self.timePlan = editingTask.timePlan
        self.reminder = editingTask.reminder
    }
    
    /// 获取特定记录对应的任务状态
    func status(with record: HabitRecord?) -> HabitTaskStatus {
        guard let record = record else {
            return .notStarted
        }

        var status: HabitTaskStatus = .notStarted
        let amount = record.amount
        if amount >= self.goal.validatedTargetAmount {
            status = .completed /// 已完成
        } else {
            if amount > 0 {
                status = .inProgress /// 进行中
            }
            
            if record.status == .failed {
                status = .failed(record.reason) /// 失败
            } else if record.status == .skipped {
                status = .skipped(record.reason)  /// 跳过
            }
        }
        
        return status
    }
    
    /// 获取特定记录对应的任务进度
    func progress(with record: HabitRecord?) -> CGFloat {
        guard let record = record else {
            return 0.0
        }

        let amount = record.amount
        let progress = CGFloat(amount) / CGFloat(goal.validatedTargetAmount)
        return validatedProgress(progress)
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
        var indicators = [timeOptionIndicator]

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
    
    var timeOptionIndicator: ASAttributedString {
        guard let image = self.timeOption.iconImage else {
            return self.timeOption.title.attributedString
        }
        
        return .string(image: image,
                       imageSize: .size(4),
                       imageColor: .white,
                       trailingText: self.timeOption.title,
                       separator: " ")
    }
    
    /// 提醒闹铃图标
    var bellIndicator: ASAttributedString {
        let image = resGetImage("bell_fill_16")!
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
    func logIndicator(color: UIColor? = nil) -> ASAttributedString {
        return .logIndicator(color: color)
    }
    
    /// 跳过指示信息
    func skipIndicator(reason: String? = nil, color: UIColor? = nil) -> ASAttributedString {
        return .skipIndicator(reason: reason, color: color)
    }
    
    /// 失败指示信息
    func failIndicator(reason: String? = nil, color: UIColor? = nil) -> ASAttributedString {
        return .failIndicator(reason: reason, color: color)
    }
}
