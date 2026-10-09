//
//  TodoMindMapConverter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/8.
//

import Foundation
import UIKit

/// 将 `TodoMindMapList`（列表 + 任务 + 子列表）递归转换为思维导图的 `MindMapNode`。
///
/// 映射规则：
///   · 列表   → 图标节点（`MindMapIconContent`：Emoji / 布局图标，颜色取列表色）；
///   · 任务   → 列表与任务之间插入一个「任务数量」中间节点（如 "4项待办"），任务挂在其下：
///              · 设置了进度的任务 → 进度节点（`MindMapProgressContent`：圆形进度环）；
///              · 其余任务         → 待办节点（`MindMapTodoContent`：圆角矩形勾选框）；
///              两者颜色都取优先级色；标题末尾追加进度信息（进度任务 "60%"、有步骤 "3/5"）；
///              默认过滤掉已完成任务，传 `showCompleted: true` 可保留；
///   · 步骤   → 待办节点（圆形勾选框，颜色跟随所属任务），递归包含子步骤；
///              已完成的任务忽略其步骤（也不再追加步骤完成信息）；
///   · 子列表 → 递归转换后挂在父列表之下；整棵子树都没有可见任务的子列表会被剪除。
///
/// 节点 id 由「前缀 + 业务 id」组成：整棵导图内 id 必须唯一，加前缀可避免列表与
/// 任务 id 恰好相同时相互冲突。
enum TodoMindMapConverter {

    /// 转换一棵列表树，返回对应的导图根节点。
    /// - Parameters:
    ///   - list: 列表树（含任务与子列表）。
    ///   - showCompleted: 是否显示已完成的任务，默认不显示。
    /// - Note: 传入的根列表始终保留；整棵子树都没有可见任务的子列表会被剪除。
    static func node(from list: TodoMindMapList, showCompleted: Bool = false) -> MindMapNode {
        return MindMapNode(id: listID(list),
                           text: list.name,
                           content: listContent(list),
                           children: childNodes(of: list, showCompleted: showCompleted))
    }

    // MARK: - 递归转换

    /// 列表的子节点：任务中间节点 + 剪枝后的子列表（顺序为任务在前、子列表在后）。
    private static func childNodes(of list: TodoMindMapList,
                                   showCompleted: Bool) -> [MindMapNodeType] {
        var children: [MindMapNodeType] = []
        if let tasks = list.tasks {
            let visibleTasks = showCompleted ? tasks : tasks.filter { !$0.isCompleted }
            // 列表与任务之间插入一个展示任务数量的中间节点（没有任务时不插入）。
            if !visibleTasks.isEmpty {
                children.append(taskSummaryNode(of: list, tasks: visibleTasks))
            }
        }
        if let sublists = list.sublists {
            children.append(contentsOf: sublists.compactMap {
                sublistNode(from: $0, showCompleted: showCompleted)
            })
        }

        return children
    }

    /// 任务数量中间节点：文本形如 "4项待办"，各任务挂在其下。
    private static func taskSummaryNode(of list: TodoMindMapList,
                                        tasks: [TodoTask]) -> MindMapNode {
        let text = String(format: resGetString("%ld to-dos"), tasks.count)
        return MindMapNode(id: taskSummaryID(list),
                           text: text,
                           children: tasks.map(taskNode))
    }

    /// 子列表 → 节点。整棵子树（含更深层子列表）都没有可见任务时返回 nil，从导图中剪除。
    private static func sublistNode(from list: TodoMindMapList,
                                    showCompleted: Bool) -> MindMapNode? {
        let children = childNodes(of: list, showCompleted: showCompleted)
        guard !children.isEmpty else { return nil }

        return MindMapNode(id: listID(list),
                           text: list.name,
                           content: listContent(list),
                           children: children)
    }

    // MARK: - 列表 → 图标节点

    /// 列表节点的载荷：列表图标 + 列表颜色；没有图标时退化为纯文本节点。
    private static func listContent(_ list: TodoMindMapList) -> MindMapNodeContent? {
        guard let icon = list.icon else { return nil }
        return MindMapIconContent(icon: icon, tint: list.color)
    }

    // MARK: - 任务 → 进度 / 待办节点

    private static func taskNode(_ task: TodoTask) -> MindMapNode {
        // 进度环 / 勾选框取任务优先级对应的颜色，步骤跟随同一个颜色。
        let tint = task.priority.color
        // 已完成的任务忽略步骤：任务已完成，步骤明细不再呈现。
        let steps: [TodoStep]? = task.isCompleted ? nil : task.steps

        return MindMapNode(id: taskID(task),
                           text: taskTitle(task, steps: steps),
                           content: taskContent(task, tint: tint),
                           children: (steps ?? []).map { stepNode($0, tint: tint) })
    }

    /// 任务载荷：设置了进度的任务用进度节点，其余用待办节点。
    private static func taskContent(_ task: TodoTask, tint: UIColor) -> MindMapNodeContent {
        if task.isProgressSet {
            return MindMapProgressContent(progress: task.completionFraction, tint: tint)
        }

        return MindMapTodoContent(isDone: task.isCompleted,
                                  style: .roundedRect,
                                  tint: tint)
    }

    /// 任务标题：在名称末尾追加进度信息 —— 设置了进度的追加完成百分比（如 "60%"），
    /// 有步骤的追加步骤完成信息（如 "3/5"）；都没有则只有名称。
    private static func taskTitle(_ task: TodoTask, steps: [TodoStep]?) -> String {
        var title = task.name ?? resGetString("Untitled Task")

        if task.isProgressSet {
            let percent = Int((task.completionFraction * 100).rounded())
            title += " \(percent)%"
        }

        if let steps = steps, !steps.isEmpty {
            title += " \(steps.completedCount())/\(steps.totalCount())"
        }

        return title
    }

    // MARK: - 步骤 → 待办节点

    /// 步骤（含子步骤）递归转成待办节点，勾选框反映完成状态；
    /// 步骤用圆形勾选框、颜色跟随所属任务，以区别于任务。
    private static func stepNode(_ step: TodoStep, tint: UIColor) -> MindMapNode {
        MindMapNode(id: stepID(step),
                    text: step.content,
                    content: MindMapTodoContent(isDone: step.isCompleted,
                                                style: .circle,
                                                tint: tint),
                    children: step.subSteps.map { stepNode($0, tint: tint) })
    }

    // MARK: - 节点 id

    private static func listID(_ list: TodoMindMapList) -> String {
        return "list/\(list.identifier)"
    }

    /// 任务数量中间节点的 id：由列表 id 拼接而成，如 "list/<列表id>/tasks"。
    private static func taskSummaryID(_ list: TodoMindMapList) -> String {
        return listID(list) + "/tasks"
    }

    private static func taskID(_ task: TodoTask) -> String {
        return "task/\(task.identifier)"
    }

    private static func stepID(_ step: TodoStep) -> String {
        return "step/\(step.id)"
    }
}
