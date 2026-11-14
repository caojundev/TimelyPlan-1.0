//
//  WSActionGridContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 网格内容视图

/// 动作网格内容视图，各网格尺寸共用。
///
/// 按列数等分排列动作卡片，卡片底色与圆角由行视图的 `WSRowView` 外观属性提供。
class WSActionGridContentView: WSActionContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 6.0)

        /// 卡片间距
        static let spacing: CGFloat = 6.0

        /// 卡片圆角
        static let cornerRadius: CGFloat = 10.0

        /// 卡片底色
        static let backColor = Color(light: 0x000000, 0.05, dark: 0xFFFFFF, 0.10)

        /// 卡片按下底色
        static let highlightedBackColor = Color(light: 0x000000, 0.10, dark: 0xFFFFFF, 0.20)
    }

    init(itemCount: Int, columnCount: Int) {
        super.init(maximumItemCount: itemCount)

        let columns = min(max(columnCount, 1), max(itemCount, 1))
        self.padding = Metrics.padding
        self.columnCount = columns
        self.rowSpacing = Metrics.spacing
        self.columnSpacing = Metrics.spacing
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 行视图
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        super.didAddRowView(rowView, at: index)

        guard let rowView = rowView as? WSActionRowView else {
            return
        }

        /// 网格以卡片承载
        rowView.normalBackColor = Metrics.backColor
        rowView.highlightedBackColor = Metrics.highlightedBackColor
        rowView.contentCornerRadius = Metrics.cornerRadius
    }
}
