//
//  WSHabitTaskListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 习惯任务列表内容视图。
///
/// 单列纵向排列若干习惯任务行，条数与交互器最多展示的数目保持一致；
/// 任务不足时，剩余的行展示骨架，与其它组件行的空位保持一致。
class WSHabitTaskListContentView: WSRowListView {
    
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
        return WSHabitTaskRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSHabitTaskRowView else {
            return
        }
        
        /// 列表不展示卡片底色，行本身响应点击
        rowView.normalBackColor = .clear
        rowView.didSelectTaskHandler = { [weak self] dataItem in
            guard let self = self else {
                return
            }
            
            self.interactor?.performAction(with: dataItem)
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSHabitTasksDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            /// 空位传 nil，行视图内部会切换为骨架展示
            (rowView as? WSHabitTaskRowView)?.update(with: items[safe: index])
        }
    }
}
