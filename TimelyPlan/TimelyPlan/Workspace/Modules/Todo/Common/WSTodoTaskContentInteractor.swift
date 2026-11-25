//
//  WSTodoTaskContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation

// MARK: - 任务条目协议

/// 待办任务插件的数据条目。交互器通过该协议统一读取任务标识
protocol WSTodoTaskItemProviding {

    /// 任务标识
    var taskIdentifier: String { get }
}

// MARK: - 内容交互器基类

/// 待办任务组件的内容交互器基类。
///
/// 统一任务变化监听、点击任务编辑与点击完成状态的逻辑，各模块只需实现取数与预览数据。
class WSTodoTaskContentInteractor: WSPluginContentInteractor,
                                   TodoTaskProcessorDelegate {

    /// 任务操作
    let taskController = TodoTaskController()

    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)

        /// 观察者由数据仓库弱引用持有，无需手动移除
        TodoRepository.addUpdater(self, for: .task)
    }

    // MARK: - 交互
    /// 点击任务：进入任务编辑，与四象限主页面一致
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let item = dataItem as? WSTodoTaskItemProviding,
              let task = TodoRepository.getTask(with: item.taskIdentifier) else {
            return
        }

        taskController.editTask(task)
    }

    /// 点击完成状态：完成或记录进度，与四象限主页面一致
    func clickCheckbox(for dataItem: WSTodoTaskItemProviding) {
        guard let task = TodoRepository.getTask(with: dataItem.taskIdentifier) else {
            return
        }

        taskController.clickCheckbox(for: task, completedHandler: nil, progressHandler: nil)
    }

    // MARK: - TodoTaskProcessorDelegate
    /// 远程变更无法比对，保守地重新取数
    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?) {
        pluginDataDidChange()
    }

    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        pluginDataDidChange()
    }

    func didCreateTodoTask(_ task: TodoTask) {
        pluginDataDidChange()
    }

    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        pluginDataDidChange()
    }

    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        pluginDataDidChange()
    }

    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        pluginDataDidChange()
    }

    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        pluginDataDidChange()
    }

    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        pluginDataDidChange()
    }

    func didEmptyTrash() {
        pluginDataDidChange()
    }

    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        pluginDataDidChange()
    }
}
