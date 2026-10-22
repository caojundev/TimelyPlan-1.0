//
//  WSCountdownSmallRecentContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 倒数日·小·最近内容视图。
///
/// 纵向排列若干张简略事项卡片，每张由 `WSCountdownCompactEventRowView` 渲染：
/// 左侧图标，右侧名称与剩余时间。卡片自带底色与圆角，行数由初始化时传入。
class WSCountdownSmallRecentContentView: WSPluginContentView {
    
    /// 布局参数
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 卡片之间的间距
        static let rowSpacing: CGFloat = 8.0
        
        /// 卡片圆角
        static let rowCornerRadius: CGFloat = 12.0
        
        /// 卡片底色
        static let rowBackColor: UIColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.02)
                
        /// 卡片按下时的底色
        static let rowHighlightedBackColor: UIColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.08)
    }
    
    /// 行视图，按展示顺序排列
    private var rowViews: [WSCountdownCompactEventRowView] = []
    
    /// 初始化内容视图
    /// - Parameter itemCount: 行数，与交互器最多展示的事项数目保持一致
    init(itemCount: Int) {
        super.init(frame: .zero)
        
        rowViews = (0..<max(itemCount, 0)).map { _ in
            let rowView = WSCountdownCompactEventRowView()
            rowView.normalBackColor = Metrics.rowBackColor
            rowView.highlightedBackColor = Metrics.rowHighlightedBackColor
            rowView.contentCornerRadius = Metrics.rowCornerRadius
            
            /// 行内点击直接交给交互器处理
            rowView.didSelectHandler = { [weak self] dataItem in
                self?.interactor?.performAction(with: dataItem)
            }
            
            addSubview(rowView)
            return rowView
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds.inset(by: Metrics.padding)
        let rowCount = rowViews.count
        guard layoutFrame.height > 0.0, rowCount > 0 else {
            return
        }
        
        /// 行与行之间留出固定间距，剩余高度均分给各行
        let spacing = Metrics.rowSpacing
        let totalSpacing = spacing * CGFloat(rowCount - 1)
        let rowHeight = max((layoutFrame.height - totalSpacing) / CGFloat(rowCount), 0.0)
        
        for (index, rowView) in rowViews.enumerated() where !rowView.isHidden {
            rowView.frame = CGRect(x: layoutFrame.minX,
                                   y: layoutFrame.minY + CGFloat(index) * (rowHeight + spacing),
                                   width: layoutFrame.width,
                                   height: rowHeight)
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        /// 按顺序展示事项，超出行数的部分忽略，不足的行展示骨架
        let dataItems = (dataItem as? WSCountdownRecentDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            rowView.update(with: dataItems[safe: index])
        }
        
        setNeedsLayout()
    }
}
