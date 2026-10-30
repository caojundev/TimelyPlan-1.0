//
//  WSQuadrantCountsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation

// MARK: - 内容交互器

/// 四象限·数目的内容交互器。
///
/// 按象限布局顺序逐个统计未完成任务数，任务或象限设置变化后重新取数。
/// 各尺寸的数目组件共用该交互器，展示差异由内容视图决定。
class WSQuadrantCountsContentInteractor: WSPluginContentInteractor,
                                         TodoTaskProcessorDelegate,
                                         SettingAgentObserver {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库与设置中心弱引用持有，无需手动移除
        TodoRepository.addUpdater(self, for: .task)
        QuadrantSetting.shared.addObserver(self)
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let quadrants = QuadrantSetting.shared.layout.getQuadrants()
        var counts = [Quadrant: Int]()
        let group = DispatchGroup()
        
        /// 各象限的计数查询互不依赖，并行查询后统一回调
        for quadrant in quadrants {
            group.enter()
            
            let filterRule = QuadrantSetting.shared.filterRule(for: quadrant)
            TodoRepository.fetchUncompletedTaskCount(filterRule: filterRule) { count in
                counts[quadrant] = count
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let items = quadrants.map { quadrant in
                return WSQuadrantCountsItem(quadrant: quadrant, count: counts[quadrant] ?? 0)
            }
            
            completion(WSQuadrantCountsDataItem(items: items))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例数目
    override func previewDataItem() -> WSPluginDataItem? {
        let sampleCounts = [3, 5, 2, 4]
        let items = Quadrant.allCases.enumerated().map { index, quadrant in
            return WSQuadrantCountsItem(quadrant: quadrant,
                                        count: sampleCounts[index % sampleCounts.count])
        }
        
        return WSQuadrantCountsDataItem(items: items)
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        guard let settingKey = QuadrantSetting.Key(name: keyName) else {
            return
        }
        
        /// 象限顺序与过滤规则会影响展示内容，其余设置与未完成任务数无关
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
