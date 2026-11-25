//
//  WSTodoTagDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 待办标签组件中的单个标签数据。
///
/// 展示字段与待办首页的标签一致：名称与颜色；
/// 同时持有标签本身，行视图据此获取未完成任务数目。
class WSTodoTagDataItem: NSObject, WSPluginDataItem {
    
    /// 标签。画廊预览数据没有真实标签，此时不展示任务数目
    let tag: TodoTag?
    
    /// 标签唯一标识
    let tagIdentifier: String
    
    /// 标签名称
    let title: String
    
    /// 标签颜色
    let color: UIColor
    
    /// 由待办标签生成展示数据
    init(tag: TodoTag) {
        self.tag = tag
        self.tagIdentifier = tag.identifier
        self.title = tag.name ?? resGetString("Untitled")
        self.color = tag.color
        super.init()
    }
    
    /// 预览数据：固定的名称与颜色，不关联真实标签
    init(previewIdentifier: String, title: String, color: UIColor) {
        self.tag = nil
        self.tagIdentifier = previewIdentifier
        self.title = title
        self.color = color
        super.init()
    }
}

// MARK: - 行数据条目

/// 待办标签多条目数据。
class WSTodoTagRowsDataItem: NSObject, WSPluginDataItem, WSTodoRowsDataProviding {
    
    /// 待展示的标签，按展示顺序排列
    let items: [WSTodoTagDataItem]
    
    var rowItems: [WSPluginDataItem] {
        return items
    }
    
    init(items: [WSTodoTagDataItem]) {
        self.items = items
        super.init()
    }
}
