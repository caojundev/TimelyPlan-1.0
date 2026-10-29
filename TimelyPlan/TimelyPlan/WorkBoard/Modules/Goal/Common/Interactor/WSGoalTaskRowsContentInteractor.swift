//
//  WSGoalTaskRowsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation

// MARK: - 内容交互器

/// 目标任务行组件的内容交互器，各尺寸列表与网格共用。
///
/// 按配置中的选择顺序读取目标任务，换算成行数据后下发；
/// 任务增删改或进度变化时重新取数。
class WSGoalTaskRowsContentInteractor: WSGoalTaskPluginContentInteractor {
    
    /// 最多展示的目标任务数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
    }
    
    /// 配置中选择的目标任务标识，按选择顺序排列
    private var selectedIdentifiers: [String] {
        return plugin.configuration(as: WSGoalTaskSelectedTasksConfiguration.self)?.taskIdentifiers ?? []
    }
    
    // MARK: - 取数
    /// 按选择顺序读取目标任务
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let identifiers = Array(selectedIdentifiers.prefix(maximumItemCount))
        let tasks = identifiers.compactMap { GoalRepository.getGoalTask(withIdentifier: $0) }
        
        guard !tasks.isEmpty else {
            /// 没有可展示的任务时交给空白内容视图
            completion(nil)
            return
        }
        
        let items = tasks.map { WSGoalTaskDataItem(goalTask: $0) }
        completion(WSGoalTaskRowsDataItem(items: items))
    }
    
    // MARK: - 交互
    /// 点击任务：打开任务操作视图
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let dataItem = dataItem as? WSGoalTaskDataItem,
              let goalTask = GoalRepository.getGoalTask(withIdentifier: dataItem.taskIdentifier) else {
            return
        }
        
        GoalPresenter.showActionViewController(for: goalTask)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例任务，不受用户配置影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [(title: String,
                        progress: CGFloat,
                        isCompleted: Bool,
                        checkType: TodoTaskCheckType,
                        colorHex: UInt64)] = [
            (resGetString("Reading"), 0.6, false, .increase, 0x8C36FF),
            (resGetString("Workout"), 1.0, true, .increase, 0xFCB100),
            (resGetString("Writing"), 0.2, false, .decrease, 0x09AFFF),
            (resGetString("Planning"), 0.35, false, .increase, 0xE84F01),
            (resGetString("Review"), 0.8, false, .increase, 0x26B450),
            (resGetString("Deep Work"), 0.5, false, .decrease, 0xFD2504),
            (resGetString("Coding"), 1.0, true, .increase, 0x00786C),
            (resGetString("Study"), 0.15, false, .decrease, 0x7E22A3)
        ]
        
        let now = Date()
        let targetValue: Int64 = 10
        let items = examples.prefix(maximumItemCount).enumerated().map { index, example -> WSGoalTaskDataItem in
            let startDate = now.dateByAddingDays(-3 - index) ?? now
            let endDate = now.dateByAddingDays(4 - index) ?? now
            let currentValue = Int64((example.progress * CGFloat(targetValue)).rounded())
            return WSGoalTaskDataItem(taskIdentifier: "preview.\(index)",
                                      title: example.title,
                                      color: Color(example.colorHex),
                                      progress: example.progress,
                                      hasValidProgress: true,
                                      isCompleted: example.isCompleted,
                                      checkType: example.checkType,
                                      dateRange: DateRange(startDate: startDate, endDate: endDate),
                                      currentValue: currentValue,
                                      targetValue: targetValue,
                                      weight: 3)
        }
        
        return WSGoalTaskRowsDataItem(items: items)
    }
}
