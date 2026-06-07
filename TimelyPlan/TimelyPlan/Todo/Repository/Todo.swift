//
//  Todo.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

class Todo {
    
    /// 用户列表管理器
    private let userListManager = TodoUserListManager()
    
    /// 板块管理器
    private let sectionManager = TodoSectionManager()
    
    /// 标签管理器
    private let tagManager = TodoTagManager()
    
    /// 任务管理器
    private let taskManager = TodoTaskManager()
    
    /// 过滤器管理器
    private let filterManager = TodoFilterManager()
    
    /// 添加处理更新器
    func addUpdater(_ updater: AnyObject, for option: TodoUpdaterOption = .all) {
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

extension Todo {
   
    // MARK: - 获取列表
    func fetchTopLists(completion: @escaping([TodoList]?) -> Void) {
        return userListManager.fetchTopLists(completion: completion)
    }
    
    func getTopLists() -> [TodoList]? {
        return userListManager.getTopLists()
    }
    
    func getUserList(of identifier: String) -> TodoList? {
        return userListManager.getUserList(of: identifier)
    }
    
    func getUserLists(of identifiers: [String]) -> [TodoList]? {
        return userListManager.getUserLists(of: identifiers)
    }
    
    // MARK: - 列表处理
    
    /// 新建列表
    func createList(with editingList: TodoEditingList, parent: TodoList?) {
        userListManager.createList(with: editingList, parent: parent)
    }
    
    /// 更新列表信息
    func updateList(_ list: TodoList, with editingList: TodoEditingList, parent: TodoList?) {
        userListManager.updateList(list, with: editingList, parent: parent)
    }
    
    /// 更新列表布局
    func updateList(_ list: TodoList, layoutType: TodoListLayoutType) {
        userListManager.updateList(list, layoutType: layoutType)
    }
    
    /// 移动列表
    func moveList(_ list: TodoList, to parent: TodoList?) {
        userListManager.moveList(list, to: parent)
    }
    
    func reorderList(in lists: [TodoList], fromIndex: Int, toIndex: Int, depth: Int) {
        userListManager.reorderList(in: lists, fromIndex: fromIndex, toIndex: toIndex, depth: depth)
    }
    
    /// 解散列表
    func ungroupList(_ list: TodoList) {
        userListManager.ungroupList(list)
    }
    
    /// 删除列表
    func deleteList(_ list: TodoList) {
        if list.hasSubItem {
            return
        }
        
        taskManager.moveAllTasksToTrash(in: list)
        userListManager.deleteList(list)
    }
    
}

/// 任务相关
extension Todo {
    
    /// 搜索任务
    func searchTasks(matching searchText: String,
                     options: TodoSearchOptions,
                     completion: @escaping ([TodoTask]?) -> Void) {
        taskManager.searchTasks(matching: searchText, options: options, completion: completion)
    }
    
    /// 获取用户列表任务
    func fetchSmartListTasks(in list: TodoSmartList,
                            showCompleted: Bool = true,
                            completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchSmartListTasks(in: list, showCompleted: showCompleted, completion: completion)
    }
    
    
    /// 获取用户列表任务
    func fetchAllTasks(showCompleted: Bool = false,
                       completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchAllTasks(showCompleted: showCompleted, completion: completion)
    }
    
    /// 获取用户列表任务
    func fetchUserListTasks(in list: TodoList,
                            showCompleted: Bool = true,
                            completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchUserListTasks(in: list, showCompleted: showCompleted, completion: completion)
    }
    
    func fetchTasks(tag: TodoTag, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchTasks(tag: tag, showCompleted: showCompleted, completion: completion)
    }

    func fetchTasks(filter: TodoFilter, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchTasks(filter: filter, showCompleted: showCompleted, completion: completion)
    }
    
    func fetchTasks(filterRule: TodoFilterRule, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchTasks(filterRule: filterRule,
                               showCompleted: showCompleted,
                               completion: completion)
    }
    
    /// 获取计划任务
    func fetchScheduledTasks(in range: DateInterval, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchScheduledTasks(in: range, showCompleted: showCompleted, completion: completion)
    }
    
    func fetchUncompletedTaskCount(for item: IdentifiableItem, completion: @escaping(Int) -> Void) {
        taskManager.fetchUncompletedTaskCount(for: item, completion: completion)
    }
    
    /// 根据标识获取任务
    func getTask(with identifier: String) -> TodoTask? {
        return taskManager.getTask(with: identifier)
    }
    
    // MARK: - 任务处理
    /// 创建任务
    func createTask(with quickAddTask: TodoQuickAddTask) {
        taskManager.createTask(with: quickAddTask)
    }
    
    func moveTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {
        taskManager.moveTasks(tasks, to: section)
    }
    
    /// 将任务移动到废纸篓
    func moveTasksToTrash(_ tasks: [TodoTask]) {
        taskManager.moveTasksToTrash(tasks)
    }
        
    /// 恢复废纸篓中的任务
    func restoreTrashTask(_ task: TodoTask) {
        taskManager.restoreTrashTask(task)
    }
    
    func restoreTrashTasks(_ tasks: [TodoTask]) {
        taskManager.restoreTrashTasks(tasks)
    }
    
    /// 清空废纸篓
    func emptyTrash() {
        taskManager.emptyTrash()
    }
    
    func deleteTasks(_ tasks: [TodoTask]) {
        taskManager.deleteTasks(tasks)
    }
    
    func updateTask(_ task: TodoTask, progress: TodoEditProgress?) {
        return taskManager.updateTask(task, progress: progress)
    }
    
    func updateTask(_ task: TodoTask, name: String?) {
        taskManager.updateTask(task, name: name)
    }

    func updateTask(_ task: TodoTask, isAddedToMyDay: Bool) {
        taskManager.updateTasks([task], isAddedToMyDay: isAddedToMyDay)
    }
    
    func updateTasks(_ tasks: [TodoTask], isAddedToMyDay: Bool) {
        taskManager.updateTasks(tasks, isAddedToMyDay: isAddedToMyDay)
    }
    
    func updateTask(_ task: TodoTask, schedule: TaskSchedule?) {
        taskManager.updateTask(task, schedule: schedule)
    }
    
    func updateTask(_ task: TodoTask, tags: Set<TodoTag>?) {
        taskManager.updateTask(task, tags: tags)
    }
    
    func updateTask(_ task: TodoTask, note: String?) {
        taskManager.updateTask(task, note: note)
    }
    
    func updateTask(_ task: TodoTask, steps: [TodoStep]?) {
        taskManager.updateTask(task, steps: steps)
    }
    
    // MARK: - 批量更新
    /// 更新优先级
    func updateTasks(_ tasks: [TodoTask], priority: TodoTaskPriority) {
        taskManager.updateTasks(tasks, priority: priority)
    }
    
    /// 更新完成状态
    func updateTasks(_ tasks: [TodoTask], isCompleted: Bool) {
        taskManager.updateTasks(tasks, isCompleted: isCompleted)
    }
    
    /// 更新计划
    func updateTasks(_ tasks: [TodoTask], schedule: TaskSchedule?) {
        taskManager.updateTasks(tasks, schedule: schedule)
    }
    
    
    // MARK: - 根据 change 更新任务
    func updateTask(_ task: TodoTask, changes: [TodoTaskChange]) {
        taskManager.updateTask(task, changes: changes)
    }

    // MARK: - 排序任务
    func reorderTask(_ sourceTask: TodoTask,
                     postion: TodoTaskInsertPosition,
                     targetTask: TodoTask,
                     in list: TodoList?) {
        taskManager.reorderTask(sourceTask, postion: postion, targetTask: targetTask, in: list)
    }
    
    // MARK: - 导入任务
    func importTasks(_ tasks: [TodoImportTask], to list: TodoList?) {
        taskManager.importTasks(tasks, to: list)
    }
}

extension Todo {
    
    // MARK: - 获取标签
    func fetchTags(completion: @escaping([TodoTag]?) -> Void) {
        tagManager.fetchTags(completion: completion)
    }
    
    func getTags() -> [TodoTag] {
        return tagManager.getTags()
    }
    
    func getTag(with identifier: String) -> TodoTag? {
        return tagManager.getTag(with: identifier)
    }
    
    func getTags(of identifiers: [String]) -> [TodoTag]? {
        return tagManager.getTags(of: identifiers)
    }
    
    /// 判断标签名称是否已存在
    func isTagExist(with name: String) -> Bool {
        return tagManager.isTagExist(with: name)
    }
    
    /// 搜索标签
    func searchTags(containText text: String,
                     completion:(@escaping([TodoTag]?) -> Void)) {
        tagManager.fetchTags(containText: text, completion: completion)
    }
    
    // MARK: - 标签处理
    /// 新建标签
    func createTag(with editingTag: TodoEditingTag) {
        tagManager.createTag(with: editingTag)
    }
    
    /// 删除标签
    func deleteTag(_ tag: TodoTag) {
        tagManager.deleteTag(tag)
    }
    
    /// 更新标签信息
    func updateTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        tagManager.updateTag(tag, with: editingTag)
    }

    /// 重新排序标签
    func reorderTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        return tagManager.reorderTag(in: tags, fromIndex: fromIndex, toIndex: toIndex)
    }
}

extension Todo {
    
    func fetchFilters(completion: @escaping([TodoFilter]?) -> Void) {
        filterManager.fetchFilters(completion: completion)
    }
    
    func getFilter(of identifier: String) -> TodoFilter? {
        return filterManager.getFilter(of: identifier)
    }
    
    func getFilters() -> [TodoFilter]? {
        return filterManager.getFilters()
    }
    
    // MARK: - Processors
    /// 新建过滤器
    func createFilter(with editingFilter: TodoEditingFilter) {
        filterManager.createFilter(with: editingFilter)
    }
    
    /// 更新过滤器
    func updateFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {
        filterManager.updateFilter(filter, with: editingFilter)
    }
    
    /// 删除过滤器
    func deleteFilter(_ filter: TodoFilter) {
        filterManager.deleteFilter(filter)
    }

    /// 重新排序过滤器
    func reorderFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        filterManager.reorderFilter(in: filters, fromIndex: fromIndex, toIndex: toIndex)
    }
}

extension Todo {
    
    /// 获取统计条目
    func fetchStatsDataItem(in period: StatisticsPeriod,
                            completion:@escaping(TodoStatsDataItem) -> Void) {
        let dateRange = period.dateRange()
        taskManager.fetchCompletedTasks(in: dateRange) { tasks in
            let dataItem = TodoStatsDataItem(period: period, tasks: tasks)
            completion(dataItem)
        }
    }
}

// MARK: - 板块相关
extension Todo {
    
    func getSections(for list: TodoList?) -> [TodoSection]? {
        return sectionManager.getSections(for: list)
    }
    
    func createSection(with name: String, in list: TodoList?) {
        sectionManager.createSection(with: name, in: list)
    }
    
    func updateSection(_ section: TodoSection, with name: String) {
        sectionManager.updateSection(section, with: name)
    }
    
    func deleteSection(_ section: TodoSection) {
        sectionManager.deleteSection(section)
    }

    @discardableResult
    func reorderSection(in sections: [TodoSection],
                        of list: TodoList?,
                        from fromIndex: Int,
                        to toIndex: Int) -> Bool {
        return sectionManager.reorderSection(in: sections,
                                             of: list,
                                             from: fromIndex,
                                             to: toIndex)
    }
}
