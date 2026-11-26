//
//  WSTodoListDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 待办清单组件中的单个清单数据。
///
/// 展示字段与待办首页的清单一致：图标、名称与颜色；
/// 同时持有清单本身，行视图据此获取未完成任务数目。
class WSTodoListDataItem: NSObject, WSPluginDataItem {
    
    /// 清单。画廊预览数据没有真实清单，此时不展示任务数目
    let list: TodoList?
    
    /// 清单唯一标识
    let listIdentifier: String
    
    /// 清单名称
    let title: String
    
    /// 清单图标
    let icon: TPIcon?
    
    /// 清单颜色
    let color: UIColor
    
    /// 由待办清单生成展示数据。有表情符号时优先展示表情，其次按清单布局取图标
    init(list: TodoList) {
        self.list = list
        self.listIdentifier = list.identifier
        self.title = list.displayName
        self.icon = list.emoji.map { TPIcon(text: $0) } ?? TPIcon(name: list.layoutType.miniIconName)
        self.color = list.color ?? .primary
        super.init()
    }
    
    /// 预览数据：固定的名称与图标，不关联真实清单
    init(previewIdentifier: String, title: String, icon: TPIcon?, color: UIColor) {
        self.list = nil
        self.listIdentifier = previewIdentifier
        self.title = title
        self.icon = icon
        self.color = color
        super.init()
    }
}

// MARK: - 行数据条目

/// 待办清单多条目数据。
class WSTodoListRowsDataItem: NSObject, WSPluginDataItem, WSTodoRowsDataProviding {
    
    /// 待展示的清单，按展示顺序排列
    let items: [WSTodoListDataItem]
    
    var rowItems: [WSPluginDataItem] {
        return items
    }
    
    init(items: [WSTodoListDataItem]) {
        self.items = items
        super.init()
    }
}
