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
    static let colorHex = "colorHex"
    static let note = "note"
    static let isAddedToMyDay = "isAddedToMyDay"
    static let isCompleted = "isCompleted"
    static let startDate = "startDate"
    static let endDate = "endDate"
    static let startTime = "startTime"
    static let duration = "duration"
    static let shouldRemind = "shouldRemind"
    static let reminderJSON = "reminderJSON"
    static let timePlanRuleJSON = "timePlanRuleJSON"
    static let initialValue = "initialValue"
    static let targetValue = "targetValue"
    static let currentValue = "currentValue"
    static let calculation = "calculation"
    static let recordType = "recordType"
    static let autoRecordValue = "autoRecordValue"
    static let presetRecordValues = "presetRecordValues"
    static let weight = "weight"
    static let stepMarkdown = "stepMarkdown"
    static let stepCount = "stepCount"
    static let stepCompletedCount = "stepCompletedCount"
    static let progressFraction = "progressFraction"
    static let creationDate = "creationDate"
    static let modificationDate = "modificationDate"
    static let completionDate = "completionDate"
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

class GoalTask: NSObject, TPHexColorConvertible, SortableIdentifiable {
    
    // MARK: - 基本属性
    
    /// 任务唯一标识
    var identifier: String
    
    /// 排序因子
    var order: Int64
    
    /// 任务名称
    var name: String?
    
    /// 十六进制颜色字符串
    var colorHex: String?
    
    /// 创建日期
    let creationDate: Date?
    
    /// 修改日期
    let modificationDate: Date?
    
    /// 是否已完成
    var isCompleted: Bool
    
    /// 完成日期
    var completionDate: Date?
    
    /// 是否已添加到我的一天
    var isAddedToMyDay: Bool
    
    /// 备注
    var note: String?
    
    // MARK: - 计划属性
    
    /// 开始时间（距离当天零点的秒数，-1 表示不限时）
    var startTime: Int64 = -1
    
    /// 持续时长（秒）
    var duration: Int64 = 60
    
    /// 是否提醒
    var shouldRemind: Bool = false
    
    /// 提醒 JSON 字符串
    private let reminderJSON: String?
    
    /// 提醒（懒加载，从 JSON 反序列化）
    private(set) lazy var reminder: ScheduledReminder? = {
        guard let json = reminderJSON else { return nil }
        return ScheduledReminder.model(with: json)
    }()
    
    /// 时间计划规则 JSON 字符串
    private let timePlanRuleJSON: String?
    
    /// 时间计划规则（懒加载，从 JSON 反序列化）
    private(set) lazy var timePlan: TaskTimePlanRegularRule = {
        if let json = timePlanRuleJSON,
           let rule = TaskTimePlanRegularRule.model(with: json) {
            return rule
        }
        
        return TaskTimePlanRegularRule()
    }()
    
    /// 开始日期
    var startDate: Date?
    
    /// 结束日期
    var endDate: Date?
    
    // MARK: - 步骤
    
    /// 步骤总数
    private(set) var stepCount: Int64 = 0
    
    /// 已完成步骤数
    private(set) var stepCompletedCount: Int64 = 0
    
    /// 步骤的 Markdown 文本
    private var stepMarkdown: String?
    
    /// 步骤列表（懒加载，从 Markdown 解析）
    private(set) lazy var steps: [TodoStep]? = {
        guard let markdown = stepMarkdown else { return nil }
        let parser = TodoStepParser()
        return parser.parse(markdown)
    }()
    
    // MARK: - 进度相关
    
    /// 开始数值
    var initialValue: Int64
    
    /// 目标数值
    var targetValue: Int64
    
    /// 当前数值
    var currentValue: Int64 = 0
    
    /// 计算方式
    var calculation: GoalProgressCalculation
    
    /// 记录类型
    var recordType: GoalProgressRecordType
    
    /// 自动记录数值
    var autoRecordValue: Int?
    
    /// 预设记录数值（未持久化，仅用于记录入口的快捷选项）
    var presetRecordValues: [Int]?
    
    /// 任务权重（1～10）
    var weight: Int64
    
    // MARK: - Initialization
    init(identifier: String = UUID().uuidString,
         order: Int64 = 0,
         name: String? = nil,
         colorHex: String? = nil,
         isAddedToMyDay: Bool = false,
         startTime: Int64 = -1,
         duration: Int64 = 60,
         shouldRemind: Bool = false,
         reminderJSON: String? = nil,
         timePlanRuleJSON: String? = nil,
         startDate: Date? = nil,
         endDate: Date? = nil,
         note: String? = nil,
         initialValue: Int64 = 0,
         targetValue: Int64 = 100,
         currentValue: Int64 = 0,
         calculation: GoalProgressCalculation = .sum,
         recordType: GoalProgressRecordType = .manual,
         autoRecordValue: Int? = nil,
         presetRecordValues: [Int]? = nil,
         weight: Int64 = 5,
         stepMarkdown: String? = nil,
         stepCount: Int64 = 0,
         stepCompletedCount: Int64 = 0,
         isCompleted: Bool = false,
         creationDate: Date? = nil,
         completionDate: Date? = nil,
         modificationDate: Date? = nil) {
        self.identifier = identifier
        self.order = order
        self.name = name
        self.colorHex = colorHex
        self.isAddedToMyDay = isAddedToMyDay
        self.startTime = startTime
        self.duration = duration
        self.shouldRemind = shouldRemind
        self.reminderJSON = reminderJSON
        self.timePlanRuleJSON = timePlanRuleJSON
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.initialValue = initialValue
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.calculation = calculation
        self.recordType = recordType
        self.autoRecordValue = autoRecordValue
        self.presetRecordValues = presetRecordValues
        self.weight = weight
        self.stepMarkdown = stepMarkdown
        self.stepCount = stepCount
        self.stepCompletedCount = stepCompletedCount
        self.isCompleted = isCompleted
        self.creationDate = creationDate
        self.completionDate = completionDate
        self.modificationDate = modificationDate
        super.init()
    }
    
    /// 根据 CoreData 目标任务创建模型
    convenience init(content: CDGoalTask) {
        self.init(identifier: content.identifiableKey,
                  order: content.order,
                  name: content.name,
                  colorHex: content.colorHex,
                  isAddedToMyDay: content.isAddedToMyDay,
                  startTime: content.startTime,
                  duration: content.duration,
                  shouldRemind: content.shouldRemind,
                  reminderJSON: content.reminderJSON,
                  timePlanRuleJSON: content.timePlanRuleJSON,
                  startDate: content.startDate,
                  endDate: content.endDate,
                  note: content.note,
                  initialValue: content.initialValue,
                  targetValue: content.targetValue,
                  currentValue: content.currentValue,
                  calculation: content.progressCalculation,
                  recordType: content.progressRecordType,
                  autoRecordValue: content.autoRecordNumber,
                  weight: Int64(content.weight),
                  stepMarkdown: content.stepMarkdown,
                  stepCount: content.stepCount,
                  stepCompletedCount: content.stepCompletedCount,
                  isCompleted: content.isCompleted,
                  creationDate: content.creationDate,
                  completionDate: content.completionDate,
                  modificationDate: content.modificationDate)
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
        return currentValue == other.currentValue
            && isCompleted == other.isCompleted
            && editingTask == other.editingTask
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
    
    // MARK: - Getters
    var displayName: String {
        return name ?? resGetString("Untitled Task")
    }
    
    /// 检查类型
    var checkType: TodoTaskCheckType {
        guard isValidProgress else {
            return .normal
        }
        
        if initialValue < targetValue {
            return .increase
        }
        
        return .decrease
    }
    
    /// 是否有效进度
    var isValidProgress: Bool {
        if initialValue == targetValue {
            return false
        }
        
        return true
    }
    
    /// 是否有提醒
    var hasReminder: Bool {
        guard shouldRemind, let reminder = reminder, reminder.hasAlarm else {
            return false
        }
        
        return true
    }
    
    /// 日期区间
    var dateRange: DateRange {
        get {
            return DateRange(startDate: startDate, endDate: endDate)
        }
        
        set {
            self.startDate = newValue.startDate
            self.endDate = newValue.endDate
        }
    }
    
    // MARK: - 进度
    /// 进度（0.0 ~ 1.0）
    var progressFraction: Double {
        return GoalTask.progressFraction(initialValue: initialValue,
                                         targetValue: targetValue,
                                         currentValue: currentValue)
    }
    
    /// 进度是否已完成
    var isProgressCompleted: Bool {
        return progressFraction >= 1.0
    }
    
    /// 计算进度
    static func progressFraction(initialValue: Int64,
                                 targetValue: Int64,
                                 currentValue: Int64) -> Double {
        let total = targetValue - initialValue
        guard total != 0 else {
            return 0.0
        }
        
        let fraction = Double(currentValue - initialValue) / Double(total)
        return max(0.0, min(fraction, 1.0))
    }
    
    /// 限制在合法区间内的当前数值
    func validatedCurrentValue(_ value: Int64) -> Int64 {
        return GoalTask.validatedCurrentValue(value,
                                              initialValue: initialValue,
                                              targetValue: targetValue)
    }
    
    /// 限制在合法区间内的数值
    static func validatedCurrentValue(_ value: Int64,
                                      initialValue: Int64,
                                      targetValue: Int64) -> Int64 {
        guard initialValue != targetValue else {
            return value
        }
        
        if initialValue < targetValue {
            return clampedValue(value, initialValue, targetValue)
        }
        
        return clampedValue(value, targetValue, initialValue)
    }
    
    /// 在指定数值上递增后的当前数值
    func currentValue(byIncrementing increment: Int64) -> Int64 {
        return validatedCurrentValue(currentValue + increment)
    }
    
    /// 自动记录数值（递减类型的目标取负值）
    var validatedAutoRecordValue: Int64 {
        var recordValue = Int64(autoRecordValue ?? 0)
        if recordValue == 0 {
            recordValue = 1
        }
        
        if checkType == .decrease {
            recordValue = -recordValue
        }
        
        return recordValue
    }
    
    /// 是否支持自动记录
    var canAutoRecord: Bool {
        return isValidProgress && recordType == .auto
    }
    
    /// 自动记录后的当前数值
    func autoRecordedCurrentValue() -> Int64? {
        guard canAutoRecord else {
            return nil
        }
        
        return currentValue(byIncrementing: validatedAutoRecordValue)
    }
}

// MARK: - 编辑任务
extension GoalTask {
    
    /// 编辑目标任务
    var editingTask: GoalEditingTask {
        var task = GoalEditingTask(startDate: startDate, endDate: endDate)
        task.name = name
        task.color = color ?? Self.defaultColor
        task.steps = steps
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
struct GoalEditingTask: Equatable, Hashable {
    
    var color: UIColor = .primary
    
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
            && lhs.color == rhs.color
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

// MARK: - 目标任务变更

struct GoalTaskChangeInfo {
    
    /// 目标任务
    let goalTask: GoalTask
    
    /// 改变内容
    let change: GoalTaskChange
}

/// 目标任务改变
enum GoalTaskChange: Hashable {
    
    /// 名称
    case name(oldValue: String?, newValue: String?)
    
    /// 备注
    case note(oldValue: String?, newValue: String?)
    
    /// 完成状态
    case completed(oldValue: Bool, newValue: Bool)
    
    /// 添加到我的一天
    case myDay(oldValue: Bool, newValue: Bool)
    
    /// 步骤
    case step(oldValue: [TodoStep]?, newValue: [TodoStep]?)
    
    /// 当前数值
    case progress(oldValue: Int64, newValue: Int64)
    
    /// 内容（名称、颜色、步骤、数值、权重、计划、提醒等整体更新）
    case content(oldValue: GoalEditingTask, newValue: GoalEditingTask)
}

extension Array where Element == GoalTaskChangeInfo {
    
    /// 所有目标任务
    var goalTasks: [GoalTask] {
        return self.map { $0.goalTask }
    }
}
