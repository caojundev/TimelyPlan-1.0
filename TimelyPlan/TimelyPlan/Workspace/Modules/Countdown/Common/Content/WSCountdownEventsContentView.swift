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
class WSCountdownEventsContentView: WSRowListView {
    
    /// 卡片风格。为 nil 表示纯列表，不给行视图加底色
    private let cardStyle: WSCountdownEventsCardStyle?
    
    /// 行视图的构建闭包
    private let rowViewBuilder: () -> WSCountdownEventRowBaseView
    
    /// 初始化内容视图
    /// - Parameters:
    ///   - itemCount: 行视图数量，与交互器最多展示的事项数目保持一致
    ///   - columnCount: 每行个数
    ///   - contentInsets: 内容与组件边缘的间距
    ///   - spacing: 行视图之间的间距，行列一致
    ///   - cardStyle: 卡片风格，为 nil 时按纯列表排列
    ///   - makeRowView: 行视图的构建闭包
    init(itemCount: Int,
         columnCount: Int = 1,
         contentInsets: UIEdgeInsets = .zero,
         spacing: CGFloat = 0.0,
         cardStyle: WSCountdownEventsCardStyle? = nil,
         makeRowView: @escaping () -> WSCountdownEventRowBaseView = { WSCountdownEventRowView() }) {
        self.cardStyle = cardStyle
        self.rowViewBuilder = makeRowView
        super.init(frame: .zero)
        
        /// 列数不超过条数，避免出现空列
        let columns = min(max(columnCount, 1), max(itemCount, 1))
        self.padding = contentInsets
        self.columnCount = columns
        self.rowCount = itemCount > 0 ? Int(ceil(Double(itemCount) / Double(columns))) : 0
        self.rowSpacing = spacing
        self.columnSpacing = spacing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return rowViewBuilder()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSCountdownEventRowBaseView else {
            return
        }
        
        applyCardStyle(to: rowView)
        
        /// 行内点击直接交给交互器处理；空白行没有对应事项，交给组件主操作响应
        rowView.didSelectItemHandler = { [weak self] dataItem in
            guard let self = self else {
                return
            }
            
            guard let dataItem = dataItem else {
                self.interactor?.performEmptyRowAction()
                return
            }
            
            self.interactor?.performAction(with: dataItem)
        }
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
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        /// 按顺序展示事项，超出行数的部分忽略，不足的行展示骨架
        let dataItems = (dataItem as? WSCountdownEventsDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            (rowView as? WSCountdownEventRowBaseView)?.update(with: dataItems[safe: index])
        }
    }
}
