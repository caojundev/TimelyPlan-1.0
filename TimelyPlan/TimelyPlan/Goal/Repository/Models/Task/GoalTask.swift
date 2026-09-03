//
//  GoalTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/2.
//

import Foundation
import UIKit

struct GoalTaskKey {
    static let identifier = "identifier"
    static let order = "order"
    static let name = "name"
    static let isAddedToMyDay = "isAddedToMyDay"
    static let startDate = "startDate"
    static let endDate = "endDate"
    static let note = "note"
    static let initialValue = "initialValue"
    static let targetValue = "targetValue"
    static let calculation = "calculation"
    static let recordType = "recordType"
    static let autoRecordValue = "autoRecordValue"
    static let presetRecordValues = "presetRecordValues"
    static let weight = "weight"
}

/// 计算方式
enum GoalProgressCalculation: Int, Codable, TPMenuRepresentable {
    
    /// 添加
    case sum = 0
    
    /// 更新
    case update
    
    var title: String {
        switch self {
        case .sum:
            return resGetString("Sum")
        case .update:
            return resGetString("Update")
        }
    }
}

/// 记录方式
enum GoalProgressRecordType: Int, Codable, TPMenuRepresentable {
    
    /// 手动
    case manual = 0
    
    /// 自动
    case auto
    
    var title: String {
        switch self {
        case .manual:
            return resGetString("Manual")
        case .auto:
            return resGetString("Auto")
        }
    }
}

class GoalTask: NSObject, SortableIdentifiable {
    
    /// 任务唯一标识
    var identifier: String
    
    /// 排序因子
    var order: Int64
    
    /// 任务名称
    var name: String?
    
    /// 步骤
    var steps: [TodoStep]?
    
    /// 是否已添加到我的一天
    var isAddedToMyDay: Bool

    var startTime: Int64 = -1
    
    var duration: Int64 = 60

    /// 是否提醒
    var shouldRemind: Bool = false

    /// 提醒
    var reminder: ScheduledReminder?

    /// 开始日期
    var startDate: Date?
    
    /// 结束日期
    var endDate: Date?
    
    /// 备注
    var note: String?
    
    /// 开始数值
    var initialValue: Int64
    
    /// 目标数值
    var targetValue: Int64
    
    /// 计算方式
    var calculation: GoalProgressCalculation
    
    /// 记录类型
    var recordType: GoalProgressRecordType
    
    /// 自动记录数值
    var autoRecordValue: Int?
    
    /// 预设记录数值
    var presetRecordValues: [Int]?
    
    /// 任务权重（1～10）
    var weight: Int64
    
    /// 修改日期
    let modificationDate: Date?
    
    
    init(identifier: String = UUID().uuidString,
         order: Int64 = 0,
         name: String? = nil,
         isAddedToMyDay: Bool = false,
         startDate: Date? = nil,
         endDate: Date? = nil,
         note: String? = nil,
         initialValue: Int64 = 0,
         targetValue: Int64 = 100,
         calculation: GoalProgressCalculation = .sum,
         recordType: GoalProgressRecordType = .manual,
         autoRecordValue: Int? = nil,
         presetRecordValues: [Int]? = nil,
         weight: Int64 = 5,
         modificationDate: Date? = nil) {
        self.identifier = identifier
        self.order = order
        self.name = name
        self.isAddedToMyDay = isAddedToMyDay
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.initialValue = initialValue
        self.targetValue = targetValue
        self.calculation = calculation
        self.recordType = recordType
        self.autoRecordValue = autoRecordValue
        self.presetRecordValues = presetRecordValues
        self.weight = weight
        self.modificationDate = modificationDate
        super.init()
    }
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return identifier
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? GoalTask else { return false }
        if self === other { return true }
        return editingTask == other.editingTask
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? GoalTask {
            return self.identifier == other.identifier
        }
        
        return false
    }
}

// MARK: - 编辑任务
extension GoalTask {
    
    /// 编辑目标任务
    var editingTask: GoalEditingTask {
        var task = GoalEditingTask(startDate: startDate, endDate: endDate)
        task.name = name
        if let markdown = steps?.markdown() {
            let stepParser = TodoStepParser()
            task.steps = stepParser.parse(markdown)
        }
        
        task.isAddedToMyDay = isAddedToMyDay
        task.note = note
        task.initialValue = initialValue
        task.targetValue = targetValue
        task.calculation = calculation
        task.recordType = recordType
        task.autoRecordValue = autoRecordValue
        task.presetRecordValues = presetRecordValues
        task.weight = weight
        task.startTime = startTime
        task.duration = duration
        task.shouldRemind = shouldRemind
        task.reminder = reminder?.copy() as? ScheduledReminder
        
        return task
    }
    
    /// 判断编辑内容是否与当前任务相同
    func isSameTask(as editingTask: GoalEditingTask) -> Bool {
        let current = self.editingTask
        return current == editingTask
    }
}

extension Array where Element == GoalTask {
    
    /// 所有标识
    var identifiers: [String] {
        return self.map { $0.identifier }
    }
}


/// 目标任务编辑模型
struct GoalEditingTask: Equatable {
    
    var name: String?
    
    /// 步骤
    var steps: [TodoStep]?
    
    /// 是否已添加到我的一天
    var isAddedToMyDay: Bool
    
    var startTime: Int64 = -1
    
    var duration: Int64 = 60

    /// 是否提醒
    var shouldRemind: Bool = false

    /// 提醒
    var reminder: ScheduledReminder?

    /// 开始日期
    var startDate: Date?
    
    /// 结束日期
    var endDate: Date?
    
    /// 备注
    var note: String?
    
    /// 开始数值
    var initialValue: Int64
    
    /// 目标数值
    var targetValue: Int64
    
    /// 计算方式
    var calculation: GoalProgressCalculation
    
    /// 记录类型
    var recordType: GoalProgressRecordType
    
    /// 自动记录数值
    var autoRecordValue: Int?
    
    /// 预设记录数值
    var presetRecordValues: [Int]?
    
    /// 任务权重（1～10）
    var weight: Int64
    
    init() {
        let current = Date()
        self.name = nil
        self.isAddedToMyDay = false
        self.startDate = current.startOfDay()
        self.endDate = current.dateByAddingMonths(1)?.endOfDay()
        self.note = nil
        self.initialValue = 0
        self.targetValue = 100
        self.calculation = .sum
        self.recordType = .manual
        self.autoRecordValue = nil
        self.presetRecordValues = nil
        self.weight = 5
    }
    
    init(startDate: Date?, endDate: Date?) {
        self.init()
        self.startDate = startDate
        self.endDate = endDate
    }
    
    static func == (lhs: GoalEditingTask, rhs: GoalEditingTask) -> Bool {
        return lhs.name == rhs.name
            && lhs.steps?.markdown() == rhs.steps?.markdown()
            && lhs.isAddedToMyDay == rhs.isAddedToMyDay
            && lhs.startDate == rhs.startDate
            && lhs.endDate == rhs.endDate
            && lhs.note == rhs.note
            && lhs.initialValue == rhs.initialValue
            && lhs.targetValue == rhs.targetValue
            && lhs.calculation == rhs.calculation
            && lhs.recordType == rhs.recordType
            && lhs.autoRecordValue == rhs.autoRecordValue
            && lhs.presetRecordValues == rhs.presetRecordValues
            && lhs.weight == rhs.weight
            && lhs.shouldRemind == rhs.shouldRemind
            && lhs.reminder == rhs.reminder
            && lhs.startTime == rhs.startTime
            && lhs.duration == rhs.duration
    }
    
    var dateRange: DateRange {
        get {
            return DateRange(startDate: startDate, endDate: endDate)
        }
        
        set {
            self.startDate = newValue.startDate
            self.endDate = newValue.endDate
        }
    }
}
