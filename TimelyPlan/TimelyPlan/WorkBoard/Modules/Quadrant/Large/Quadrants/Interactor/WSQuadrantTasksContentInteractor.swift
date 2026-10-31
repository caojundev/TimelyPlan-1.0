//
//  WSQuadrantTasksContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation

// MARK: - 内容交互器

/// 四象限任务的内容交互器。
///
/// 按象限布局顺序读取各象限的未完成任务，下发条数由 `maximumTaskCount` 控制，
/// 超出上限时少下发一条，为更多入口预留最后一个位置。任务或象限设置变化后重新取数。
class WSQuadrantTasksContentInteractor: WSPluginContentInteractor,
                                        TodoTaskProcessorDelegate,
                                        SettingAgentObserver {
    
    /// 每个象限最多展示的任务数
    static let maximumTaskCount = 4
    
    /// 任务操作
    private let taskController = TodoTaskController()
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库与设置中心弱引用持有，无需手动移除
        TodoRepository.addUpdater(self, for: .task)
        QuadrantSetting.shared.addObserver(self)
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let quadrants = QuadrantSetting.shared.layout.getQuadrants()
        var results = [Quadrant: [TodoTask]]()
        let group = DispatchGroup()
        
        /// 各象限的查询互不依赖，并行查询后统一回调
        for quadrant in quadrants {
            group.enter()
            
            let filterRule = QuadrantSetting.shared.filterRule(for: quadrant)
            TodoRepository.fetchTasks(filterRule: filterRule, showCompleted: false) { tasks in
                results[quadrant] = tasks ?? []
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let items = quadrants.map { quadrant -> WSQuadrantTaskGroup in
                return Self.makeQuadrantItem(quadrant: quadrant, tasks: results[quadrant] ?? [])
            }
            
            completion(WSQuadrantTasksDataItem(quadrants: items))
        }
    }
    
    /// 按创建时间倒序取前若干条任务，与四象限主页面的排序一致
    private static func makeQuadrantItem(quadrant: Quadrant,
                                         tasks: [TodoTask]) -> WSQuadrantTaskGroup {
        let sortedTasks = tasks.sorted { lhs, rhs in
            let lhsDate = lhs.creationDate ?? .distantPast
            let rhsDate = rhs.creationDate ?? .distantPast
            return lhsDate > rhsDate
        }
        
        let visibleTasks = sortedTasks.prefix(visibleTaskCount(for: sortedTasks.count))
            .map { WSQuadrantTaskItem(task: $0) }
        return WSQuadrantTaskGroup(quadrant: quadrant,
                                           tasks: visibleTasks,
                                           totalCount: sortedTasks.count)
    }
    
    /// 下发的任务数。超出上限时为更多入口留出最后一个位置
    private static func visibleTaskCount(for totalCount: Int) -> Int {
        return totalCount > maximumTaskCount ? maximumTaskCount - 1 : totalCount
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例任务，第一个象限超出上限以展示更多入口
    override func previewDataItem() -> WSPluginDataItem? {
        let titles = [resGetString("Reading"),
                      resGetString("Workout"),
                      resGetString("Writing"),
                      resGetString("Planning"),
                      resGetString("Review"),
                      resGetString("Deep Work"),
                      resGetString("Coding")]
        let totalCounts = [8, 5, 3, 6]
        let quadrants = Quadrant.allCases.enumerated().map { index, quadrant -> WSQuadrantTaskGroup in
            let totalCount = totalCounts[index % totalCounts.count]
            let tasks = (0..<Self.visibleTaskCount(for: totalCount)).map { taskIndex -> WSQuadrantTaskItem in
                let titleIndex = (index + taskIndex) % titles.count
                return WSQuadrantTaskItem(identifier: "preview.\(index).\(taskIndex)",
                                               name: titles[titleIndex],
                                               isCompleted: taskIndex == 1,
                                               checkType: titleIndex % 3 == 0 ? .decrease : .increase,
                                               progress: CGFloat(taskIndex + 1) / 5.0,
                                               isProgressSet: taskIndex % 2 == 0,
                                               detail: nil)
            }
            
            return WSQuadrantTaskGroup(quadrant: quadrant,
                                               tasks: tasks,
                                               totalCount: totalCount)
        }
        
        return WSQuadrantTasksDataItem(quadrants: quadrants)
    }
    
    // MARK: - 交互
    /// 点击任务：进入任务编辑，与四象限主页面一致
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let item = dataItem as? WSQuadrantTaskItem,
              let task = TodoRepository.getTask(with: item.identifier) else {
            return
        }
        
        taskController.editTask(task)
    }
    
    /// 点击完成状态：完成或记录进度，与四象限主页面一致
    func clickCheckbox(for dataItem: WSQuadrantTaskItem) {
        guard let task = TodoRepository.getTask(with: dataItem.identifier) else {
            return
        }
        
        taskController.clickCheckbox(for: task, completedHandler: nil, progressHandler: nil)
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        guard let settingKey = QuadrantSetting.Key(name: keyName) else {
            return
        }
        
        /// 象限顺序与过滤规则会影响展示内容，其余设置与未完成任务无关
        switch settingKey {
        case .layout, .customRules:
            pluginDataDidChange()
        case .showCompleted, .showDetail:
            break
        }
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
