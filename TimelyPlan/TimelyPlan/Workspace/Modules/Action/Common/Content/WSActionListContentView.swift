//
//  WSActionListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 列表内容视图

/// 动作列表内容视图，各列表尺寸共用。
///
/// 单列纵向排列动作，行高按最大展示条数均分，动作较少时不会占满整个列表。
class WSActionListContentView: WSActionContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(horizontal: 4.0, vertical: 6.0)
    }

    init(itemCount: Int) {
        super.init(maximumItemCount: itemCount)

        self.padding = Metrics.padding
        self.columnCount = 1
        self.rowSpacing = 0.0
        self.columnSpacing = 0.0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
