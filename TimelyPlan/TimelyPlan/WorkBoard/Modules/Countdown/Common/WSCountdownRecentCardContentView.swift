//
//  WSCountdownRecentCardContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 卡片风格

/// 倒数日「最近」类组件的卡片风格。
///
/// 卡片底色很淡，只比组件背景略亮一点；骨架块颜色比全局默认更明显，
/// 保证在淡底色卡片上仍能看出层次。
enum WSCountdownRecentCardStyle {
    
    /// 卡片底色
    static let backColor: UIColor = Color(light: 0x000000, 0.02, dark: 0xFFFFFF, 0.02)
    
    /// 卡片按下时的底色
    static let highlightedBackColor: UIColor = Color(light: 0x000000, 0.08, dark: 0xFFFFFF, 0.08)
    
    /// 卡片圆角
    static let cornerRadius: CGFloat = 12.0
    
    /// 卡片骨架配置
    static let skeletonConfig: SkeletonConfig = {
        var config = Skeleton.config
        config.baseColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
        return config
    }()
}

// MARK: - 内容视图

/// 倒数日「最近」卡片内容视图。
///
/// 把若干张简略事项卡片按行列等分排列：小号组件为一列多行，中号网格组件为两列两行。
/// 每张卡片由 `WSCountdownCompactEventRowView` 渲染，卡片数与列数由初始化时传入。
class WSCountdownRecentCardContentView: WSPluginContentView {
    
    /// 布局参数
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 卡片之间的间距
        static let spacing: CGFloat = 8.0
    }
    
    /// 每行卡片数
    private let columnCount: Int
    
    /// 行视图，按展示顺序排列
    private var rowViews: [WSCountdownCompactEventRowView] = []
    
    /// 初始化内容视图
    /// - Parameters:
    ///   - itemCount: 卡片数量，与交互器最多展示的事项数目保持一致
    ///   - columnCount: 每行卡片数
    init(itemCount: Int, columnCount: Int) {
        self.columnCount = max(columnCount, 1)
        super.init(frame: .zero)
        
        rowViews = (0..<max(itemCount, 0)).map { _ in
            let rowView = WSCountdownCompactEventRowView()
            rowView.normalBackColor = WSCountdownRecentCardStyle.backColor
            rowView.highlightedBackColor = WSCountdownRecentCardStyle.highlightedBackColor
            rowView.contentCornerRadius = WSCountdownRecentCardStyle.cornerRadius
            rowView.skeletonConfig = WSCountdownRecentCardStyle.skeletonConfig
            
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
        let itemCount = rowViews.count
        guard layoutFrame.height > 0.0, itemCount > 0 else {
            return
        }
        
        /// 列数不超过卡片数量，避免出现空列
        let columnCount = min(self.columnCount, itemCount)
        let rowCount = Int(ceil(Double(itemCount) / Double(columnCount)))
        let spacing = Metrics.spacing
        
        /// 行与行、列与列之间留出固定间距，剩余空间均分给每张卡片
        let itemWidth = max((layoutFrame.width - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount), 0.0)
        let itemHeight = max((layoutFrame.height - spacing * CGFloat(rowCount - 1)) / CGFloat(rowCount), 0.0)
        
        for (index, rowView) in rowViews.enumerated() where !rowView.isHidden {
            let column = index % columnCount
            let row = index / columnCount
            rowView.frame = CGRect(x: layoutFrame.minX + CGFloat(column) * (itemWidth + spacing),
                                   y: layoutFrame.minY + CGFloat(row) * (itemHeight + spacing),
                                   width: itemWidth,
                                   height: itemHeight)
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        /// 按顺序展示事项，超出卡片数的部分忽略，不足的卡片展示骨架
        let dataItems = (dataItem as? WSCountdownRecentDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            rowView.update(with: dataItems[safe: index])
        }
        
        setNeedsLayout()
    }
}
