//
//  WSTodoRowsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 行协议

/// 待办行视图。内容视图通过该协议统一刷新行数据
protocol WSTodoRowViewUpdating: AnyObject {
    
    /// 行内容与行边缘的间距
    var contentInsets: UIEdgeInsets { get set }
    
    /// 更新行数据。传 nil 表示空位，行视图内部切换为骨架展示
    func update(with dataItem: WSPluginDataItem?)
}

/// 待办行数据条目。内容视图通过该协议统一读取待展示的行数据
protocol WSTodoRowsDataProviding {
    
    /// 待展示的行数据，按展示顺序排列
    var rowItems: [WSPluginDataItem] { get }
}

// MARK: - 行内容视图基类

/// 待办行内容视图基类，列表与网格共用。
///
/// 统一顶部标题、行列布局、卡片外观与点击转发；行视图与数据绑定由具体协议约束，
/// 子类只需提供行视图与行交互。
class WSTodoRowsContentView: WSRowListView {
    
    // MARK: - 配置
    /// 布局配置
    struct LayoutConfiguration {
        
        /// 内容与组件边缘的间距
        let padding: UIEdgeInsets
        
        /// 列数，1 为列表
        let columnCount: Int
        
        /// 行间距
        let rowSpacing: CGFloat
        
        /// 列间距
        let columnSpacing: CGFloat
        
        /// 卡片圆角，0 表示不展示卡片
        let cornerRadius: CGFloat
        
        /// 卡片内容内边距，nil 表示沿用行视图的默认值
        let contentInsets: UIEdgeInsets?
        
        /// 卡片底色，nil 表示不展示底色
        let backColor: UIColor?
        
        /// 卡片按下底色
        let highlightedBackColor: UIColor?
        
        /// 列表：单列纵向排列，行不展示底色
        static let list = LayoutConfiguration(padding: UIEdgeInsets(value: 8.0),
                                              columnCount: 1,
                                              rowSpacing: 4.0,
                                              columnSpacing: 0.0,
                                              cornerRadius: 0.0,
                                              contentInsets: nil,
                                              backColor: nil,
                                              highlightedBackColor: nil)
        
        /// 网格：多列卡片排列
        static func grid(columnCount: Int = 2) -> LayoutConfiguration {
            return LayoutConfiguration(padding: UIEdgeInsets(value: 8.0),
                                       columnCount: columnCount,
                                       rowSpacing: 8.0,
                                       columnSpacing: 8.0,
                                       cornerRadius: 12.0,
                                       contentInsets: UIEdgeInsets(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0),
                                       backColor: Color(light: 0x000000, 0.05, dark: 0xFFFFFF, 0.10),
                                       highlightedBackColor: Color(light: 0x000000, 0.10, dark: 0xFFFFFF, 0.20))
        }
    }
    
    /// 标题配置
    struct TitleConfiguration {
        
        /// 图标名称
        let iconName: String
        
        /// 图标与文案颜色
        let color: UIColor
        
        /// 标题文案
        let title: String
    }
    
    /// 标题尺寸
    private enum Metrics {
        
        /// 图标边长及其与标题的间距
        static let iconSize: CGFloat = 16.0
        static let iconMargins = UIEdgeInsets(left: 8.0, right: 8.0)
        
        /// 标题高度及其与行列表的间距
        static let titleHeight: CGFloat = 24.0
        static let titleSpacing: CGFloat = 4.0
        
        /// 标题字号
        static let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .medium)
    }
    
    // MARK: - 状态
    /// 布局配置
    let layoutConfiguration: LayoutConfiguration
    
    /// 标题配置
    private let titleConfiguration: TitleConfiguration
    
    /// 图标 + 标题
    private lazy var titleView: TPIconTitleView = {
        let view = TPIconTitleView()
        view.icon = TPIcon(name: titleConfiguration.iconName)
        view.foreColor = titleConfiguration.color
        view.accessorySize = CGSize(value: Metrics.iconSize)
        view.accessoryMargins = Metrics.iconMargins
        view.titleConfig = .withFont(Metrics.titleFont, textColor: titleConfiguration.color)
        view.title = titleConfiguration.title
        return view
    }()
    
    init(titleConfiguration: TitleConfiguration,
         layoutConfiguration: LayoutConfiguration,
         itemCount: Int) {
        self.titleConfiguration = titleConfiguration
        self.layoutConfiguration = layoutConfiguration
        super.init(frame: .zero)
        
        let padding = layoutConfiguration.padding
        
        /// 顶部留出标题的位置，行列表在标题下方排布
        self.padding = UIEdgeInsets(top: padding.top + Metrics.titleHeight + Metrics.titleSpacing,
                                    left: padding.left,
                                    bottom: padding.bottom,
                                    right: padding.right)
        
        let itemCount = max(itemCount, 0)
        let columns = min(max(layoutConfiguration.columnCount, 1), max(itemCount, 1))
        self.columnCount = columns
        self.rowCount = itemCount > 0 ? Int(ceil(Double(itemCount) / Double(columns))) : 0
        self.rowSpacing = layoutConfiguration.rowSpacing
        self.columnSpacing = layoutConfiguration.columnSpacing
        
        addSubview(titleView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// 标题贴内容区域顶部，行区域由 padding 预留标题高度后自动下移
        let contentFrame = bounds.inset(by: layoutConfiguration.padding)
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        /// 行视图晚于标题创建，标题需要保持在最上层
        bringSubviewToFront(titleView)
        titleView.frame = CGRect(x: contentFrame.minX,
                                 y: contentFrame.minY,
                                 width: contentFrame.width,
                                 height: Metrics.titleHeight)
    }
    
    // MARK: - 行视图
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        rowView.normalBackColor = layoutConfiguration.backColor ?? .clear
        
        if let backColor = layoutConfiguration.highlightedBackColor {
            rowView.highlightedBackColor = backColor
        }
        
        if layoutConfiguration.cornerRadius > 0.0 {
            rowView.contentCornerRadius = layoutConfiguration.cornerRadius
        }
        
        if let contentInsets = layoutConfiguration.contentInsets {
            (rowView as? WSTodoRowViewUpdating)?.contentInsets = contentInsets
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSTodoRowsDataProviding)?.rowItems ?? []
        for (index, rowView) in rowViews.enumerated() {
            (rowView as? WSTodoRowViewUpdating)?.update(with: items[safe: index])
        }
    }
    
    // MARK: - 交互
    /// 转发行点击给交互器
    func performAction(with dataItem: WSPluginDataItem) {
        interactor?.performAction(with: dataItem)
    }
}
