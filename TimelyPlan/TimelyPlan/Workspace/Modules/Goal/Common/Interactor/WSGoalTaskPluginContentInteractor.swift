//
//  WSGoalTaskPluginContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation

// MARK: - 内容交互器基类

/// 目标任务组件的内容交互器基类。
///
/// 统一注册目标任务观察者，数据变化时刷新组件内容；子类只需实现取数与交互。
class WSGoalTaskPluginContentInteractor: WSPluginContentInteractor,
                                         GoalTaskProcessorDelegate {
    
    /// 需要观察的数据类型
    var observedUpdaterOptions: GoalUpdaterOption {
        return .task
    }
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        GoalRepository.addUpdater(self, for: observedUpdaterOptions)
    }
    
    // MARK: - 交互
    /// 点击完成状态：切换任务完成情况
    func clickCheckbox(for dataItem: WSGoalTaskDataItem) {
        guard let goalTask = GoalRepository.getGoalTask(withIdentifier: dataItem.taskIdentifier) else {
            return
        }
        
        GoalTaskController().clickCheckbox(for: goalTask)
    }
    
    // MARK: - GoalTaskProcessorDelegate
    /// 远程变更无法比对，保守地重新取数
    func didChangeRemoteGoalTask(with results: EntityChangeResults<GoalTask>?) {
        pluginDataDidChange()
    }
    
    func didCreateGoalTask(_ goalTask: GoalTask) {
        pluginDataDidChange()
    }
    
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        pluginDataDidChange()
    }
    
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {
        pluginDataDidChange()
    }
    
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {
        pluginDataDidChange()
    }
}
