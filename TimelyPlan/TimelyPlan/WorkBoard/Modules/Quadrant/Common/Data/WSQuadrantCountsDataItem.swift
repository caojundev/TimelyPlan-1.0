//
//  WSQuadrantCountsDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation

// MARK: - 数据条目

/// 象限与其未完成任务数
struct WSQuadrantCountsItem {
    
    let quadrant: Quadrant
    
    let count: Int
}

/// 四象限·数目的组件数据。
///
/// 只持有各象限的未完成任务数，展示格式由内容视图决定。
class WSQuadrantCountsDataItem: NSObject, WSPluginDataItem {
    
    /// 按象限布局顺序排列的未完成任务数
    let items: [WSQuadrantCountsItem]
    
    init(items: [WSQuadrantCountsItem]) {
        self.items = items
        super.init()
    }
}
