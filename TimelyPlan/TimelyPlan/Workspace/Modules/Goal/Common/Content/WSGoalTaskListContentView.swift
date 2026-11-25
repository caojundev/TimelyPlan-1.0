//
//  WSGoalTaskListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 列表内容视图

/// 目标任务列表内容视图，各列表尺寸共用。
///
/// 单列纵向排列若干目标任务行，条数与交互器最多展示的数目保持一致；
/// 任务不足时，剩余的行展示骨架，与其它组件行的空位保持一致。
class WSGoalTaskListContentView: WSGoalTaskRowsContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 行间距
        static let rowSpacing: CGFloat = 2.0
    }
    
    init(itemCount: Int, rowViewFactory: @escaping () -> WSGoalTaskRowView) {
        super.init(rowViewFactory: rowViewFactory)
        
        self.padding = Metrics.padding
        self.columnCount = 1
        self.rowCount = max(itemCount, 0)
        self.rowSpacing = Metrics.rowSpacing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        super.didAddRowView(rowView, at: index)
        
        /// 列表不展示卡片底色
        rowView.normalBackColor = .clear
    }
}
