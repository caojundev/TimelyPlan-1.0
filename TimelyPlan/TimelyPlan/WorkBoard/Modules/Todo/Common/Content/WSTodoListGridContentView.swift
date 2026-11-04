//
//  WSTodoListGridContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 网格内容视图

/// 待办清单网格内容视图，各网格尺寸共用。
///
/// 顶部标题由基类提供，其下按列数等分排列若干清单卡片，卡片底色与圆角由行视图的
/// `WSRowView` 外观属性提供；清单不足时，剩余位置展示骨架。
class WSTodoListGridContentView: WSTodoListRowsContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 卡片间距
        static let spacing: CGFloat = 8.0
        
        /// 卡片圆角
        static let cornerRadius: CGFloat = 12.0
        
        /// 卡片内边距
        static let contentInsets = UIEdgeInsets(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0)
        
        /// 卡片底色
        static let backColor = Color(light: 0x000000, 0.05, dark: 0xFFFFFF, 0.10)
        
        /// 卡片按下底色
        static let highlightedBackColor = Color(light: 0x000000, 0.10, dark: 0xFFFFFF, 0.20)
    }
    
    init(itemCount: Int, columnCount: Int) {
        super.init(frame: .zero)
        
        let columns = min(max(columnCount, 1), max(itemCount, 1))
        self.contentPadding = Metrics.padding
        self.columnCount = columns
        self.rowCount = itemCount > 0 ? Int(ceil(Double(itemCount) / Double(columns))) : 0
        self.rowSpacing = Metrics.spacing
        self.columnSpacing = Metrics.spacing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        super.didAddRowView(rowView, at: index)
        
        guard let rowView = rowView as? WSTodoListRowView else {
            return
        }
        
        /// 网格以卡片承载，行内边距比列表更大
        rowView.normalBackColor = Metrics.backColor
        rowView.highlightedBackColor = Metrics.highlightedBackColor
        rowView.contentCornerRadius = Metrics.cornerRadius
        rowView.contentInsets = Metrics.contentInsets
    }
}
