//
//  WSGoalPlanListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 列表内容视图

/// 目标计划列表内容视图，各列表尺寸共用。
///
/// 单列纵向排列若干目标计划行，条数与交互器最多展示的数目保持一致；
/// 计划不足时，剩余的行展示骨架，与其它组件行的空位保持一致。
class WSGoalPlanListContentView: WSRowListView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 行间距
        static let rowSpacing: CGFloat = 4.0
    }
    
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
        return WSGoalPlanBriefRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSGoalPlanRowView else {
            return
        }
        
        /// 列表不展示卡片底色，行本身响应点击
        rowView.normalBackColor = .clear
        rowView.didSelectPlanHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSGoalPlanListDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            /// 空位传 nil，行视图内部会切换为骨架展示
            (rowView as? WSGoalPlanRowView)?.update(with: items[safe: index])
        }
    }
}
