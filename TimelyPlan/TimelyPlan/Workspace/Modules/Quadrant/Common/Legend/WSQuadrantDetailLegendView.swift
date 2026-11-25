//
//  WSQuadrantDetailLegendView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 象限图例

/// 四象限图例。自上而下逐行展示各象限的图标、名称、未完成任务数与占比。
///
/// 每行都可点击，点击后进入对应象限的详情页。
class WSQuadrantDetailLegendView: WSRowListView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 行间距
        static let rowSpacing: CGFloat = 2.0
        
        /// 列间距
        static let columnSpacing: CGFloat = 8.0
    }
    
    /// 点击象限回调
    var didSelectQuadrantHandler: ((Quadrant) -> Void)?
    
    init(rowCount: Int, columnCount: Int = 1) {
        super.init(frame: .zero)
        
        self.rowCount = max(rowCount, 1)
        self.columnCount = max(columnCount, 1)
        self.rowSpacing = Metrics.rowSpacing
        self.columnSpacing = Metrics.columnSpacing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSQuadrantDetailLegendRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSQuadrantDetailLegendRowView else {
            return
        }
        
        rowView.didSelectQuadrant = { [weak self] quadrant in
            self?.didSelectQuadrantHandler?(quadrant)
        }
    }
    
    // MARK: - 渲染
    /// 更新图例内容。各行按总数换算占比
    func update(with items: [WSQuadrantCountsItem]) {
        reloadData()
        
        let total = items.reduce(0) { $0 + $1.count }
        for (index, rowView) in rowViews.enumerated() {
            (rowView as? WSQuadrantDetailLegendRowView)?.update(with: items[safe: index], total: total)
        }
    }
}

// MARK: - 图例行视图

/// 四象限图例的行视图。最左侧为象限图标，其后为象限名称与未完成任务数，最右侧为占比。
class WSQuadrantDetailLegendRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let padding = UIEdgeInsets(horizontal: 8.0)
        
        /// 行按下高亮的圆角
        static let cornerRadius: CGFloat = 6.0
        
        /// 图标尺寸
        static let iconSize = CGSize(value: 16.0)
        
        /// 图标与名称的间距
        static let iconSpacing: CGFloat = 6.0
        
        /// 数目与占比的间距
        static let percentSpacing: CGFloat = 6.0
        
        /// 名称字体
        static let titleFont = UIFont.systemFont(ofSize: 12.0)
        
        /// 数目字体
        static let valueFont = UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .semibold)
        
        /// 占比字体
        static let percentFont = UIFont.monospacedDigitSystemFont(ofSize: 11.0, weight: .regular)
        
        /// 按下时行底色的透明度
        static let highlightedBackgroundColorAlpha: CGFloat = 0.12
    }
    
    /// 象限图标
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    /// 名称与未完成任务数
    private lazy var infoView: TPInfoTextValueView = {
        let view = TPInfoTextValueView()
        view.titleConfig = .withFont(Metrics.titleFont, textColor: .label)
        return view
    }()
    
    /// 占比
    private lazy var percentLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.percentFont
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.numberOfLines = 1
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
        
        addSubview(iconView)
        addSubview(infoView)
        addSubview(percentLabel)
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
        
        let percentWidth = ceil(percentLabel.sizeThatFits(.unlimited).width)
        let infoLeft = contentFrame.minX + Metrics.iconSize.width + Metrics.iconSpacing
        let infoRight = max(contentFrame.maxX - percentWidth - Metrics.percentSpacing, infoLeft)
        
        /// 图标贴左并垂直居中
        iconView.size = Metrics.iconSize
        iconView.left = contentFrame.minX
        iconView.centerY = contentFrame.midY
        
        /// 名称与数目占中间区域，数目贴信息视图右侧
        infoView.size = CGSize(width: infoRight - infoLeft, height: contentFrame.height)
        infoView.left = infoLeft
        infoView.top = contentFrame.minY
        
        /// 占比贴右
        percentLabel.size = CGSize(width: percentWidth, height: contentFrame.height)
        percentLabel.top = contentFrame.minY
        percentLabel.right = contentFrame.maxX
    }
    
    // MARK: - 渲染
    /// 更新象限、未完成任务数与占比。传 nil 时清空内容
    func update(with dataItem: WSQuadrantCountsItem?, total: Int) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            iconView.image = nil
            infoView.title = nil
            infoView.valueConfig = nil
            percentLabel.text = nil
            normalBackColor = .clear
            highlightedBackColor = .clear
            setNeedsLayout()
            return
        }
        
        let color = dataItem.quadrant.color
        iconView.image = iconImage(for: dataItem.quadrant)
        iconView.tintColor = color
        infoView.title = dataItem.quadrant.title
        infoView.valueConfig = .valueText("\(dataItem.count)",
                                          font: Metrics.valueFont,
                                          textColor: color)
        
        let percent = total > 0 ? Float(dataItem.count) / Float(total) : 0.0
        percentLabel.text = percent.percentageString(decimalPlaces: 0)
        
        normalBackColor = .clear
        highlightedBackColor = color.withAlphaComponent(Metrics.highlightedBackgroundColorAlpha)
        
        setNeedsLayout()
    }
    
    /// 象限图标按象限颜色渲染
    private func iconImage(for quadrant: Quadrant) -> UIImage? {
        guard let iconName = quadrant.iconName else {
            return nil
        }
        
        return resGetImage(iconName)?.withRenderingMode(.alwaysTemplate)
    }
    
    // MARK: - 交互
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectQuadrant?(dataItem.quadrant)
    }
}
