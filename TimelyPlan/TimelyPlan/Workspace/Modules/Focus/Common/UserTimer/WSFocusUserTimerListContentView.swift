//
//  WSFocusUserTimerListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 列表内容视图

/// 用户计时器列表内容视图，各尺寸共用。
///
/// 单列纵向排列若干用户计时器行，条数与交互器最多展示的数目保持一致；
/// 空缺行展示骨架，保持与真实展示一致的排布。
class WSFocusUserTimerListContentView: WSRowListView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(horizontal: 4.0, vertical: 8.0)
        
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
        return WSFocusUserTimerRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSFocusUserTimerRowView else {
            return
        }
        
        /// 列表不展示卡片底色，行内只有开始按钮响应点击
        rowView.normalBackColor = .clear
        rowView.highlightedBackColor = .clear
        rowView.didClickStartHandler = { [weak self] dataItem in
            self?.startFocus(with: dataItem.timerIdentifier)
        }
    }
    
    // MARK: - 交互
    /// 点击行内开始按钮，开启对应的用户计时器
    private func startFocus(with timerIdentifier: String) {
        (interactor as? WSFocusUserTimerContentInteractor)?.startFocus(with: timerIdentifier)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSFocusUserTimersDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            (rowView as? WSFocusUserTimerRowView)?.update(with: items[safe: index])
        }
    }
}
