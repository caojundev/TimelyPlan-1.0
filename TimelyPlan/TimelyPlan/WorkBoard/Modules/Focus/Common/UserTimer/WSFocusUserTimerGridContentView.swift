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
class WSFocusUserTimerGridContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 卡片间距
        static let spacing: CGFloat = 8.0
    }
    
    /// 每行卡片数
    private let columnCount: Int
    
    /// 行视图，数量与展示条数一致
    private let rowViews: [WSFocusUserTimerRowView]
    
    // MARK: - 初始化
    /// 初始化内容视图
    /// - Parameters:
    ///   - itemCount: 卡片数量，与交互器最多展示的计时器数目保持一致
    ///   - columnCount: 每行卡片数
    init(itemCount: Int, columnCount: Int) {
        self.columnCount = max(columnCount, 1)
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
        
        /// 卡片按列数等分可用区域
        let rowCount = Int(ceil(Double(rowViews.count) / Double(columnCount)))
        let totalColumnSpacing = Metrics.spacing * CGFloat(columnCount - 1)
        let totalRowSpacing = Metrics.spacing * CGFloat(max(rowCount - 1, 0))
        let cardWidth = max((contentFrame.width - totalColumnSpacing) / CGFloat(columnCount), 0.0)
        let cardHeight = max((contentFrame.height - totalRowSpacing) / CGFloat(rowCount), 0.0)
        
        for (index, rowView) in rowViews.enumerated() {
            let column = index % columnCount
            let row = index / columnCount
            
            rowView.size = CGSize(width: cardWidth, height: cardHeight)
            rowView.left = contentFrame.minX + CGFloat(column) * (cardWidth + Metrics.spacing)
            rowView.top = contentFrame.minY + CGFloat(row) * (cardHeight + Metrics.spacing)
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
            /// 空缺位置展示骨架，保持与真实展示一致的排布
            rowView.update(with: items[safe: index])
        }
        
        setNeedsLayout()
    }
}
