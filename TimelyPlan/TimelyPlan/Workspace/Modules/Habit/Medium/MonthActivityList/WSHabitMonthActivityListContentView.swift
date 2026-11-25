//
//  WSHabitMonthActivityListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 习惯月度活动列表内容视图。
///
/// 单列纵向排列若干习惯的月度活动行，行数与交互器最多展示的数目保持一致；
/// 中、大尺寸共用同一套行视图，仅行数不同。
class WSHabitMonthActivityListContentView: WSRowListView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 4.0)
        
        /// 行间距
        static let rowSpacing: CGFloat = 0.0
    }
    
    // MARK: - 初始化
    init(itemCount: Int) {
        super.init(frame: .zero)
        
        self.padding = Metrics.padding
        self.columnCount = 1
        self.rowCount = max(itemCount, 0)
        self.rowSpacing = Metrics.rowSpacing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSHabitMonthActivityRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSHabitMonthActivityRowView else {
            return
        }
        
        /// 列表不展示卡片底色
        rowView.normalBackColor = .clear
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSHabitPeriodsDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            /// 空位传 nil，行视图内部会清空内容
            (rowView as? WSHabitMonthActivityRowView)?.update(with: items[safe: index])
        }
    }
}
