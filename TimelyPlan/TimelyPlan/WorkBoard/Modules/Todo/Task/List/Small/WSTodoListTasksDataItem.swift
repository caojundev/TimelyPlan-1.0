//
//  WSTodoListTasksDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 组件数据

/// 待办自选清单任务组件的数据。
///
/// 头部展示所选清单的图标、名称与颜色，下方为清单内的未完成任务。
class WSTodoListTasksDataItem: NSObject, WSPluginDataItem {
    
    /// 所选清单的展示信息
    let listItem: WSTodoListDataItem
    
    /// 未完成任务，按清单内的顺序排列
    let items: [WSTodoTaskRowItem]
    
    init(listItem: WSTodoListDataItem, items: [WSTodoTaskRowItem]) {
        self.listItem = listItem
        self.items = items
        super.init()
    }
    
    /// 未完成任务数目
    var taskCount: Int {
        return items.count
    }
}
