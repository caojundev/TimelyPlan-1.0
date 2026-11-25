//
//  WSQuadrantTasksContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 内容交互器

/// 四象限任务的内容交互器。
///
/// 按象限布局顺序读取各象限的未完成任务，下发条数由 `maximumTaskCount` 控制，
/// 实际展示条数由列表视图按可用高度决定。任务或象限设置变化后重新取数。
class WSQuadrantTasksContentInteractor: WSTodoTaskContentInteractor,
                                        SettingAgentObserver {

    /// 每个象限最多下发的任务数。卡片更高的组件可覆写
    var maximumTaskCount: Int {
        return 6
    }

    /// 任务详情的展示项。为 nil 时不展示详情
    var option: TodoTaskDetailOption? {
        return nil
    }

    /// 任务快速添加管理器，首次添加时创建
    private var quickAddManager: TodoTaskQuickAddManager?

    /// 需要取数与展示的象限。单象限组件可覆写为配置中选择的象限
    var targetQuadrants: [Quadrant] {
        return QuadrantSetting.shared.layout.getQuadrants()
    }

    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)

        /// 观察者由设置中心弱引用持有，无需手动移除
        QuadrantSetting.shared.addObserver(self)
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let quadrants = targetQuadrants
        let maximumTaskCount = self.maximumTaskCount
        let option = self.option
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
                return Self.makeQuadrantItem(quadrant: quadrant,
                                             tasks: results[quadrant] ?? [],
                                             maximumTaskCount: maximumTaskCount,
                                             option: option)
            }

            completion(WSQuadrantTasksDataItem(quadrants: items))
        }
    }

    /// 按创建时间倒序取前若干条任务，与四象限主页面的排序一致
    private static func makeQuadrantItem(quadrant: Quadrant,
                                         tasks: [TodoTask],
                                         maximumTaskCount: Int,
                                         option: TodoTaskDetailOption?) -> WSQuadrantTaskGroup {
        let sortedTasks = tasks.sorted { lhs, rhs in
            let lhsDate = lhs.creationDate ?? .distantPast
            let rhsDate = rhs.creationDate ?? .distantPast
            return lhsDate > rhsDate
        }

        let visibleTasks = sortedTasks.prefix(maximumTaskCount).map {
            WSTodoTaskItem(task: $0, option: option)
        }
        return WSQuadrantTaskGroup(
            quadrant: quadrant,
            tasks: visibleTasks,
            totalCount: sortedTasks.count)
    }

    // MARK: - 预览数据
    /// 画廊预览使用的象限，各尺寸组件可覆写
    var previewQuadrants: [Quadrant] {
        return targetQuadrants
    }

    /// 画廊预览数据：固定展示一组示例任务，第一个象限超出上限以展示更多入口
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
                      resGetString("Coffee Break"),
                      resGetString("Warm Up"),
                      resGetString("Free Focus")]
        let totalCounts = [12, 5, 3, 6]
        let quadrants = previewQuadrants.enumerated().map { index, quadrant -> WSQuadrantTaskGroup in
            let totalCount = totalCounts[index % totalCounts.count]
            /// 示例任务名不重复展示
            let sampleCount = min(totalCount, maximumTaskCount, titles.count)
            /// 有详情展示项时补充示例详情
            let detail = option == nil
                ? nil
                : Date().monthDayString.attributedString(textColor: .secondaryLabel)
            let tasks = (0..<sampleCount).map { taskIndex -> WSTodoTaskItem in
                let titleIndex = (index + taskIndex) % titles.count
                return WSTodoTaskItem(identifier: "preview.\(index).\(taskIndex)",
                                      name: titles[titleIndex],
                                      isCompleted: taskIndex == 1,
                                      checkType: titleIndex % 3 == 0 ? .decrease : .increase,
                                      progress: CGFloat(taskIndex + 1) / 5.0,
                                      isProgressSet: taskIndex % 2 == 0,
                                      detail: detail)
            }

            return WSQuadrantTaskGroup(quadrant: quadrant,
                                       tasks: tasks,
                                       totalCount: totalCount)
        }

        return WSQuadrantTasksDataItem(quadrants: quadrants)
    }

    // MARK: - 交互
    /// 添加任务：按该象限的过滤规则快速添加，与四象限主页面点击添加按钮一致
    func quickAddTask(for quadrant: Quadrant, from view: UIView?) {
        guard let viewController = view?.parentViewController else {
            return
        }

        if quickAddManager == nil {
            quickAddManager = TodoTaskQuickAddManager(containerViewController: viewController)
        }

        let filterRule = QuadrantSetting.shared.filterRule(for: quadrant)
        quickAddManager?.show(with: filterRule.matchingQuickAddTask)
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
}
