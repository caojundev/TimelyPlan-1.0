//
//  WSQuadrantLargeDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 任务数据

/// 象限中单个任务的展示数据。作为点击回调的数据条目传给交互器
struct WSQuadrantLargeTaskItem: WSPluginDataItem {
    
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
    
    /// 详情：任务日期信息
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
    
    /// 由待办任务生成展示数据
    init(task: TodoTask) {
        self.init(identifier: task.identifier,
                  name: task.name ?? "",
                  isCompleted: task.isCompleted,
                  checkType: task.checkType,
                  progress: task.completionFraction,
                  isProgressSet: task.isProgressSet,
                  detail: task.schedule?.dateInfo?.attributedTitle(slashFormatted: false,
                                                                   textColor: .secondaryLabel))
    }
}

// MARK: - 象限数据

/// 象限及其展示的任务
struct WSQuadrantLargeQuadrantItem {
    
    /// 象限
    let quadrant: Quadrant
    
    /// 待展示的任务，最多 4 条
    let tasks: [WSQuadrantLargeTaskItem]
    
    /// 未完成任务总数
    let totalCount: Int
    
    /// 未展示的任务数
    var hiddenCount: Int {
        return max(totalCount - tasks.count, 0)
    }
}

// MARK: - 组件数据

/// 四象限·大·任务的组件数据
class WSQuadrantLargeDataItem: NSObject, WSPluginDataItem {
    
    /// 按象限布局顺序排列的各象限任务
    let quadrants: [WSQuadrantLargeQuadrantItem]
    
    init(quadrants: [WSQuadrantLargeQuadrantItem]) {
        self.quadrants = quadrants
        super.init()
    }
}
