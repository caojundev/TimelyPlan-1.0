//
//  TodoRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

class TodoRepository {
    
    // MARK: - 单例
    static let shared = TodoRepository()
    
    private init() {}
    
    // MARK: - 私有管理器
    /// 用户列表管理器
    private static let userListManager = TodoUserListManager()
    
    /// 板块管理器
    private static let sectionManager = TodoSectionManager()
    
    /// 标签管理器
    private static let tagManager = TodoTagManager()
    
    /// 任务管理器
    private static let taskManager = TodoTaskManager()
    
    /// 过滤器管理器
    private static let filterManager = TodoFilterManager()
    
    /// 添加处理更新器
    static func addUpdater(_ updater: AnyObject, for option: TodoUpdaterOption = .all) {
        if option.contains(.list) {
            userListManager.updater.addDelegate(updater)
        }
        
        if option.contains(.section) {
            sectionManager.updater.addDelegate(updater)
        }
        
        if option.contains(.tag) {
            tagManager.updater.addDelegate(updater)
        }
        
        if option.contains(.task) {
            taskManager.updater.addDelegate(updater)
        }
        
        if option.contains(.filter) {
            filterManager.updater.addDelegate(updater)
        }
    }
}

// MARK: - 列表相关
extension TodoRepository {
   
    /// 获取列表
    static func fetchTopLists(completion: @escaping([TodoList]?) -> Void) {
        return userListManager.fetchTopLists(completion: completion)
    }
    
    static func getTopLists() -> [TodoList]? {
        return userListManager.getTopLists()
    }
    
    static func getUserList(of identifier: String) -> TodoList? {
        return userListManager.getUserList(of: identifier)
    }
    
    static func getUserLists(of identifiers: [String]) -> [TodoList]? {
        return userListManager.getUserLists(of: identifiers)
    }
    
    // MARK: - 列表处理
    /// 新建列表
    static func createList(with editingList: TodoEditingList, parent: TodoList?) {
        userListManager.createList(with: editingList, parent: parent)
    }
    
    /// 更新列表信息
    static func updateList(_ list: TodoList, with editingList: TodoEditingList, parent: TodoList?) {
        userListManager.updateList(list, with: editingList, parent: parent)
    }
    
    /// 更新列表布局
    static func updateList(_ list: TodoList, layoutType: TodoListLayoutType) {
        userListManager.updateList(list, layoutType: layoutType)
    }
    
    /// 移动列表
    static func moveList(_ list: TodoList, to parent: TodoList?) {
        userListManager.moveList(list, to: parent)
    }
    
    static func reorderList(in lists: [TodoList], fromIndex: Int, toIndex: Int, depth: Int) {
        userListManager.reorderList(in: lists, fromIndex: fromIndex, toIndex: toIndex, depth: depth)
    }
    
    /// 解散列表
    static func ungroupList(_ list: TodoList) {
        userListManager.ungroupList(list)
    }
    
    /// 删除列表
    static func deleteList(_ list: TodoList) {
        if list.hasSubItem {
            return
        }
        
        taskManager.moveAllTasksToTrash(in: list)
        userListManager.deleteList(list)
    }
}

// MARK: - 任务相关
extension TodoRepository {
    
    /// 搜索任务
    static func searchTasks(matching searchText: String,
                     options: TodoSearchOptions,
                     completion: @escaping ([TodoTask]?) -> Void) {
        taskManager.searchTasks(matching: searchText, options: options, completion: completion)
    }
    
    /// 获取智能列表任务
    static func fetchSmartListTasks(in list: TodoSmartList,
                            showCompleted: Bool = true,
                            completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchSmartListTasks(in: list, showCompleted: showCompleted, completion: completion)
    }
    
    /// 获取所有任务
    static func fetchAllTasks(showCompleted: Bool = false,
                       completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchAllTasks(showCompleted: showCompleted, completion: completion)
    }
    
    /// 获取用户列表任务
    static func fetchUserListTasks(in list: TodoList,
                            showCompleted: Bool = true,
                            completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchUserListTasks(in: list, showCompleted: showCompleted, completion: completion)
    }
    
    static func fetchTasks(tag: TodoTag, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchTasks(tag: tag, showCompleted: showCompleted, completion: completion)
    }

    static func fetchTasks(filter: TodoFilter, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchTasks(filter: filter, showCompleted: showCompleted, completion: completion)
    }
    
    static func fetchTasks(filterRule: TodoFilterRule, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchTasks(filterRule: filterRule,
                               showCompleted: showCompleted,
                               completion: completion)
    }
    
    static func fetchUncompletedTaskCount(for item: IdentifiableItem, completion: @escaping(Int) -> Void) {
        taskManager.fetchUncompletedTaskCount(for: item, completion: completion)
    }
    
    /// 根据标识获取任务
    static func getTask(with identifier: String) -> TodoTask? {
        return taskManager.getTask(with: identifier)
    }
    
    /// 获取计划任务
    static func fetchEventTasks(in range: DateInterval, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchEventTasks(in: range, showCompleted: showCompleted, completion: completion)
    }

    // MARK: - 任务处理
    /// 创建任务
    static func createTask(with quickAddTask: TodoQuickAddTask) {
        taskManager.createTask(with: quickAddTask)
    }
    
    static func moveTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {
        taskManager.moveTasks(tasks, to: section)
    }
    
    /// 将任务移动到废纸篓
    static func moveTasksToTrash(_ tasks: [TodoTask]) {
        taskManager.moveTasksToTrash(tasks)
    }
        
    /// 恢复废纸篓中的任务
    static func restoreTrashTask(_ task: TodoTask) {
        taskManager.restoreTrashTask(task)
    }
    
    static func restoreTrashTasks(_ tasks: [TodoTask]) {
        taskManager.restoreTrashTasks(tasks)
    }
    
    /// 清空废纸篓
    static func emptyTrash() {
        taskManager.emptyTrash()
    }
    
    static func deleteTasks(_ tasks: [TodoTask]) {
        taskManager.deleteTasks(tasks)
    }
    
    static func updateTask(_ task: TodoTask, progress: TodoEditProgress?) {
        return taskManager.updateTask(task, progress: progress)
    }
    
    static func updateTask(_ task: TodoTask, name: String?) {
        taskManager.updateTask(task, name: name)
    }

    static func updateTask(_ task: TodoTask, isAddedToMyDay: Bool) {
        taskManager.updateTasks([task], isAddedToMyDay: isAddedToMyDay)
    }
    
    static func updateTasks(_ tasks: [TodoTask], isAddedToMyDay: Bool) {
        taskManager.updateTasks(tasks, isAddedToMyDay: isAddedToMyDay)
    }
    
    static func updateTask(_ task: TodoTask, schedule: TaskSchedule?) {
        taskManager.updateTask(task, schedule: schedule)
    }
    
    static func updateTask(_ task: TodoTask, tags: Set<TodoTag>?) {
        taskManager.updateTask(task, tags: tags)
    }
    
    static func updateTask(_ task: TodoTask, note: String?) {
        taskManager.updateTask(task, note: note)
    }
    
    static func updateTask(_ task: TodoTask, steps: [TodoStep]?) {
        taskManager.updateTask(task, steps: steps)
    }
    
    // MARK: - 批量更新
    /// 更新优先级
    static func updateTasks(_ tasks: [TodoTask], priority: TodoTaskPriority) {
        taskManager.updateTasks(tasks, priority: priority)
    }
    
    /// 更新完成状态
    static func updateTasks(_ tasks: [TodoTask], isCompleted: Bool) {
        taskManager.updateTasks(tasks, isCompleted: isCompleted)
    }
    
    /// 更新计划
    static func updateTasks(_ tasks: [TodoTask], schedule: TaskSchedule?) {
        taskManager.updateTasks(tasks, schedule: schedule)
    }
    
    // MARK: - 根据 change 更新任务
    static func updateTask(_ task: TodoTask, changes: [TodoTaskChange]) {
        taskManager.updateTask(task, changes: changes)
    }

    // MARK: - 排序任务
    static func reorderTask(_ sourceTask: TodoTask,
                     postion: TodoTaskInsertPosition,
                     targetTask: TodoTask,
                     in list: TodoList?) {
        taskManager.reorderTask(sourceTask, postion: postion, targetTask: targetTask, in: list)
    }
    
    // MARK: - 导入任务
    static func importTasks(_ tasks: [TodoImportTask], to list: TodoList?) {
        taskManager.importTasks(tasks, to: list)
    }
}

// MARK: - 标签相关
extension TodoRepository {
    
    /// 获取标签
    static func fetchTags(completion: @escaping([TodoTag]?) -> Void) {
        tagManager.fetchTags(completion: completion)
    }
    
    static func getTags() -> [TodoTag] {
        return tagManager.getTags()
    }
    
    static func getTag(with identifier: String) -> TodoTag? {
        return tagManager.getTag(with: identifier)
    }
    
    static func getTags(of identifiers: [String]) -> [TodoTag]? {
        return tagManager.getTags(of: identifiers)
    }
    
    /// 判断标签名称是否已存在
    static func isTagExist(with name: String) -> Bool {
        return tagManager.isTagExist(with: name)
    }
    
    /// 搜索标签
    static func searchTags(containText text: String,
                     completion:(@escaping([TodoTag]?) -> Void)) {
        tagManager.fetchTags(containText: text, completion: completion)
    }
    
    // MARK: - 标签处理
    /// 新建标签
    static func createTag(with editingTag: TodoEditingTag) {
        tagManager.createTag(with: editingTag)
    }
    
    /// 删除标签
    static func deleteTag(_ tag: TodoTag) {
        tagManager.deleteTag(tag)
    }
    
    /// 更新标签信息
    static func updateTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        tagManager.updateTag(tag, with: editingTag)
    }

    /// 重新排序标签
    static func reorderTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        return tagManager.reorderTag(in: tags, fromIndex: fromIndex, toIndex: toIndex)
    }
}

// MARK: - 过滤器相关
extension TodoRepository {
    
    static func fetchFilters(completion: @escaping([TodoFilter]?) -> Void) {
        filterManager.fetchFilters(completion: completion)
    }
    
    static func getFilter(of identifier: String) -> TodoFilter? {
        return filterManager.getFilter(of: identifier)
    }
    
    static func getFilters() -> [TodoFilter]? {
        return filterManager.getFilters()
    }
    
    // MARK: - 过滤器处理
    /// 新建过滤器
    static func createFilter(with editingFilter: TodoEditingFilter) {
        filterManager.createFilter(with: editingFilter)
    }
    
    /// 更新过滤器
    static func updateFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {
        filterManager.updateFilter(filter, with: editingFilter)
    }
    
    /// 删除过滤器
    static func deleteFilter(_ filter: TodoFilter) {
        filterManager.deleteFilter(filter)
    }

    /// 重新排序过滤器
    static func reorderFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        filterManager.reorderFilter(in: filters, fromIndex: fromIndex, toIndex: toIndex)
    }
}

// MARK: - 统计相关
extension TodoRepository {
    
    /// 获取统计条目
    static func fetchStatsDataItem(in period: StatisticsPeriod,
                            completion:@escaping(TodoStatsDataItem) -> Void) {
        let dateRange = period.dateRange()
        taskManager.fetchCompletedTasks(in: dateRange) { tasks in
            let dataItem = TodoStatsDataItem(period: period, tasks: tasks)
            completion(dataItem)
        }
    }
}

// MARK: - 板块相关
extension TodoRepository {
    
    static func getSections(for list: TodoList?) -> [TodoSection]? {
        return sectionManager.getSections(for: list)
    }
    
    static func createSection(with name: String, in list: TodoList?) {
        sectionManager.createSection(with: name, in: list)
    }
    
    static func updateSection(_ section: TodoSection, with name: String) {
        sectionManager.updateSection(section, with: name)
    }
    
    static func deleteSection(_ section: TodoSection) {
        sectionManager.deleteSection(section)
    }

    @discardableResult
    static func reorderSection(in sections: [TodoSection],
                        of list: TodoList?,
                        from fromIndex: Int,
                        to toIndex: Int) -> Bool {
        return sectionManager.reorderSection(in: sections,
                                             of: list,
                                             from: fromIndex,
                                             to: toIndex)
    }
}
