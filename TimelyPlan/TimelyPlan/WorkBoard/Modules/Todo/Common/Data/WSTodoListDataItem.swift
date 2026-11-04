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
/// 展示字段与待办首页的清单一致：图标、名称与颜色。
/// 只持有清单标识，交互时再据此读取最新的清单，避免持有过期快照。
class WSTodoListDataItem: NSObject, WSPluginDataItem {
    
    /// 清单唯一标识
    let listIdentifier: String
    
    /// 清单名称
    let title: String
    
    /// 清单图标
    let icon: TPIcon?
    
    /// 清单颜色
    let color: UIColor
    
    init(listIdentifier: String, title: String, icon: TPIcon?, color: UIColor) {
        self.listIdentifier = listIdentifier
        self.title = title
        self.icon = icon
        self.color = color
        super.init()
    }
    
    /// 由待办清单生成展示数据。有表情符号时优先展示表情，其次按清单布局取图标
    convenience init(list: TodoList) {
        let icon = list.emoji.map { TPIcon(text: $0) } ?? TPIcon(name: list.layoutType.miniIconName)
        self.init(listIdentifier: list.identifier,
                  title: list.displayName,
                  icon: icon,
                  color: list.color ?? .primary)
    }
}

// MARK: - 行数据条目

/// 待办清单多条目数据。
class WSTodoListRowsDataItem: NSObject, WSPluginDataItem {
    
    /// 待展示的清单，按展示顺序排列
    let items: [WSTodoListDataItem]
    
    init(items: [WSTodoListDataItem]) {
        self.items = items
        super.init()
    }
}
