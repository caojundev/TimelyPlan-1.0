//
//  WSTodoTaskSelectedDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 任务数据

/// 自选任务中单个任务的展示数据。作为点击回调的数据条目传给交互器
struct WSTodoTaskSelectedItem: WSPluginDataItem {

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

    /// 任务颜色：与待办列表一致取优先级颜色
    let color: UIColor

    init(identifier: String,
         name: String,
         isCompleted: Bool = false,
         checkType: TodoTaskCheckType = .normal,
         progress: CGFloat = 0.0,
         isProgressSet: Bool = false,
         detail: ASAttributedString? = nil,
         color: UIColor = .primary) {
        self.identifier = identifier
        self.name = name
        self.isCompleted = isCompleted
        self.checkType = checkType
        self.progress = progress
        self.isProgressSet = isProgressSet
        self.detail = detail
        self.color = color
    }

    /// 由待办任务生成展示数据，详情项与待办任务列表一致
    init(task: TodoTask, option: TodoTaskDetailOption?) {
        let provider = TodoTaskDetailProvider(task: task, option: option ?? [])
        let detail = provider.attributedInfo()
        
        self.init(identifier: task.identifier,
                  name: task.name ?? "",
                  isCompleted: task.isCompleted,
                  checkType: task.checkType,
                  progress: task.completionFraction,
                  isProgressSet: task.isProgressSet,
                  detail: detail,
                  color: task.priority.color)
    }

    /// 行视图沿用的任务数据，保证各组件外观一致
    var rowItem: WSTodoTaskItem {
        return WSTodoTaskItem(identifier: identifier,
                              name: name,
                              isCompleted: isCompleted,
                              checkType: checkType,
                              progress: progress,
                              isProgressSet: isProgressSet,
                              detail: detail)
    }
}

// MARK: - 组件数据

/// 待办自选任务的行数据
class WSTodoTaskSelectedRowsDataItem: NSObject, WSPluginDataItem {

    /// 待展示的任务，按选择顺序排列
    let items: [WSTodoTaskSelectedItem]

    init(items: [WSTodoTaskSelectedItem]) {
        self.items = items
        super.init()
    }
}
