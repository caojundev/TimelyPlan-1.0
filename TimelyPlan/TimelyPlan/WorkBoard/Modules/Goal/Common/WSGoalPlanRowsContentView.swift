//
//  WSGoalPlanRowsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 行内容视图基类

/// 目标计划行内容视图基类，列表与网格共用。
///
/// 统一行视图工厂、点击转发与数据绑定；子类只负责行列数与行外观。
class WSGoalPlanRowsContentView: WSRowListView {
    
    /// 行视图工厂。具体行视图由各尺寸组件提供
    private let rowViewFactory: () -> WSGoalPlanRowView
    
    init(rowViewFactory: @escaping () -> WSGoalPlanRowView) {
        self.rowViewFactory = rowViewFactory
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return rowViewFactory()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSGoalPlanRowView else {
            return
        }
        
        /// 行本身响应点击
        rowView.didSelectPlanHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSGoalPlanRowsDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            /// 空位传 nil，行视图内部会切换为骨架展示
            (rowView as? WSGoalPlanRowView)?.update(with: items[safe: index])
        }
    }
}
