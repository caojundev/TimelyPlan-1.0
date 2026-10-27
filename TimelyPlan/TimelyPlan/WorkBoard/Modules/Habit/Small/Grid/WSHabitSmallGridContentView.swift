//
//  WSHabitSmallGridContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 习惯·小·网格的内容视图。按列等分展示习惯图标，空位展示骨架。
class WSHabitSmallGridContentView: WSRowListView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 图标间距
        static let spacing: CGFloat = 8.0
    }
    
    init(itemCount: Int, columnCount: Int) {
        super.init(frame: .zero)
        
        let columns = min(max(columnCount, 1), max(itemCount, 1))
        self.padding = Metrics.padding
        self.columnCount = columns
        self.rowCount = itemCount > 0 ? Int(ceil(Double(itemCount) / Double(columns))) : 0
        self.rowSpacing = Metrics.spacing
        self.columnSpacing = Metrics.spacing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSHabitSmallGridRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSHabitSmallGridRowView else {
            return
        }
        
        rowView.didSelectTaskHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSHabitTasksDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            (rowView as? WSHabitSmallGridRowView)?.update(with: items[safe: index])
        }
    }
}
