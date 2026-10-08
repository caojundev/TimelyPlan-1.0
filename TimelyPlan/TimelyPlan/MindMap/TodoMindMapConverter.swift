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
///   · 任务   → 待办节点（`MindMapTodoContent`：圆角矩形勾选框反映完成状态），
///              默认过滤掉已完成任务，传 `showCompleted: true` 可保留；
///   · 步骤   → 待办节点（圆形勾选框），递归包含子步骤；已完成的任务忽略其步骤；
///   · 子列表 → 递归转换后挂在父列表之下。
///
/// 节点 id 由「前缀 + 业务 id」组成：整棵导图内 id 必须唯一，加前缀可避免列表与
/// 任务 id 恰好相同时相互冲突。
enum TodoMindMapConverter {

    /// 转换一棵列表树，返回对应的导图根节点。
    /// - Parameters:
    ///   - list: 列表树（含任务与子列表）。
    ///   - showCompleted: 是否显示已完成的任务，默认不显示。
    static func node(from list: TodoMindMapList, showCompleted: Bool = false) -> MindMapNode {
        // 子节点顺序：任务在前、子列表在后，与列表详情里的展示顺序一致。
        var children: [MindMapNodeType] = []
        if let tasks = list.tasks {
            let visibleTasks = showCompleted ? tasks : tasks.filter { !$0.isCompleted }
            children.append(contentsOf: visibleTasks.map(taskNode))
        }
        if let sublists = list.sublists {
            children.append(contentsOf: sublists.map {
                node(from: $0, showCompleted: showCompleted)
            })
        }

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

    // MARK: - 任务 → 待办节点

    private static func taskNode(_ task: TodoTask) -> MindMapNode {
        // 已完成的任务忽略步骤：任务已完成，步骤明细不再呈现。
        let steps = task.isCompleted ? [] : (task.steps ?? []).map(stepNode)

        return MindMapNode(id: taskID(task),
                           text: task.name ?? resGetString("Untitled Task"),
                           content: MindMapTodoContent(isDone: task.isCompleted,
                                                       style: .roundedRect),
                           children: steps)
    }

    // MARK: - 步骤 → 待办节点

    /// 步骤（含子步骤）递归转成待办节点，勾选框反映完成状态；
    /// 步骤用圆形勾选框，以区别于任务的圆角矩形。
    private static func stepNode(_ step: TodoStep) -> MindMapNode {
        MindMapNode(id: stepID(step),
                    text: step.content,
                    content: MindMapTodoContent(isDone: step.isCompleted, style: .circle),
                    children: step.subSteps.map(stepNode))
    }

    // MARK: - 节点 id

    private static func listID(_ list: TodoMindMapList) -> String {
        return "list/\(list.identifier)"
    }

    private static func taskID(_ task: TodoTask) -> String {
        return "task/\(task.identifier)"
    }

    private static func stepID(_ step: TodoStep) -> String {
        return "step/\(step.id)"
    }
}
