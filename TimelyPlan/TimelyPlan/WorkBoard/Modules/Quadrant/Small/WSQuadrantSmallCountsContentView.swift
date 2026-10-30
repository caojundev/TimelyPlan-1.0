//
//  WSQuadrantSmallCountsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·小·数量的内容视图。以两列两行的网格展示各象限的名称与未完成任务数。
///
/// 每个象限都可点击，点击后进入对应象限的详情页。
class WSQuadrantSmallCountsContentView: WSRowListView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 10.0)
        
        /// 象限之间的间距
        static let spacing: CGFloat = 6.0
        
        /// 网格行数
        static let rowCount = 2
        
        /// 网格列数
        static let columnCount = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        self.rowCount = Metrics.rowCount
        self.columnCount = Metrics.columnCount
        self.rowSpacing = Metrics.spacing
        self.columnSpacing = Metrics.spacing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSQuadrantSmallCountsRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSQuadrantSmallCountsRowView else {
            return
        }
        
        rowView.didSelectQuadrantHandler = { [weak self] quadrant in
            self?.showDetail(for: quadrant)
        }
    }
    
    /// 进入象限详情，与四象限主页面点击象限标题的行为一致
    private func showDetail(for quadrant: Quadrant) {
        WSQuadrantDetailPresenter.showDetail(for: quadrant, from: self)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSQuadrantSmallCountsDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            (rowView as? WSQuadrantSmallCountsRowView)?.update(with: items[safe: index])
        }
    }
}

// MARK: - 象限行视图

/// 四象限·小·数量的行视图。承载象限卡片，并响应点击进入象限详情。
class WSQuadrantSmallCountsRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 卡片圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 卡片底色透明度
        static let backgroundColorAlpha: CGFloat = 0.1
        
        /// 按下时卡片底色的透明度
        static let highlightedBackgroundColorAlpha: CGFloat = 0.2
    }
    
    /// 象限卡片
    private let itemView = WSQuadrantSmallCountsItemView()
    
    /// 当前展示的象限数据
    private(set) var dataItem: WSQuadrantCountsItem?
    
    /// 点击象限回调
    var didSelectQuadrantHandler: ((Quadrant) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentCornerRadius = Metrics.cornerRadius
        
        /// 卡片不参与交互，点击统一由行视图处理
        itemView.isUserInteractionEnabled = false
        addSubview(itemView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemView.frame = bounds
    }
    
    // MARK: - 渲染
    /// 更新象限与未完成任务数。传 nil 时清空内容
    func update(with dataItem: WSQuadrantCountsItem?) {
        self.dataItem = dataItem
        itemView.update(with: dataItem)
        
        let color = dataItem?.quadrant.color
        normalBackColor = color?.withAlphaComponent(Metrics.backgroundColorAlpha) ?? .clear
        highlightedBackColor = color?.withAlphaComponent(Metrics.highlightedBackgroundColorAlpha) ?? .clear
    }
    
    // MARK: - 交互
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectQuadrantHandler?(dataItem.quadrant)
    }
}

// MARK: - 象限卡片

/// 四象限·小·数量的象限卡片。左上角为标识点与象限名称，左下角为未完成任务数。
class WSQuadrantSmallCountsItemView: UIView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与卡片边缘的间距
        static let padding = UIEdgeInsets(value: 6.0)
        
        /// 标识点尺寸
        static let dotSize = CGSize(value: 6.0)
        
        /// 标识点与名称的间距
        static let dotSpacing: CGFloat = 4.0
        
        /// 名称字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 11.0)
        
        /// 名称最多展示的行数
        static let titleMaximumLines: Int = 2
        
        /// 名称与数目的间距
        static let countSpacing: CGFloat = 2.0
        
        /// 数目字号占数目区域高度的比例及上限
        static let countFontRatio: CGFloat = 0.95
        static let countMaximumFontSize: CGFloat = 44.0
    }
    
    /// 标识点
    private lazy var dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Metrics.dotSize.width / 2.0
        return view
    }()
    
    /// 象限名称
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.numberOfLines = Metrics.titleMaximumLines
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    /// 未完成任务数
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        addSubview(dotView)
        addSubview(titleLabel)
        addSubview(countLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        let lineHeight = ceil(Metrics.titleFont.lineHeight)
        let titleMaximumHeight = lineHeight * CGFloat(Metrics.titleMaximumLines)
        let titleWidth = max(contentFrame.width - Metrics.dotSize.width - Metrics.dotSpacing, 0.0)
        let titleHeight = min(ceil(titleLabel.sizeThatFits(CGSize(width: titleWidth,
                                                                 height: titleMaximumHeight)).height),
                              titleMaximumHeight)
        
        /// 标识点与名称首行居中对齐
        dotView.size = Metrics.dotSize
        dotView.left = contentFrame.minX
        dotView.top = contentFrame.minY + (lineHeight - Metrics.dotSize.height) / 2.0
        
        titleLabel.size = CGSize(width: titleWidth, height: titleHeight)
        titleLabel.left = dotView.right + Metrics.dotSpacing
        titleLabel.top = contentFrame.minY
        
        /// 名称按固定行数预留高度，保证各卡片的数目区域大小一致
        let countTop = contentFrame.minY + titleMaximumHeight + Metrics.countSpacing
        let countHeight = max(contentFrame.maxY - countTop, 0.0)
        countLabel.size = CGSize(width: contentFrame.width, height: countHeight)
        countLabel.left = contentFrame.minX
        countLabel.top = countTop
        
        let fontSize = min(floor(countHeight * Metrics.countFontRatio), Metrics.countMaximumFontSize)
        countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: max(fontSize, 1.0), weight: .bold)
    }
    
    // MARK: - 渲染
    /// 更新象限与未完成任务数。传 nil 时清空内容
    func update(with dataItem: WSQuadrantCountsItem?) {
        guard let dataItem = dataItem else {
            dotView.backgroundColor = nil
            titleLabel.text = nil
            countLabel.text = nil
            setNeedsLayout()
            return
        }
        
        let color = dataItem.quadrant.color
        dotView.backgroundColor = color
        titleLabel.textColor = color
        titleLabel.text = dataItem.quadrant.title
        countLabel.textColor = color
        countLabel.text = "\(dataItem.count)"
        
        setNeedsLayout()
    }
}
