//
//  WSQuadrantCountsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·数目的内容视图。
///
/// 按行列数把各象限排成网格，各尺寸组件只需指定行列数与行视图；
/// 每个象限都可点击，点击后进入对应象限的详情页。
class WSQuadrantCountsContentView: WSRowListView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 6.0)
        
        /// 象限之间的间距
        static let spacing: CGFloat = 4.0
    }
    
    init(rowCount: Int, columnCount: Int) {
        super.init(frame: .zero)
        
        self.padding = Metrics.padding
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.rowSpacing = Metrics.spacing
        self.columnSpacing = Metrics.spacing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSQuadrantCountsRowView else {
            return
        }
        
        rowView.didSelectQuadrantHandler = { [weak self] quadrant in
            self?.showDetail(for: quadrant)
        }
    }
    
    /// 进入象限详情，与四象限主页面点击象限标题的行为一致
    private func showDetail(for quadrant: Quadrant) {
        WSQuadrantDetailPresenter.showDetail(for: quadrant, from: self)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSQuadrantCountsDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            (rowView as? WSQuadrantCountsRowView)?.update(with: items[safe: index])
        }
    }
}
