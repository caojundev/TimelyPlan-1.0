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
    
    /// 标签管理器
    private let tagManager = TodoTagManager()
    
    /// 任务管理器
    private let taskManager = TodoTaskManager()
    
    /// 添加处理更新器
    func addUpdater(_ updater: AnyObject, for option: TodoUpdaterOption = .all) {
        if option.contains(.list) {
            userListManager.updater.addDelegate(updater)
        }
        
        if option.contains(.tag) {
            tagManager.updater.addDelegate(updater)
        }
        
        if option.contains(.task) {
            taskManager.updater.addDelegate(updater)
        }
    }
    

    // MARK: - 获取标签
    func fetchTags(completion: @escaping([TodoTag]?) -> Void) {
        tagManager.fetchTags(completion: completion)
    }
    
    func getTags() -> [TodoTag] {
        return tagManager.getTags()
    }
    
    func getTag(of identifier: String) -> TodoTag? {
        return tagManager.getTag(of: identifier)
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
    
    /// 获取用户列表任务
    func fetchSmartListTasks(in list: TodoSmartList,
                            showCompleted: Bool = true,
                            completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchSmartListTasks(in: list, showCompleted: showCompleted, completion: completion)
    }
    
    /// 获取用户列表任务
    func fetchUserListTasks(in list: TodoList,
                            showCompleted: Bool = true,
                            completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchUserListTasks(in: list, showCompleted: showCompleted, completion: completion)
    }
    
    func fetchTasks(for tag: TodoTag, completion: @escaping([TodoTask]?) -> Void) {
        taskManager.fetchTasks(for: tag, completion: completion)
    }
    
    func fetchUncompletedTaskCount(for item: IdentifiableItem, completion: @escaping(Int) -> Void) {
        taskManager.fetchUncompletedTaskCount(for: item, completion: completion)
    }
    
    // MARK: - 任务处理
    /// 创建任务
    func createTask(with quickAddTask: TodoQuickAddTask) {
        taskManager.createTask(with: quickAddTask)
    }
    
    func moveTasks(_ tasks: [TodoTask], to list: TodoList?) {
        taskManager.moveTasks(tasks, to: list)
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
    
    /// 更新优先级
    func updateTasks(_ tasks: [TodoTask], priority: TodoTaskPriority) {
        taskManager.updateTasks(tasks, priority: priority)
    }
    
    func updateTasks(_ tasks: [TodoTask], isCompleted: Bool) {
        taskManager.updateTasks(tasks, isCompleted: isCompleted)
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
    
    func reorderTask(_ sourceTask: TodoTask,
                     postion: TodoTaskInsertPosition,
                     targetTask: TodoTask,
                     in list: TodoList?) {
        taskManager.reorderTask(sourceTask, postion: postion, targetTask: targetTask, in: list)
    }
}
