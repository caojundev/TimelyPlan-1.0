//
//  WSTodoFilterDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 待办过滤器组件中的单个过滤器数据。
///
/// 展示字段与待办首页的过滤器一致：名称与颜色；
/// 同时持有过滤器本身，行视图据此获取未完成任务数目。
class WSTodoFilterDataItem: NSObject, WSPluginDataItem {
    
    /// 过滤器。画廊预览数据没有真实过滤器，此时不展示任务数目
    let filter: TodoFilter?
    
    /// 过滤器唯一标识
    let filterIdentifier: String
    
    /// 过滤器名称
    let title: String
    
    /// 过滤器颜色
    let color: UIColor
    
    /// 由待办过滤器生成展示数据
    init(filter: TodoFilter) {
        self.filter = filter
        self.filterIdentifier = filter.identifier
        self.title = filter.name ?? resGetString("Untitled")
        self.color = filter.color
        super.init()
    }
    
    /// 预览数据：固定的名称与颜色，不关联真实过滤器
    init(previewIdentifier: String, title: String, color: UIColor) {
        self.filter = nil
        self.filterIdentifier = previewIdentifier
        self.title = title
        self.color = color
        super.init()
    }
}

// MARK: - 行数据条目

/// 待办过滤器多条目数据。
class WSTodoFilterRowsDataItem: NSObject, WSPluginDataItem, WSTodoRowsDataProviding {
    
    /// 待展示的过滤器，按展示顺序排列
    let items: [WSTodoFilterDataItem]
    
    var rowItems: [WSPluginDataItem] {
        return items
    }
    
    init(items: [WSTodoFilterDataItem]) {
        self.items = items
        super.init()
    }
}
