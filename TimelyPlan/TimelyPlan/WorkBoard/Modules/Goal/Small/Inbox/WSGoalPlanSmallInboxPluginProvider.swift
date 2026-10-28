//
//  WSGoalPlanSmallInboxPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标·小·收件箱。展示收件箱中的任务数目。
class WSGoalPlanSmallInboxPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .goalSmallInbox
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .small
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSGoalPlanSmallInboxContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSGoalPlanInboxContentInteractor(plugin: plugin, context: context)
    }
}

// MARK: - 内容交互器

class WSGoalPlanInboxContentInteractor: WSGoalPlanPluginContentInteractor,
                                        GoalTaskProcessorDelegate {
    
    /// 收件箱任务数目只随目标任务变化
    override var observedUpdaterOptions: GoalUpdaterOption {
        return .task
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        GoalRepository.fetchNumberOfInboxGoalTasks { count in
            completion(WSGoalPlanInboxDataItem(taskCount: count))
        }
    }
    
    // MARK: - 主操作
    /// 点击组件：打开收件箱详情
    override func performPrimaryAction() {
        WSGoalPlanDetailPresenter.showInboxDetail()
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示示例任务数目
    override func previewDataItem() -> WSPluginDataItem? {
        return WSGoalPlanInboxDataItem(taskCount: 3)
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
