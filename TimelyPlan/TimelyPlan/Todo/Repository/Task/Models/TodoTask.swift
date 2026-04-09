//
//  TodoTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/6.
//

import Foundation

class TodoTask: NSObject {

    /// 标识
    var identifier: String
    
    /// 排序因子
    var order: Int64 = 0
    
    /// 列表
    var list: TodoListFeature?
    
    /// 我的一天
    var isAddedToMyDay: Bool = false
    
    /// 名称
    var name: String?
    
    /// 备注
    var note: String?
    
    /// 优先级
    var priority: TodoTaskPriority = .none
    
    /// 标签
    var tags: Set<TodoTag>?
    
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
    private(set) lazy var progress: TodoEditProgress? = {
        if let json = progressJSON {
            return TodoEditProgress.model(with: json)
        }
        
        return nil
    }()
    
    /// 任务计划
    var schedule: TaskSchedule? {
        guard let dateInfo = dateInfo else {
            return nil
        }
        
        let schedule = TaskSchedule(dateInfo: dateInfo, reminder: reminder, repeatRule: repeatRule)
        return schedule
    }
    
    /// 日期信息
    private var dateInfo: TaskDateInfo?
    
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
    
    
    init(content: CDTodoTask) {
        self.identifier = content.identifiableKey
        self.order = content.order
        self.isAddedToMyDay = content.isAddedToMyDay
        self.name = content.name
        self.note = content.note
        self.priority = content.priority
        self.list = content.listFeature
        self.isCompleted = content.isCompleted
        self.isRemoved = content.isRemoved
        self.creationDate = content.creationDate
        self.completionDate = content.completionDate
        self.modificationDate = content.modificationDate
        
        self.dateInfo = content.dateInfo
        self.reminderJSON = content.reminderJSON
        self.repeatRuleJSON = content.repeatRuleJSON
        self.progressJSON = content.progressJSON
        
//        /// 标签
//        var tags: Set<TodoTag>?
        super.init()
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(modificationDate)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoTask else { return false }
        if self === other { return true }
        return identifier == other.identifier &&
                modificationDate == other.modificationDate
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return self.identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self.isEqual(object)
    }
}

