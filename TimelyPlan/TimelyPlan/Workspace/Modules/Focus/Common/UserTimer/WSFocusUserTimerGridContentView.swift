//
//  WSFocusUserTimerGridContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 网格内容视图

/// 用户计时器网格内容视图，各尺寸共用。
///
/// 按列数等分排列行视图，空缺位置展示骨架；行视图自带卡片底色与圆角。
class WSFocusUserTimerGridContentView: WSRowListView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 卡片间距
        static let spacing: CGFloat = 8.0
    }
    
    // MARK: - 初始化
    /// 初始化内容视图
    /// - Parameters:
    ///   - itemCount: 卡片数量，与交互器最多展示的计时器数目保持一致
    ///   - columnCount: 每行卡片数
    init(itemCount: Int, columnCount: Int) {
        super.init(frame: .zero)
        
        /// 列数不超过条数，避免出现空列
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
        return WSFocusUserTimerRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSFocusUserTimerRowView else {
            return
        }
        
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
