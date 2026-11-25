//
//  WSTodoGroupTasksRowListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 带卡片样式的任务行列表

/// 按集合筛选任务的行列表视图。
///
/// 在 `WSTodoTaskMoreRowListView` 的基础上按布局配置设置行的间距与卡片样式；
/// 行视图刷新会重置底色，因此每次更新数据后重新应用卡片外观。
class WSTodoGroupTasksRowListView: WSTodoTaskMoreRowListView {
    
    /// 行外观
    struct Appearance {
        
        /// 行内容与行边缘的间距
        let rowPadding: UIEdgeInsets
        
        /// 行的卡片圆角，0 表示沿用行视图的默认值
        let cornerRadius: CGFloat
        
        /// 行的卡片底色，nil 表示不展示底色
        let backColor: UIColor?
        
        /// 行的卡片按下底色，nil 表示沿用行视图的默认值
        let highlightedBackColor: UIColor?
    }
    
    /// 行外观
    private let appearance: Appearance
    
    init(maximumRowCount: Int, appearance: Appearance) {
        self.appearance = appearance
        super.init(maximumRowCount: maximumRowCount)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 数据
    override func update(items: [WSTodoTaskRowItem]) {
        super.update(items: items)
        
        guard appearance.backColor != nil else {
            return
        }
        
        for rowView in rowViews.compactMap({ $0 as? WSTodoTaskRowView }) where rowView.dataItem != nil {
            updateCardAppearance(for: rowView)
        }
    }
    
    // MARK: - 行视图
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        super.didAddRowView(rowView, at: index)
        
        guard let rowView = rowView as? WSTodoTaskRowView else {
            return
        }
        
        rowView.padding = appearance.rowPadding
        if appearance.cornerRadius > 0.0 {
            rowView.contentCornerRadius = appearance.cornerRadius
        }
    }
    
    /// 应用卡片底色
    private func updateCardAppearance(for rowView: WSTodoTaskRowView) {
        rowView.normalBackColor = appearance.backColor ?? .clear
        
        if let highlightedBackColor = appearance.highlightedBackColor {
            rowView.highlightedBackColor = highlightedBackColor
        }
    }
}
