//
//  WSFocusSmallUserTimerContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 专注·小·用户计时器的内容视图。
///
/// 纵向排列若干用户计时器行，条数与交互器最多展示的数目保持一致。
class WSFocusSmallUserTimerContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 行间距
        static let rowSpacing: CGFloat = 4.0
    }
    
    /// 行视图，数量与展示条数一致
    private let rowViews: [WSFocusUserTimerRowView]
    
    // MARK: - 初始化
    init(itemCount: Int) {
        self.rowViews = (0..<max(itemCount, 0)).map { _ in WSFocusUserTimerRowView() }
        super.init(frame: .zero)
        
        self.padding = Metrics.padding
        
        for rowView in rowViews {
            rowView.didClickStartHandler = { [weak self] dataItem in
                self?.startFocus(with: dataItem.timerIdentifier)
            }
            
            addSubview(rowView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard rowViews.count > 0 else {
            return
        }
        
        /// 行等分可用高度
        let totalSpacing = Metrics.rowSpacing * CGFloat(rowViews.count - 1)
        let rowHeight = max((contentFrame.height - totalSpacing) / CGFloat(rowViews.count), 0.0)
        
        var top = contentFrame.minY
        for rowView in rowViews {
            rowView.size = CGSize(width: contentFrame.width, height: rowHeight)
            rowView.left = contentFrame.minX
            rowView.top = top
            top = rowView.bottom + Metrics.rowSpacing
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
            /// 空缺行展示骨架，保持与真实展示一致的排布
            rowView.update(with: items[safe: index])
        }
        
        setNeedsLayout()
    }
}
