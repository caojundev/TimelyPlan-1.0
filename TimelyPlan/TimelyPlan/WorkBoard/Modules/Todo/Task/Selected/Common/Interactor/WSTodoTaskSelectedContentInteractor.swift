//
//  WSTodoTaskSelectedContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation

// MARK: - 内容交互器

/// 待办自选任务的内容交互器，各尺寸列表与网格共用。
///
/// 按配置中的选择顺序读取待办任务，换算成行数据后下发；
/// 任务点击与完成状态点击沿用待办任务交互器基类。
class WSTodoTaskSelectedContentInteractor: WSTodoTaskContentInteractor {

    /// 最多展示的任务数目
    private let maximumItemCount: Int

    /// 任务详情的展示项。为 nil 时不展示详情
    private let option: TodoTaskDetailOption?

    init(plugin: WSPlugin,
         context: WSPluginContext,
         maximumItemCount: Int,
         option: TodoTaskDetailOption?) {
        self.maximumItemCount = max(maximumItemCount, 1)
        self.option = option
        super.init(plugin: plugin, context: context)
    }

    /// 配置中选择的任务标识，按选择顺序排列
    private var selectedIdentifiers: [String] {
        return plugin.configuration(as: WSTodoTaskSelectedTasksConfiguration.self)?.taskIdentifiers ?? []
    }

    // MARK: - 取数
    /// 按选择顺序批量读取待办任务，已完成任务正常展示
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let identifiers = Array(selectedIdentifiers.prefix(maximumItemCount))
        guard !identifiers.isEmpty else {
            /// 没有可选择的任务时交给空白内容视图
            completion(nil)
            return
        }

        let option = self.option
        TodoRepository.fetchTasks(of: identifiers) { tasks in
            guard let tasks = tasks, !tasks.isEmpty else {
                completion(nil)
                return
            }

            let items = tasks.map { WSTodoTaskSelectedItem(task: $0, option: option) }
            completion(WSTodoTaskSelectedRowsDataItem(items: items))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例任务，不受用户配置影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let titles = [resGetString("Reading"),
                      resGetString("Workout"),
                      resGetString("Writing"),
                      resGetString("Planning"),
                      resGetString("Review"),
                      resGetString("Deep Work"),
                      resGetString("Coding"),
                      resGetString("Study"),
                      resGetString("Meditation"),
                      resGetString("Coffee Break")]
        /// 行颜色统一取任务优先级颜色
        let priorities: [TodoTaskPriority] = [.high, .medium, .low, .none]
        /// 示例详情：展示计划与进度，与待办任务详情一致
        let detail: ASAttributedString = Date().monthDayString.attributedString(textColor: .secondaryLabel)

        let itemCount: Int = min(maximumItemCount, titles.count)
        var items: [WSTodoTaskSelectedItem] = []
        items.reserveCapacity(itemCount)

        for index in 0..<itemCount {
            let title: String = titles[index]
            let priority: TodoTaskPriority = priorities[index % priorities.count]
            let checkType: TodoTaskCheckType = index % 3 == 0 ? .decrease : .increase
            let item = WSTodoTaskSelectedItem(identifier: "preview.\(index)",
                                              name: title,
                                              isCompleted: index == 1,
                                              checkType: checkType,
                                              progress: CGFloat(index + 1) / 5.0,
                                              isProgressSet: index % 2 == 0,
                                              detail: detail,
                                              color: priority.color)
            items.append(item)
        }

        return WSTodoTaskSelectedRowsDataItem(items: items)
    }
}
