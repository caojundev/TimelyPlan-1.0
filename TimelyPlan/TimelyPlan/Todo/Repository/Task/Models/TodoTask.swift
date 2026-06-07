//
//  TodoTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/6.
//

import Foundation

@objcMembers class TodoTask: NSObject {

    /// 标识
    var identifier: String
    
    /// 排序因子
    var order: Int64 = 0
    
    /// 列表
    var list: TodoListFeature? {
        return section.list
    }
    
    /// 板块
    var section: TodoSectionFeature
    
    /// 我的一天
    var isAddedToMyDay: Bool = false
    
    /// 名称
    var name: String?
    
    /// 备注
    var note: String?
    
    /// 优先级
    var priority: TodoTaskPriority = .none
    
    /// 标签
    var tags: [TodoTag]?
    
    /// 创建日期
    var creationDate: Date?
    
    /// 完成日期
    var completionDate: Date?
    
    /// 修改日期
    var modificationDate: Date?
    
    /// 是否完成
    var isCompleted: Bool = false
    
    /// 是否已移动到废纸篓
    var isRemoved: Bool = false
    
    /// 进度
    lazy var progress: TodoEditProgress? = {
        if let json = progressJSON {
            return TodoEditProgress.model(with: json)
        }
        
        return nil
    }()
    
    /// 任务计划
    var schedule: TaskSchedule? {
        get {
            guard let startDate = startDate, let endDate = dueDate else {
                return nil
            }

            let dateInfo = TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: isAllDay)
            let schedule = TaskSchedule(dateInfo: dateInfo, reminder: reminder, repeatRule: repeatRule)
            return schedule
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

    private(set) var startDate: Date?
    private(set) var dueDate: Date?
    private(set) var isAllDay: Bool = true
    
    /// 任务提醒
    private lazy var reminder: TaskReminder? = {
        if let json = reminderJSON {
            return TaskReminder.model(with: json)
        }
        
        return nil
    }()

    /// 重复规则
    private lazy var repeatRule: RepeatRule? = {
        if let json = repeatRuleJSON {
            return RepeatRule.model(with: json)
        }
        
        return nil
    }()
    
    /// 提醒 JSON 字符串
    private let reminderJSON: String?
    
    /// 重复规则 JSON 字符串
    private let repeatRuleJSON: String?
    
    /// 进度 JSON 字符串
    private let progressJSON: String?

    private(set) var stepCount: Int = 0
    
    private(set) var stepCompletedCount: Int = 0
    
    private var stepMarkdown: String?
    
    /// 步骤
    private(set) lazy var steps: [TodoStep]? = {
        if let markdown = stepMarkdown {
            let parser = TodoStepParser()
            return parser.parse(markdown)
        }
        
        return nil
    }()
    
    // MARK: - 只读
    var tagsSet: Set<TodoTag>? {
        if let tags = tags, tags.count > 0 {
            return Set(tags)
        }
        
        return nil
    }
    
    var nextSchedule: TaskSchedule? {
        guard let schedule = schedule,
              let dateInfo = schedule.dateInfo,
              let repeatRule = schedule.repeatRule else {
            return nil
        }
        
        let repeatScheduler = RepeatScheduler()
        guard let nextRepeatDate = repeatScheduler.nextRepeatDate(completionDate: dateInfo.startDate,
                                                                  matching: repeatRule,
                                                                  startDate: dateInfo.startDate) else {
            return nil
        }
        
        /// 更新任务为下一重复周期数据
        let startDate = nextRepeatDate
        let endDate = nextRepeatDate.dateByAddingSeconds(dateInfo.duration)!
        let nextDateInfo = TaskDateInfo(startDate: startDate,
                                        endDate: endDate,
                                        isAllDay: dateInfo.isAllDay)
        
        var nextRepeatRule: RepeatRule?
        if let repeatRule = repeatRule.copy() as? RepeatRule {
            let count = repeatRule.count ?? 0
            repeatRule.count = count + 1 /// 重复次数加一
            nextRepeatRule = repeatRule
        }
        
        return TaskSchedule(dateInfo: nextDateInfo,
                            reminder: schedule.reminder,
                            repeatRule: nextRepeatRule)
    }

    var currentOccurrenceQuickAddTask: TodoQuickAddTask {
        let repeatTask = TodoQuickAddTask()
        repeatTask.isCompleted = true
        repeatTask.section = section
        repeatTask.name = name
        repeatTask.priority = priority
        
        repeatTask.isNoteEnabled = true /// 开启备注
        repeatTask.note = note
        
        /// 计划
        var schedule = schedule
        schedule?.repeatRule = nil
        repeatTask.schedule = schedule
        
        if var progress = progress {
            // 完成进度
            progress.complete()
            repeatTask.progress = progress
        }
        
        repeatTask.tags = tagsSet
        repeatTask.steps = steps
        return repeatTask
    }
    
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
        super.init()
    }
    
    func reset(with nextSchedule: TaskSchedule?) {
        self.schedule = nextSchedule
        self.isCompleted = false
        self.completionDate = nil
        
        /// 重置进度
        self.progress?.resetCurrentValue()
        
        /// 重置步骤状态
        if let steps = self.steps?.flatten() {
            steps.forEach { step in
                step.isCompleted = false
                step.isExpanded = true
            }
        }
        
        /// 重置步骤数目信息
        self.stepCount = self.steps?.totalCount() ?? 0
        self.stepCompletedCount = self.steps?.completedCount() ?? 0
        self.modificationDate = .now
    }
    
    // MARK: - 等同性判断
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
        return self.identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? TodoTask else { return false }
        if self === other { return true }
        return self.identifier == other.identifier
    }
}
