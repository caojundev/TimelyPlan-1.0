//
//  CDTodoTask+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/8.
//

import Foundation
import CoreData

/// 待办任务键值
struct TodoTaskKey {
    static var identifier = "identifier"
    static var list = "list"
    static var listIdentifier = "list.identifier"
    static var priority = "priorityRawValue"
    static var isAddedToMyDay = "isAddedToMyDay"
    static var tags = "tags"
    static var tagsIdentifier = "tags.identifier"
    
    static var order = "order"
    static var name = "name"
    static var note = "note"
    static var stepMarkdown = "stepMarkdown"
    static var isCompleted = "isCompleted"
    static var isRemoved = "isRemoved"
    static var creationDate = "creationDate"
    static var modificationDate = "modificationDate"
    static var completionDate = "completionDate"
    
    static var startDate = "startDate"
    static var dueDate = "dueDate"
    
    static var progressJSON = "progressJSON"
    static var progressFraction = "progressFraction"
}

extension CDTodoTask: SortableIdentifiable {
    
    /// 收件箱最小排序因子
    static var inboxMinOrder: Int64 {
        return minimumOrder(with: allInboxTaskPredicate)
    }
    
    /// 收件箱最大排序因子
    static var inboxMaxOrder: Int64 {
        return maximumOrder(with: allInboxTaskPredicate)
    }
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    /// 列表特征
    var listFeature: TodoListFeature? {
        return self.list?.feature
    }
    
    /// 用户标签
    var userTags: [TodoTag]? {
        guard let cdTags = self.tags as? Set<CDTodoTag> else {
            return nil
        }
        
        return cdTags.map { TodoTag(content: $0) }
    }
    
    var priority: TodoTaskPriority {
        get {
            return TodoTaskPriority(rawValue: Int(self.priorityRawValue)) ?? .none
        }
        
        set {
            self.priorityRawValue = Int16(newValue.rawValue)
        }
    }
    
    var dateInfo: TaskDateInfo? {
        get {
            guard let startDate = startDate, let endDate = dueDate else {
                return nil
            }
        
            return TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: isAllDay)
        }
        
        set {
            self.startDate = newValue?.startDate
            self.dueDate = newValue?.endDate
            self.isAllDay = newValue?.isAllDay ?? true
        }
    }
    
    func updateCompleted(_ isCompleted: Bool) {
        self.isCompleted = isCompleted
        self.completionDate = isCompleted ? .now : nil
    }
    
    /// 更新计划
    func updateSchedule(_ schedule: TaskSchedule?) {
        self.dateInfo = schedule?.dateInfo
        self.reminderJSON = schedule?.reminder?.jsonString()
        self.repeatRuleJSON = schedule?.repeatRule?.jsonString()
    }
    
    /// 更新进度
    func updateProgress(_ progress: TodoEditProgress?) {
        guard let progress = progress, progress.isValid else {
            self.progressFraction = 0.0
            self.progressJSON = nil
            return
        }

        self.progressFraction = progress.completionFraction
        self.progressJSON = progress.jsonString()
    }
    
    @discardableResult
    func updateSteps(_ steps: [TodoStep]?) -> Bool {
        let markdown = steps?.markdown()
        guard self.stepMarkdown != markdown else {
            return false
        }
        
        self.stepMarkdown = steps?.markdown()
        self.stepCount = Int64(steps?.totalCount() ?? 0)
        self.stepCompletedCount = Int64(steps?.completedCount() ?? 0)
        return true
    }
    
    static func createTodoTask(with quickAddTask: TodoQuickAddTask, onTop: Bool = false) -> CDTodoTask {
        let task = CDTodoTask.createEntity(in: .defaultContext)
        task.identifier = UUID().uuidString
        task.name = quickAddTask.name
        task.note = quickAddTask.isNoteEnabled ? quickAddTask.note : nil
        task.isAddedToMyDay = quickAddTask.isAddedToMyDay
        task.priority = quickAddTask.priority
        
        /// 标签
        if let tags = quickAddTask.tags, let cdTags = CDTodoTag.getTags(for: tags) {
            task.addToTags(Set(cdTags) as NSSet)
        }
    
        /// 更新计划
        if let schedule = quickAddTask.schedule {
            task.updateSchedule(schedule)
        }
        
        if let progress = quickAddTask.progress {
            task.updateProgress(progress)
        }

        if let steps = quickAddTask.steps {
            task.updateSteps(steps)
        }

        task.updateCompleted(quickAddTask.isCompleted)
        
        let currentDate: Date = .now
        task.creationDate = currentDate
        task.modificationDate = currentDate
        
        /// 添加到列表
        if let list = quickAddTask.list, let cdList = CDTodoList.getItem(with: list.identifier) {
            cdList.addTask(task, onTop: onTop)
        } else {
            /// 添加到收件箱
            if onTop {
                task.order = inboxMinOrder - kOrderedStep
            } else {
                task.order = inboxMaxOrder + kOrderedStep
            }
        }
        
        return task
    }
    
    /// 同步任务数据
    static func updateTodoTask(_ task: TodoTask) -> Bool {
        guard let cdTask = getItem(with: task.identifier) else {
            return false
        }

        cdTask.updateCompleted(task.isCompleted)
        cdTask.updateSchedule(task.schedule)
        cdTask.updateProgress(task.progress)
        cdTask.updateSteps(task.steps)
        cdTask.modificationDate = task.modificationDate
        return true
    }
    
    /// 更新优先级
    static func updateTasks(_ tasks: [TodoTask], priority: TodoTaskPriority) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask],
              cdTasks.count > 0 else {
            return false
        }
        
        let modificationDate = Date()
        for cdTask in cdTasks {
            cdTask.priority = priority
            cdTask.modificationDate = modificationDate
        }
        
        return true
    }
    
    static func updateTasks(_ tasks: [TodoTask], isCompleted: Bool) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask],
              cdTasks.count > 0 else {
            return false
        }
        
        let modificationDate = Date()
        for cdTask in cdTasks {
            cdTask.isCompleted = isCompleted
            cdTask.completionDate = isCompleted ? modificationDate: nil
            cdTask.modificationDate = modificationDate
        }
        
        return true
    }
    
    /// 更新任务进度
    static func updateTask(_ task: TodoTask, progress: TodoEditProgress?) -> Bool {
        guard let cdTask = getItem(with: task.identifier) else {
            return false
        }
        
        cdTask.updateProgress(progress)
        cdTask.modificationDate = .now
        return true
    }
    
    static func updateTask(_ task: TodoTask, name: String?) -> Bool {
        guard let cdTask = getItem(with: task.identifier) else {
            return false
        }
        
        cdTask.name = name
        cdTask.modificationDate = .now
        return true
    }
    
    static func updateTasks(_ tasks: [TodoTask], isAddedToMyDay: Bool) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask],
              cdTasks.count > 0 else {
            return false
        }
        
        let modificationDate = Date()
        for cdTask in cdTasks {
            cdTask.isAddedToMyDay = isAddedToMyDay
            cdTask.modificationDate = modificationDate
        }
        
        return true
    }
    
    static func updateTasks(_ tasks: [TodoTask], schedule: TaskSchedule?) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask],
              cdTasks.count > 0 else {
            return false
        }
        
        let modificationDate = Date()
        for cdTask in cdTasks {
            cdTask.updateSchedule(schedule)
            cdTask.modificationDate = modificationDate
        }
        
        return true
    }
    
    static func updateTask(_ task: TodoTask, tags: Set<TodoTag>?) -> Bool {
        let oldTags = Set(task.tags ?? [])
        if oldTags == tags {
            return false
        }
        
        guard let cdTask = getItem(with: task.identifier) else {
            return false
        }
        
        /// 删除标签
        var removeTags = oldTags
        if let tags = tags {
           removeTags = oldTags.subtracting(tags)
        }
        
        if removeTags.count > 0, let cdRemoveTags = CDTodoTag.getTags(for: removeTags) {
            cdTask.removeFromTags(Set(cdRemoveTags) as NSSet)
        }

        /// 添加标签
        let addTags = tags?.subtracting(oldTags)
        if let addTags = addTags, let cdAddTags = CDTodoTag.getTags(for: addTags) {
            cdTask.addToTags(Set(cdAddTags) as NSSet)
        }
        
        cdTask.modificationDate = .now
        return true
    }
    
    static func updateTask(_ task: TodoTask, note: String?) -> Bool {
        guard let cdTask = getItem(with: task.identifier) else {
            return false
        }
        
        cdTask.note = note
        cdTask.modificationDate = .now
        return true
    }
    
    static func updateTask(_ task: TodoTask, steps: [TodoStep]?) -> Bool {
        guard let cdTask = getItem(with: task.identifier) else {
            return false
        }
        
        if cdTask.updateSteps(steps) {
            cdTask.modificationDate = .now
            return true
        }
        
        return false
    }
    
    // MARK: - 根据 change 更新任务
    
    static func updateTask(_ task: TodoTask, changes: [TodoTaskChange]) -> [TodoTaskChange]? {
        var appliedChanges = Set<TodoTaskChange>()
        for change in changes {
            if updateTask(task, change: change) {
                appliedChanges.insert(change)
            }
        }
        
        guard appliedChanges.count > 0 else {
            return nil
        }
        
        return Array(appliedChanges)
    }

    private static func updateTask(_ task: TodoTask, change: TodoTaskChange) -> Bool {
        switch change {
        case .list(_, _):
            return updateTask(task, listChange: change)
        case .priority(_, _):
            return updateTask(task, priorityChange: change)
        case .schedule(_, _):
            return updateTask(task, scheduleChange: change)
        case .myDay(_, _):
            return updateTask(task, myDayChange: change)
        case .tag(_, _):
            return updateTask(task, tagChange: change)
        case .progress(_, _):
            return updateTask(task, progressChange: change)
        default:
            return false
        }
    }
    
    private static func updateTask(_ task: TodoTask, priorityChange: TodoTaskChange) -> Bool {
        guard case let .priority(oldValue, newValue) = priorityChange, oldValue != newValue else {
            return false
        }
        
        return updateTasks([task], priority: newValue)
    }
    
    private static func updateTask(_ task: TodoTask, scheduleChange: TodoTaskChange) -> Bool {
        guard case let .schedule(oldSchedule, newSchedule) = scheduleChange, oldSchedule != newSchedule else {
            return false
        }
        
        return updateTasks([task], schedule: newSchedule)
    }

    private static func updateTask(_ task: TodoTask, myDayChange: TodoTaskChange) -> Bool {
        guard case let .myDay(oldValue, newValue) = myDayChange, oldValue != newValue else {
            return false
        }
        
        return updateTasks([task], isAddedToMyDay: newValue)
    }

    private static func updateTask(_ task: TodoTask, progressChange: TodoTaskChange) -> Bool {
        guard case let .progress(oldProgress, newProgress) = progressChange, oldProgress != newProgress else {
            return false
        }
        
        return updateTask(task, progress: newProgress)
    }
    
    private static func updateTask(_ task: TodoTask, listChange: TodoTaskChange) -> Bool {
        guard case let .list(oldList, newList) = listChange, oldList != newList else {
            return false
        }
        
        return moveTasks([task], to: newList)
    }
    
    private static func updateTask(_ task: TodoTask, tagChange: TodoTaskChange) -> Bool {
        guard case let .tag(oldTags, newTags) = tagChange, oldTags != newTags else {
            return false
        }
        
        return updateTask(task, tags: newTags)
    }
    
    // MARK: - 排序任务
    static func reorderTask(_ sourceTask: TodoTask,
                            postion: TodoTaskInsertPosition,
                            targetTask: TodoTask,
                            in list: TodoList?) -> Bool {
        var tasks: [CDTodoTask]?
        if let list = list {
            /// 用户列表任务
            tasks = getUserListTasks(in: list)
        } else {
            /// 收件箱列表任务
            tasks = getInboxTasks()
        }
        
        guard var tasks = tasks, tasks.count > 0 else {
            return false
        }

        let sourceIndex = tasks.firstIndex { $0.identifier == sourceTask.identifier }
        guard let sourceIndex = sourceIndex else {
            return false
        }
        
        let moveTask = tasks.remove(at: sourceIndex)

        let targetIndex = tasks.firstIndex { $0.identifier == targetTask.identifier }
        guard let targetIndex = targetIndex else {
            return false
        }
        
        var insertIndex = targetIndex
        if postion == .after {
            insertIndex = targetIndex < tasks.count ? targetIndex + 1 : tasks.count
        }
        
        tasks.insert(moveTask, at: insertIndex)
        tasks.updateOrders()
        return true
    }
}

// MARK: - 处理任务
extension CDTodoTask {

    /// 移动任务到新列表
    static func moveTasks(_ tasks: [TodoTask], to list: TodoListRepresentable?) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask],
              cdTasks.count > 0 else {
            return false
        }
        
        var cdToList: CDTodoList? = nil
        if let toList = list {
            cdToList = CDTodoList.getItem(with: toList.identifier)
        }
        
        for cdTask in cdTasks {
            let cdFromList = cdTask.list
            if cdFromList == cdToList {
                continue
            }
            
            cdFromList?.removeFromTasks(cdTask)
            cdToList?.addTask(cdTask)
        }
        
        return true
    }
    
    /// 将任务移动到废纸篓
    static func moveTasksToTrash(_ tasks: [TodoTask]) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask], cdTasks.count > 0 else {
            return false
        }
        
        for cdTask in cdTasks {
            cdTask.isRemoved = true
        }
        
        return true
    }
        
    /// 恢复废纸篓中的任务
    static func restoreTrashTask(_ task: TodoTask) -> Bool  {
        return restoreTrashTasks([task])
    }
    
    static func restoreTrashTasks(_ tasks: [TodoTask]) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask], cdTasks.count > 0 else {
            return false
        }
        
        for cdTask in cdTasks {
            cdTask.isRemoved = false
        }
        
        return true
    }
    
    /// 清空废纸篓
    static func emptyTrash(completion: @escaping(Bool) -> Void) {
        fetchSmartListTasks(in: .trash, showCompleted: true) { tasks in
            guard let tasks = tasks, tasks.count > 0 else {
                completion(false)
                return
            }
            
            for task in tasks {
                task.list?.removeFromTasks(task)
            }
            
            NSManagedObjectContext.defaultContext.deleteObjects(tasks)
            completion(true)
        }
    }
    
    static func deleteTasks(_ tasks: [TodoTask]) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask], cdTasks.count > 0 else {
            return false
        }
        
        NSManagedObjectContext.defaultContext.deleteObjects(cdTasks)
        return true
    }
}


// MARK: - 获取任务
extension CDTodoTask {
    
    /// 搜索任务
    static func searchTasks(matching searchText: String,
                            options: TodoSearchOptions,
                            completion: @escaping ([CDTodoTask]?) -> Void) {
        let sortTerms: [SortTerm] = [(TodoTagKey.creationDate, false)]
    
        var predicates = [NSPredicate]()
        var andConditions = [notRemovedCondition]
        if !options.showCompleted {
            andConditions.append(notCompletedCondition)
        }

        predicates.append(andConditions.andPredicate())
        
        /// 文本匹配条件
        var textConditions: [PredicateCondition] = []
        let nameCondition: PredicateCondition = (TodoTaskKey.name, .contains(searchText))
        textConditions.append(nameCondition)
        
        if options.searchStep {
            let stepCondition: PredicateCondition = (TodoTaskKey.stepMarkdown, .contains(searchText))
            textConditions.append(stepCondition)
        }
        
        if options.searchNote {
            let noteCondition: PredicateCondition = (TodoTaskKey.note, .contains(searchText))
            textConditions.append(noteCondition)
        }
        
        predicates.append(textConditions.orPredicate())
        
        /// 过滤
        if let filterPredicate = options.filterRule?.predicate {
            predicates.append(filterPredicate)
        }
        
        let searchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchAll(matching: searchPredicate, sortTerms: sortTerms) { results in
            completion(results as? [CDTodoTask])
        }
    }
    
    /// 同步获取收件箱任务
    static func getInboxTasks(showCompleted: Bool = true) -> [CDTodoTask]? {
        let predicate = activeInboxTaskPredicate(showCompleted: showCompleted)
        let results: [CDTodoTask]? = findAll(with: predicate, sortedBy: TodoTaskKey.order, ascending: true, in: .defaultContext)
        return results
    }
    
    /// 获取智能清单任务
    static func fetchSmartListTasks(in list: TodoSmartList,
                                    showCompleted: Bool = true,
                                    completion: @escaping([CDTodoTask]?) -> Void) {
        let predicate = smartListTaskPredicate(in: list, showCompleted: showCompleted)
        findAll(with: predicate, sortedBy: TodoTaskKey.creationDate, ascending: true) { results in
            completion(results as? [CDTodoTask])
        }
    }
    
    /// 获取用户列表任务
    static func fetchUserListTasks(in list: TodoList,
                                   showCompleted: Bool = true,
                                   completion: @escaping([CDTodoTask]?) -> Void) {
        let predicate = userListActiveTaskPredicate(for: list, showCompleted: showCompleted)
        findAll(with: predicate, sortedBy: TodoTaskKey.creationDate, ascending: true) { results in
            completion(results as? [CDTodoTask])
        }
    }
    
    static func getUserListTasks(in list: TodoList, showCompleted: Bool = true) -> [CDTodoTask]? {
        let predicate = userListActiveTaskPredicate(for: list, showCompleted: showCompleted)
        let results: [CDTodoTask]? = findAll(with: predicate, sortedBy: TodoTaskKey.order, ascending: true, in: .defaultContext)
        return results
    }
    
    static func fetchTasks(tag: TodoTag, showCompleted: Bool, completion: @escaping([CDTodoTask]?) -> Void) {
        let predicate = tagActiveTaskPredicate(for: tag, showCompleted: showCompleted)
        findAll(with: predicate) { results in
            completion(results as? [CDTodoTask])
        }
    }
    
    static func fetchTasks(filter: TodoFilter,
                           showCompleted: Bool,
                           completion: @escaping([CDTodoTask]?) -> Void) {
        guard let filterRule = filter.rule else {
            completion(nil)
            return
        }
        
        fetchTasks(filterRule: filterRule, showCompleted: showCompleted, completion: completion)
    }
    
    static func fetchTasks(filterRule: TodoFilterRule,
                           showCompleted: Bool,
                           completion: @escaping([CDTodoTask]?) -> Void) {
        guard let predicate = filterActiveTaskPredicate(for: filterRule, showCompleted: showCompleted) else {
            completion(nil)
            return
        }
        
        findAll(with: predicate) { results in
            completion(results as? [CDTodoTask])
        }
    }
    
    static func fetchScheduledTasks(in range: DateInterval,
                                    showCompleted: Bool = true,
                                    completion: @escaping([CDTodoTask]?) -> Void) {
        let predicate = activeScheduledTaskPredicate(in: range, showCompleted: showCompleted)
        findAll(with: predicate, sortedBy: TodoTaskKey.startDate, ascending: true) { results in
            completion(results as? [CDTodoTask])
        }
    }
   
    /// 获取特定范围已完成任务
    static func fetchCompletedTasks(in range: DateInterval,
                                    completion: @escaping([CDTodoTask]?) -> Void) {
        let conditions: [PredicateCondition] = [
            completedCondition,
            notRemovedCondition,
            (TodoTaskKey.completionDate, .between(range.start, range.end))
        ]
        
        let predicate = conditions.andPredicate()
        findAll(with: predicate) { results in
            completion(results as? [CDTodoTask])
        }
    }
    
    
    static func fetchUncompletedTaskCount(for item: IdentifiableItem, completion: @escaping(Int) -> Void) {
        var predicate: NSPredicate?
        switch item {
        case let list as TodoList:
            predicate = userListActiveTaskPredicate(for: list, showCompleted: false)
        case let tag as TodoTag:
            predicate = tagActiveTaskPredicate(for: tag, showCompleted: false)
        case let smartList as TodoSmartList:
            predicate = smartListTaskPredicate(in: smartList, showCompleted: false)
        case let filter as TodoFilter:
            predicate = filterActiveTaskPredicate(for: filter, showCompleted: false)
        default:
            break
        }
        
        if let predicate = predicate {
            fetchCount(withPredicate: predicate) { count in
                DispatchQueue.main.async {
                    completion(count)
                }
            }
        } else {
            completion(0)
        }
    }
}

// MARK: - 谓词
extension CDTodoTask {

    // MARK: - 过滤器
    static func filterActiveTaskPredicate(for filter: TodoFilter,
                                          showCompleted: Bool = true) -> NSPredicate? {
        return filterActiveTaskPredicate(for: filter.rule, showCompleted: showCompleted)
    }
    
    static func filterActiveTaskPredicate(for filterRule: TodoFilterRule?,
                                          showCompleted: Bool = true) -> NSPredicate? {
        guard let rulePredicate = filterRule?.predicate else {
            return nil
        }
        
        var conditions: [PredicateCondition] = [
            notRemovedCondition
        ]
        
        if !showCompleted {
            conditions.append(notCompletedCondition)
        }
        
        let statusPredicate = conditions.andPredicate()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [statusPredicate, rulePredicate])
        return predicate
    }

    // MARK: - 标签
    /// 标签活动任务
    static func tagActiveTaskPredicate(for tag: TodoTag, showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            notRemovedCondition,
            (TodoTaskKey.tagsIdentifier, .anyEqual(tag.identifier))
        ]
        
        if !showCompleted {
            conditions.append(notCompletedCondition)
        }
        
        return conditions.andPredicate()
    }
    
    // MARK: - 用户清单任务
    /// 用户清单活动任务
    static func userListActiveTaskPredicate(for list: TodoList,
                                             showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            (TodoTaskKey.listIdentifier, .equal(list.identifier)),
            notRemovedCondition
        ]
        
        if !showCompleted {
            conditions.append(notCompletedCondition)
        }
        
        return conditions.andPredicate()
    }
    
    // MARK: - 谓词
    static func smartListTaskPredicate(in list: TodoSmartList,
                                       showCompleted: Bool = false) -> NSPredicate {
        var predicate: NSPredicate
        switch list.listType {
        case .myDay:
            predicate = activeMyDayTaskPredicate(showCompleted: showCompleted)
        case .inbox:
            predicate = activeInboxTaskPredicate(showCompleted: showCompleted)
        case .completed:
            predicate = activeCompletedTaskPredicate()
        case .overdue:
            predicate = activeOverdueTaskPredicate()
        case .today:
            predicate = activeTodayTaskPredicate(showCompleted: showCompleted)
        case .tomorrow:
            predicate = activeTomorrowTaskPredicate(showCompleted: showCompleted)
        case .upcoming:
            predicate = activeUpcomingTaskPredicate(showCompleted: showCompleted)
        case .trash:
            predicate = trashTaskPredicate()
        }
        
        return predicate
    }
    
    /// 所有收件箱任务
    static var allInboxTaskPredicate: NSPredicate {
        let condition: PredicateCondition = (TodoTaskKey.list, .isEmpty)
        return NSPredicate.predicate(with: condition)
    }
    
    /// 我的一天活动任务
    static func activeMyDayTaskPredicate(showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            (TodoTaskKey.isAddedToMyDay, .isTrue),
            notRemovedCondition
        ]
        
        if !showCompleted {
            conditions.append(notCompletedCondition)
        }
        
        return conditions.andPredicate()
    }
    
    /// 收件箱活动任务
    static func activeInboxTaskPredicate(showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            (TodoTaskKey.list, .isEmpty),
            notRemovedCondition
        ]
        
        if !showCompleted {
            conditions.append(notCompletedCondition)
        }
        
        return conditions.andPredicate()
    }
    
    /// 已完成
    static func activeCompletedTaskPredicate() -> NSPredicate {
        let conditions: [PredicateCondition] = [
            completedCondition,
            notRemovedCondition
        ]
        
        return conditions.andPredicate()
    }
    
    // 废纸篓
    static func trashTaskPredicate() -> NSPredicate {
        let conditions: [PredicateCondition] = [
            (TodoTaskKey.isRemoved, .isTrue)
        ]
        
        return conditions.andPredicate()
    }
    
    /// 过期
    static func activeOverdueTaskPredicate() -> NSPredicate {
        var conditions = scheduledConditions(showCompleted: false)
        let overdueCondition: PredicateCondition = (TodoTaskKey.dueDate, .lessThan(Date()))
        conditions.append(overdueCondition)
        return conditions.andPredicate()
    }

    /// 今日
    static func activeTodayTaskPredicate(showCompleted: Bool = true) -> NSPredicate {
        let date = Date()
        return activeScheduledTaskPredicate(on: date, showCompleted: showCompleted)
    }
    
    /// 明日
    static func activeTomorrowTaskPredicate(showCompleted: Bool = true) -> NSPredicate {
        let date = Date().dateByAddingDays(1)!
        return activeScheduledTaskPredicate(on: date, showCompleted: showCompleted)
    }
    
    /// 接下来（从后天开始）
    static func activeUpcomingTaskPredicate(showCompleted: Bool = false) -> NSPredicate {
        var conditions = scheduledConditions(showCompleted: showCompleted)
        let date = Date().dateByAddingDays(1)!.endOfDay() /// 明天结束
        let upcomingCondition: PredicateCondition = (TodoTaskKey.startDate, .greaterThan(date))
        conditions.append(upcomingCondition)
        return conditions.andPredicate()
    }
    
    static func activeScheduledTaskPredicate(on date: Date,
                                             showCompleted: Bool = true) -> NSPredicate {
        let range = DateInterval.rangeOfDay(date)
        return activeScheduledTaskPredicate(in: range, showCompleted: showCompleted)
    }
    
    static func activeScheduledTaskPredicate(in range: DateInterval,
                                             showCompleted: Bool = true) -> NSPredicate {
        let scheduledConditions = scheduledConditions(showCompleted: showCompleted)
        let scheduledPredicate = scheduledConditions.andPredicate()
        let format = "!((\(TodoTaskKey.dueDate) < %@) AND (\(TodoTaskKey.startDate) < %@))"
        let start = range.start as NSDate
        let end = range.end as NSDate
        let dateRangePredicate = NSPredicate(format: format, start, end)
        let predicates = [scheduledPredicate, dateRangePredicate]
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    // MARK: - Conditions
    static func scheduledConditions(showCompleted: Bool = true) -> [PredicateCondition] {
        var conditions: [PredicateCondition] = [
            notRemovedCondition,
            (TodoTaskKey.dueDate, .isNotEmpty)
        ]
        
        if !showCompleted {
            conditions.append(notCompletedCondition)
        }
        
        return conditions
    }
    
    static var notRemovedCondition: PredicateCondition {
        return (TodoTaskKey.isRemoved, .isFalse)
    }
    
    static var completedCondition: PredicateCondition {
        return (TodoTaskKey.isCompleted, .isTrue)
    }
    
    static var notCompletedCondition: PredicateCondition {
        return (TodoTaskKey.isCompleted, .isFalse)
    }
    
    
}

extension Array where Element == CDTodoTask {
    
    var tasks: [TodoTask] {
        self.map{ TodoTask(content: $0) }
    }
}
