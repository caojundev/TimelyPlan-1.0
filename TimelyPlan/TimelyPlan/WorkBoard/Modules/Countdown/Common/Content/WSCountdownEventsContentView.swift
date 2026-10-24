//
//  WSCountdownEventsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 倒数日「事项」类组件的展示条数。
///
/// 各组件唯一的差异是展示条数：小号 2 条、中号列表 3 条、中号网格 4 条、中号三列 3 条、
/// 大号列表 5 条、大号网格 8 条。交互器取数与内容视图行数共用这里的常量，避免两处分别硬编码。
enum WSCountdownEventsItemCount {
    
    /// 小号组件的展示条数
    static let small = 2
    
    /// 中号·列表组件的展示条数
    static let mediumList = 3
    
    /// 中号·网格组件的展示条数
    static let mediumGrid = 4
    
    /// 中号·三列组件的展示条数
    static let mediumColumns = 3
    
    /// 大号·列表组件的展示条数
    static let largeList = 5
    
    /// 大号·网格组件的展示条数
    static let largeGrid = 8
}

// MARK: - 内容视图

/// 倒数日「事项」内容视图。
///
/// 把若干行视图按列数等分排列：列表为单列逐行（无内边距、无间隔），
/// 卡片网格为多列（带内边距与间隔，并给行视图应用卡片风格）。
/// 行视图的类型、数量与排列方式全部由初始化参数决定，各尺寸组件共用同一套排列算法。
class WSCountdownEventsContentView: WSPluginContentView {
    
    /// 每行个数
    private let columnCount: Int
    
    /// 内容与组件边缘的间距
    private let contentInsets: UIEdgeInsets
    
    /// 行视图之间的间距
    private let spacing: CGFloat
    
    /// 卡片风格。为 nil 表示纯列表，不给行视图加底色
    private let cardStyle: WSCountdownEventsCardStyle?
    
    /// 行视图，按展示顺序排列
    private var rowViews: [WSCountdownEventRowBaseView] = []
    
    /// 初始化内容视图
    /// - Parameters:
    ///   - itemCount: 行视图数量，与交互器最多展示的事项数目保持一致
    ///   - columnCount: 每行个数
    ///   - contentInsets: 内容与组件边缘的间距
    ///   - spacing: 行视图之间的间距
    ///   - cardStyle: 卡片风格，为 nil 时按纯列表排列
    ///   - makeRowView: 行视图的构建闭包
    init(itemCount: Int,
         columnCount: Int = 1,
         contentInsets: UIEdgeInsets = .zero,
         spacing: CGFloat = 0.0,
         cardStyle: WSCountdownEventsCardStyle? = nil,
         makeRowView: () -> WSCountdownEventRowBaseView = { WSCountdownEventRowView() }) {
        self.columnCount = max(columnCount, 1)
        self.contentInsets = contentInsets
        self.spacing = max(spacing, 0.0)
        self.cardStyle = cardStyle
        super.init(frame: .zero)
        
        rowViews = (0..<max(itemCount, 0)).map { _ in
            let rowView = makeRowView()
            applyCardStyle(to: rowView)
            
            /// 行内点击直接交给交互器处理；空白行没有对应事项，交给组件主操作响应
            rowView.didSelectHandler = { [weak self] dataItem in
                guard let self = self else {
                    return
                }
                
                guard let dataItem = dataItem else {
                    self.interactor?.performEmptyRowAction()
                    return
                }
                
                self.interactor?.performAction(with: dataItem)
            }
            
            addSubview(rowView)
            return rowView
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 给行视图应用卡片风格
    private func applyCardStyle(to rowView: WSCountdownEventRowBaseView) {
        guard let cardStyle = cardStyle else {
            return
        }
        
        rowView.normalBackColor = cardStyle.backColor
        rowView.highlightedBackColor = cardStyle.highlightedBackColor
        rowView.contentCornerRadius = cardStyle.cornerRadius
        rowView.skeletonConfig = cardStyle.skeletonConfig
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds.inset(by: contentInsets)
        let itemCount = rowViews.count
        guard layoutFrame.height > 0.0, itemCount > 0 else {
            return
        }
        
        /// 列数不超过行视图数量，避免出现空列
        let columnCount = min(self.columnCount, itemCount)
        let rowCount = Int(ceil(Double(itemCount) / Double(columnCount)))
        
        /// 行与行、列与列之间留出固定间距，剩余空间均分
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
        
        /// 按顺序展示事项，超出行数的部分忽略，不足的行展示骨架
        let dataItems = (dataItem as? WSCountdownEventsDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            rowView.update(with: dataItems[safe: index])
        }
        
        setNeedsLayout()
    }
}
