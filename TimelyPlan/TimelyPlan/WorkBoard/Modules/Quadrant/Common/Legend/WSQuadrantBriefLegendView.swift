//
//  WSQuadrantBriefLegendView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 象限简略图例

/// 四象限简略图例。自上而下逐行展示各象限的标识点、名称与未完成任务数。
///
/// 每行都可点击，点击后进入对应象限的详情页。
class WSQuadrantBriefLegendView: WSRowListView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 行间距
        static let rowSpacing: CGFloat = 2.0
    }
    
    /// 点击象限回调
    var didSelectQuadrantHandler: ((Quadrant) -> Void)?
    
    init(rowCount: Int) {
        super.init(frame: .zero)
        
        self.rowCount = max(rowCount, 1)
        self.columnCount = 1
        self.rowSpacing = Metrics.rowSpacing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSQuadrantBriefLegendRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSQuadrantBriefLegendRowView else {
            return
        }
        
        rowView.didSelectQuadrant = { [weak self] quadrant in
            self?.didSelectQuadrantHandler?(quadrant)
        }
    }
    
    // MARK: - 渲染
    /// 更新图例内容
    func update(with items: [WSQuadrantCountsItem]) {
        reloadData()
        
        for (index, rowView) in rowViews.enumerated() {
            (rowView as? WSQuadrantBriefLegendRowView)?.update(with: items[safe: index])
        }
    }
}

// MARK: - 图例行视图

/// 四象限简略图例的行视图。左侧为象限标识点，其后为象限名称，右侧为未完成任务数。
class WSQuadrantBriefLegendRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let padding = UIEdgeInsets(horizontal: 4.0)
        
        /// 行按下高亮的圆角
        static let cornerRadius: CGFloat = 6.0
        
        /// 标识点尺寸
        static let dotSize = CGSize(value: 8.0)
        
        /// 标识点与名称的间距
        static let dotSpacing: CGFloat = 6.0
        
        /// 名称与数目的间距
        static let countSpacing: CGFloat = 6.0
        
        /// 名称字体
        static let titleFont = UIFont.systemFont(ofSize: 12.0)
        
        /// 数目字体
        static let countFont = UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .semibold)
        
        /// 按下时行底色的透明度
        static let highlightedBackgroundColorAlpha: CGFloat = 0.12
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
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    /// 未完成任务数
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.countFont
        label.textAlignment = .right
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    /// 当前展示的象限数据
    private(set) var dataItem: WSQuadrantCountsItem?
    
    /// 点击象限回调
    var didSelectQuadrant: ((Quadrant) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        self.contentCornerRadius = Metrics.cornerRadius
        
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
        
        let countWidth = ceil(countLabel.sizeThatFits(.unlimited).width)
        
        /// 标识点贴左并垂直居中
        dotView.size = Metrics.dotSize
        dotView.left = contentFrame.minX
        dotView.centerY = contentFrame.midY
        
        /// 数目贴右
        countLabel.size = CGSize(width: countWidth, height: contentFrame.height)
        countLabel.top = contentFrame.minY
        countLabel.right = contentFrame.maxX
        
        /// 名称占标识点与数目之间的区域
        let titleLeft = dotView.right + Metrics.dotSpacing
        let titleWidth = max(countLabel.left - Metrics.countSpacing - titleLeft, 0.0)
        titleLabel.size = CGSize(width: titleWidth, height: contentFrame.height)
        titleLabel.left = titleLeft
        titleLabel.top = contentFrame.minY
    }
    
    // MARK: - 渲染
    /// 更新象限与未完成任务数。传 nil 时清空内容
    func update(with dataItem: WSQuadrantCountsItem?) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            dotView.backgroundColor = nil
            titleLabel.text = nil
            countLabel.text = nil
            normalBackColor = .clear
            highlightedBackColor = .clear
            setNeedsLayout()
            return
        }
        
        let color = dataItem.quadrant.color
        dotView.backgroundColor = color
        titleLabel.text = dataItem.quadrant.title
        countLabel.textColor = color
        countLabel.text = "\(dataItem.count)"
        
        normalBackColor = .clear
        highlightedBackColor = color.withAlphaComponent(Metrics.highlightedBackgroundColorAlpha)
        
        setNeedsLayout()
    }
    
    // MARK: - 交互
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectQuadrant?(dataItem.quadrant)
    }
}
