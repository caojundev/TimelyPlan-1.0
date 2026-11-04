//
//  WSTodoListRowsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 行内容视图基类

/// 待办清单行内容视图基类，各尺寸列表共用。
///
/// 统一行视图创建、点击转发与数据绑定；子类只负责行列数与行外观。
class WSTodoListRowsContentView: WSRowListView {
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSTodoListRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSTodoListRowView else {
            return
        }
        
        /// 行本身响应点击
        rowView.didSelectListHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSTodoListRowsDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            /// 空位传 nil，行视图内部会切换为骨架展示
            (rowView as? WSTodoListRowView)?.update(with: items[safe: index])
        }
    }
}
