//
//  WSQuadrantTasksDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation

// MARK: - 象限数据

/// 象限及其展示的任务
struct WSQuadrantTaskGroup {
    
    /// 象限
    let quadrant: Quadrant
    
    /// 待展示的任务，条数由交互器的上限决定
    let tasks: [WSTodoTaskItem]
    
    /// 未完成任务总数
    let totalCount: Int
}

// MARK: - 组件数据

/// 四象限任务的组件数据
class WSQuadrantTasksDataItem: NSObject, WSPluginDataItem {
    
    /// 按象限布局顺序排列的各象限任务
    let quadrants: [WSQuadrantTaskGroup]
    
    init(quadrants: [WSQuadrantTaskGroup]) {
        self.quadrants = quadrants
        super.init()
    }
}
