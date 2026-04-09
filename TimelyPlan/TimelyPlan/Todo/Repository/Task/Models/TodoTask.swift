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
    
    /// 我的一天
    var isAddedToMyDay: Bool = false
    
    /// 名称
    var name: String?
    
    /// 备注
    var note: String?
    
    /// 优先级
    var priority: TodoTaskPriority = .none
    
    /// 列表
    var list: TodoListFeature?
    
    /// 计划
    var schedule: TaskSchedule?

    /// 进度
    var progress: TodoEditProgress?
    
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
        
//        /// 计划
//        var schedule: TaskSchedule?
//
//        /// 进度
//        var progress: TodoEditProgress?
//
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

