//
//  WSTodoTaskItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 任务数据

/// 待办任务行数据。作为行点击回调的数据条目传给交互器，各组件共用
struct WSTodoTaskItem: WSPluginDataItem {

    /// 任务标识
    let identifier: String

    /// 任务名称
    let name: String

    /// 是否已完成
    let isCompleted: Bool

    /// 完成状态样式
    let checkType: TodoTaskCheckType

    /// 完成进度（0 ～ 1）
    let progress: CGFloat

    /// 是否设置了进度
    let isProgressSet: Bool

    /// 详情：由 `TodoTaskDetailProvider` 按展示项生成
    let detail: ASAttributedString?

    init(identifier: String,
         name: String,
         isCompleted: Bool = false,
         checkType: TodoTaskCheckType = .normal,
         progress: CGFloat = 0.0,
         isProgressSet: Bool = false,
         detail: ASAttributedString? = nil) {
        self.identifier = identifier
        self.name = name
        self.isCompleted = isCompleted
        self.checkType = checkType
        self.progress = progress
        self.isProgressSet = isProgressSet
        self.detail = detail
    }

    /// 由待办任务生成展示数据。option 为 nil 时不展示详情
    init(task: TodoTask, option: TodoTaskDetailOption?) {
        self.init(identifier: task.identifier,
                  name: task.name ?? "",
                  isCompleted: task.isCompleted,
                  checkType: task.checkType,
                  progress: task.completionFraction,
                  isProgressSet: task.isProgressSet,
                  detail: option.flatMap { TodoTaskDetailProvider(task: task, option: $0).attributedInfo() })
    }
}

// MARK: - 行数据

/// 待办任务行数据。行视图沿用的任务数据与行颜色，各任务列表组件共用
struct WSTodoTaskRowItem {

    /// 行视图沿用的任务数据
    let taskItem: WSTodoTaskItem

    /// 行颜色，与待办任务一致取优先级颜色
    let color: UIColor

    init(taskItem: WSTodoTaskItem, color: UIColor) {
        self.taskItem = taskItem
        self.color = color
    }

    /// 由待办任务生成行数据。option 为 nil 时不展示详情
    init(task: TodoTask, option: TodoTaskDetailOption? = nil) {
        self.init(taskItem: WSTodoTaskItem(task: task, option: option),
                  color: task.priority.color)
    }
}

// MARK: - 任务标识

extension WSTodoTaskItem: WSTodoTaskItemProviding {

    var taskIdentifier: String {
        return identifier
    }
}
