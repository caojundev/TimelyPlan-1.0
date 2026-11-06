//
//  WSTodoGroupTasksDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 集合信息

/// 任务所属集合（清单、标签等）的展示信息。
///
/// 组件头部与画廊预览都以该信息展示集合，各业务只需提供名称、图标与颜色。
struct WSTodoGroupInfo {
    
    /// 集合名称
    let title: String
    
    /// 集合图标
    let icon: TPIcon?
    
    /// 集合颜色
    let color: UIColor
}

// MARK: - 集合任务

/// 选中的集合及其任务。
struct WSTodoTaskGroup {
    
    /// 集合展示信息
    let info: WSTodoGroupInfo
    
    /// 集合内的任务
    let tasks: [TodoTask]
}

// MARK: - 组件数据

/// 按集合筛选的待办任务组件数据。
///
/// 头部展示所属集合的图标、名称与颜色，下方为集合内的任务。
class WSTodoGroupTasksDataItem: NSObject, WSPluginDataItem {
    
    /// 所属集合的展示信息
    let group: WSTodoGroupInfo
    
    /// 任务，按集合内的顺序排列
    let items: [WSTodoTaskRowItem]
    
    init(group: WSTodoGroupInfo, items: [WSTodoTaskRowItem]) {
        self.group = group
        self.items = items
        super.init()
    }
    
    /// 任务数目
    var taskCount: Int {
        return items.count
    }
}
