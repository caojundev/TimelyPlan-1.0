//
//  TodoTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/6.
//

import Foundation

@objcMembers class TodoTask: NSObject {
    
    // MARK: - 基本属性
    
    /// 所属列表（通过 section 间接获取）
    var list: TodoListFeature? {
        return section.list
    }
    
    /// 唯一标识符
    var identifier: String
    
    /// 排序因子
    var order: Int64 = 0
    
    /// 所属板块
    var section: TodoSectionFeature
    
    /// 是否已添加到"我的一天"
    var isAddedToMyDay: Bool = false
    
    /// 任务名称
    var name: String?
    
    /// 任务备注
    var note: String?
    
    /// 任务优先级
    var priority: TodoTaskPriority = .none
    
    /// 任务标签列表
    var tags: [TodoTag]?
    
    /// 创建日期
    var creationDate: Date?
    
    /// 完成日期
    var completionDate: Date?
    
    /// 最后修改日期
    var modificationDate: Date?
    
    /// 是否已完成
    var isCompleted: Bool = false
    
    /// 是否已移至废纸篓
    var isRemoved: Bool = false
    
    // MARK: - 进度相关
    
    /// 任务进度（懒加载）
    lazy var progress: TodoEditProgress? = {
        guard let json = progressJSON else { return nil }
        return TodoEditProgress.model(with: json)
    }()
    
    // MARK: - 日程相关
    
    /// 任务日程安排
    var schedule: TaskSchedule? {
        get {
            guard let startDate = startDate, let dueDate = dueDate else { return nil }
            
            let dateInfo = TaskDateInfo(
                startDate: startDate,
                endDate: dueDate,
                isAllDay: isAllDay
            )
            
            return TaskSchedule(
                dateInfo: dateInfo,
                reminder: reminder,
                repeatRule: repeatRule
            )
        }
        
        set {
            let dateInfo = newValue?.dateInfo
            self.startDate = dateInfo?.startDate
            self.dueDate = dateInfo?.endDate
            self.isAllDay = dateInfo?.isAllDay ?? true
            self.reminder = newValue?.reminder
            self.repeatRule = newValue?.repeatRule
        }
    }
    
    /// 任务开始日期
    private(set) var startDate: Date?
    
    /// 任务截止日期
    private(set) var dueDate: Date?
    
    /// 是否为全天任务
    private(set) var isAllDay: Bool = true
    
    /// 任务提醒（懒加载，从 JSON 反序列化）
    private(set) lazy var reminder: TaskReminder? = {
        guard let json = reminderJSON else { return nil }
        return TaskReminder.model(with: json)
    }()
    
    /// 重复规则（懒加载，从 JSON 反序列化）
    private(set) lazy var repeatRule: RepeatRule? = {
        guard let json = repeatRuleJSON else { return nil }
        return RepeatRule.model(with: json)
    }()
    
    // MARK: - 步骤相关
    
    /// 步骤总数
    private(set) var stepCount: Int = 0
    
    /// 已完成步骤数
    private(set) var stepCompletedCount: Int = 0
    
    /// 步骤的 Markdown 文本
    private var stepMarkdown: String?
    
    /// 步骤列表（懒加载，从 Markdown 解析）
    private(set) lazy var steps: [TodoStep]? = {
        guard let markdown = stepMarkdown else { return nil }
        let parser = TodoStepParser()
        return parser.parse(markdown)
    }()
    
    // MARK: - 重复任务相关
    
    /// 是否已从重复规则系列中分离
    let isDetached: Bool
    
    // MARK: - JSON 存储属性（用于序列化/反序列化）
    
    /// 提醒的 JSON 字符串
    private let reminderJSON: String?
    
    /// 重复规则的 JSON 字符串
    private let repeatRuleJSON: String?
    
    /// 进度的 JSON 字符串
    private let progressJSON: String?
    
    // MARK: - 计算属性
    
    /// 标签集合（用于快速查找和比较）
    var tagsSet: Set<TodoTag>? {
        guard let tags = tags, !tags.isEmpty else { return nil }
        return Set(tags)
    }
    
    /// 计算下一个重复日程
    var nextSchedule: TaskSchedule? {
        guard let schedule = schedule,
              let dateInfo = schedule.dateInfo,
              let repeatRule = schedule.repeatRule else {
            return nil
        }
        
        let repeatScheduler = RepeatScheduler()
        guard let nextRepeatDate = repeatScheduler.nextRepeatDate(
            completionDate: dateInfo.startDate,
            matching: repeatRule,
            startDate: dateInfo.startDate
        ) else {
            return nil
        }
        
        // 计算下一个重复周期的日期信息
        let startDate = nextRepeatDate
        let endDate = nextRepeatDate.dateByAddingSeconds(dateInfo.duration)!
        let nextDateInfo = TaskDateInfo(
            startDate: startDate,
            endDate: endDate,
            isAllDay: dateInfo.isAllDay
        )
        
        // 更新重复次数
        var nextRepeatRule: RepeatRule?
        if let copiedRule = repeatRule.copy() as? RepeatRule {
            copiedRule.count = (copiedRule.count ?? 0) + 1
            nextRepeatRule = copiedRule
        }
        
        return TaskSchedule(
            dateInfo: nextDateInfo,
            reminder: schedule.reminder,
            repeatRule: nextRepeatRule
        )
    }
    
    /// 当前重复任务完成后的快速添加任务
    var currentOccurrenceQuickAddTask: TodoQuickAddTask {
        let repeatTask = TodoQuickAddTask()
        repeatTask.isCompleted = true
        repeatTask.section = section
        repeatTask.name = name
        repeatTask.priority = priority
        
        // 启用并复制备注
        repeatTask.isNoteEnabled = true
        repeatTask.note = note
        
        // 复制日程信息（移除重复规则）
        var schedule = self.schedule
        schedule?.repeatRule = nil
        repeatTask.schedule = schedule
        
        // 处理进度（标记为完成）
        if var progress = self.progress {
            progress.complete()
            repeatTask.progress = progress
        }
        
        repeatTask.tags = tagsSet
        repeatTask.steps = steps
        
        return repeatTask
    }
    
    // MARK: - 初始化方法
    
    /// 从 Core Data 实体初始化
    init(content: CDTodoTask) {
        self.identifier = content.identifiableKey
        self.order = content.order
        self.isAddedToMyDay = content.isAddedToMyDay
        self.name = content.name
        self.note = content.note
        self.priority = content.priority
        self.section = content.sectionFeature
        self.isCompleted = content.isCompleted
        self.isRemoved = content.isRemoved
        self.creationDate = content.creationDate
        self.completionDate = content.completionDate
        self.modificationDate = content.modificationDate
        
        self.startDate = content.startDate
        self.dueDate = content.dueDate
        self.isAllDay = content.isAllDay
        self.reminderJSON = content.reminderJSON
        self.repeatRuleJSON = content.repeatRuleJSON
        self.progressJSON = content.progressJSON
        self.tags = content.userTags
        
        self.stepMarkdown = content.stepMarkdown
        self.stepCount = Int(content.stepCount)
        self.stepCompletedCount = Int(content.stepCompletedCount)
        self.isDetached = false
        
        super.init()
    }
    
    /// 从主任务创建分离的重复任务实例
    /// - Parameters:
    ///   - masterTask: 主任务对象
    ///   - occurrenceDate: 分离任务的发生日期
    init(masterTask: TodoTask, occurrenceDate: Date) {
        // 生成分离任务的标识符：格式为 "主任务ID/RID:yyyyMMdd"
        self.identifier = "\(masterTask.identifier)/RID:\(occurrenceDate.dayIntegerKey)"
        
        // 标记为已分离的任务
        self.isDetached = true
        
        // 复制基本信息
        self.order = masterTask.order
        self.isAddedToMyDay = masterTask.isAddedToMyDay
        self.name = masterTask.name
        self.note = masterTask.note
        self.priority = masterTask.priority
        self.section = masterTask.section
        self.isCompleted = masterTask.isCompleted
        self.isRemoved = masterTask.isRemoved
        self.creationDate = masterTask.creationDate
        self.completionDate = masterTask.completionDate
        self.modificationDate = masterTask.modificationDate
        
        self.reminderJSON = masterTask.reminderJSON
        self.repeatRuleJSON = masterTask.repeatRuleJSON
        self.progressJSON = masterTask.progressJSON
        self.tags = masterTask.tags
        self.stepMarkdown = masterTask.stepMarkdown
        self.stepCount = masterTask.stepCount
        self.stepCompletedCount = masterTask.stepCompletedCount
        
        /// 修改日期
        if let dateInfo = masterTask.schedule?.dateInfo {
            let dateEditor = TodoDateInfoEditor(dateInfo: dateInfo)
            dateEditor.setDate(occurrenceDate, editType: .start)
            self.startDate = dateEditor.dateInfo.startDate
            self.dueDate = dateEditor.dateInfo.endDate
            self.isAllDay = dateInfo.isAllDay
        }
        
        super.init()
        self.repeatRule = masterTask.repeatRule
    }
    
    // MARK: - 实例方法
    
    /// 重置任务到下一个重复周期
    /// - Parameter nextSchedule: 下一个日程安排（可选）
    func reset(with nextSchedule: TaskSchedule?) {
        self.schedule = nextSchedule
        self.isCompleted = false
        self.completionDate = nil
        
        // 重置进度
        self.progress?.resetCurrentValue()
        
        // 重置所有步骤状态
        if let steps = self.steps?.flatten() {
            steps.forEach { step in
                step.isCompleted = false
                step.isExpanded = true
            }
        }
        
        // 更新步骤计数
        self.stepCount = self.steps?.totalCount() ?? 0
        self.stepCompletedCount = self.steps?.completedCount() ?? 0
        self.modificationDate = .now
    }
    
    var hasReminder: Bool {
        return reminderJSON != nil
    }
    
    // MARK: - Hashable & Equatable
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoTask else { return false }
        if self === other { return true }
        
        return identifier == other.identifier &&
               modificationDate == other.modificationDate &&
               list == other.list &&
               tags == other.tags
    }
    
    // MARK: - ListDiffable
    
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? TodoTask else { return false }
        if self === other { return true }
        return self.identifier == other.identifier
    }
}
