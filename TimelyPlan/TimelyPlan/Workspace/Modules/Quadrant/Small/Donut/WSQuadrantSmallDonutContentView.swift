//
//  WSQuadrantSmallDonutContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·小·圆环的内容视图。
///
/// 上方为按象限计数分段的圆环，环心展示总的任务数目；
/// 底部为图例，按象限顺序居中排列各象限的颜色与计数，点击图例进入对应象限详情。
class WSQuadrantSmallDonutContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 环边长占可用区域短边的比例
        static let ringSizeRatio: CGFloat = 0.8
        
        /// 圆环与图例的间距
        static let ringSpacing: CGFloat = 4.0
        
        /// 图例元素之间的间距
        static let legendSpacing: CGFloat = 8.0
    }
    
    /// 圆环
    private let ringView = WSQuadrantDonutRingView()
    
    /// 图例元素
    private lazy var legendItemViews: [Quadrant: WSQuadrantSmallDonutLegendItemView] = {
        var views = [Quadrant: WSQuadrantSmallDonutLegendItemView]()
        for quadrant in Quadrant.allCases {
            views[quadrant] = WSQuadrantSmallDonutLegendItemView(quadrant: quadrant)
        }
        
        return views
    }()
    
    /// 象限的展示顺序
    private var order: [Quadrant] = Quadrant.allCases
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        addSubview(ringView)
        for quadrant in Quadrant.allCases {
            guard let itemView = legendItemViews[quadrant] else {
                continue
            }
            
            itemView.didSelectHandler = { [weak self] quadrant in
                self?.showDetail(for: quadrant)
            }
            addSubview(itemView)
        }
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
        
        let legendHeight = layoutLegendItems(in: contentFrame)
        
        /// 圆环占据图例以上的区域，保持正方形并居中
        let legendTop = contentFrame.maxY - legendHeight
        let ringAreaHeight = max(legendTop - Metrics.ringSpacing - contentFrame.minY, 0.0)
        let side = max(min(contentFrame.width, ringAreaHeight) * Metrics.ringSizeRatio, 0.0)
        ringView.size = CGSize(value: side)
        ringView.left = contentFrame.midX - side / 2.0
        ringView.top = contentFrame.minY + (ringAreaHeight - side) / 2.0
    }
    
    /// 图例贴底居中排列，返回图例高度
    private func layoutLegendItems(in contentFrame: CGRect) -> CGFloat {
        let items = order.compactMap { quadrant -> (view: WSQuadrantSmallDonutLegendItemView, size: CGSize)? in
            guard let itemView = legendItemViews[quadrant] else {
                return nil
            }
            
            return (itemView, itemView.sizeThatFits(.unlimited))
        }
        
        guard !items.isEmpty else {
            return 0.0
        }
        
        let legendHeight = items.map { ceil($0.size.height) }.max() ?? 0.0
        let legendWidth = items.reduce(0.0) { $0 + ceil($1.size.width) }
            + Metrics.legendSpacing * CGFloat(items.count - 1)
        
        var left = contentFrame.midX - legendWidth / 2.0
        let top = contentFrame.maxY - legendHeight
        for item in items {
            let width = ceil(item.size.width)
            item.view.size = CGSize(width: width, height: legendHeight)
            item.view.left = left
            item.view.top = top
            
            left += width + Metrics.legendSpacing
        }
        
        return legendHeight
    }
    
    /// 进入象限详情，与四象限主页面点击象限标题的行为一致
    private func showDetail(for quadrant: Quadrant) {
        WSQuadrantDetailPresenter.showDetail(for: quadrant, from: self)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSQuadrantCountsDataItem else {
            ringView.segments = []
            ringView.total = 0
            for itemView in legendItemViews.values {
                itemView.update(with: nil)
            }
            
            setNeedsLayout()
            return
        }
        
        order = dataItem.items.map { $0.quadrant }
        ringView.segments = dataItem.items.map { item in
            return WSQuadrantDonutRingView.Segment(color: item.quadrant.color, count: item.count)
        }
        ringView.total = dataItem.items.reduce(0) { $0 + $1.count }
        
        for item in dataItem.items {
            legendItemViews[item.quadrant]?.update(with: item)
        }
        
        setNeedsLayout()
    }
}

// MARK: - 图例元素

/// 四象限·小·圆环的图例元素。左侧为象限色块，右侧为该象限的未完成任务数。
class WSQuadrantSmallDonutLegendItemView: UIView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 色块尺寸
        static let swatchSize = CGSize(value: 8.0)
        
        /// 色块圆角
        static let swatchCornerRadius: CGFloat = 4.0
        
        /// 色块与数目的间距
        static let swatchSpacing: CGFloat = 4.0
        
        /// 数目字体
        static let countFont = UIFont.boldSystemFont(ofSize: 12.0)
        
        /// 点击范围外扩
        static let hitTestInset: CGFloat = 6.0
    }
    
    /// 所属象限
    let quadrant: Quadrant
    
    /// 点击回调
    var didSelectHandler: ((Quadrant) -> Void)?
    
    /// 象限色块
    private lazy var swatchView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Metrics.swatchCornerRadius
        return view
    }()
    
    /// 未完成任务数
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.countFont
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    init(quadrant: Quadrant) {
        self.quadrant = quadrant
        super.init(frame: .zero)
        
        addSubview(swatchView)
        addSubview(countLabel)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickItem(_:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        swatchView.size = Metrics.swatchSize
        swatchView.left = 0.0
        swatchView.centerY = height / 2.0
        
        countLabel.size = CGSize(width: max(width - swatchView.right - Metrics.swatchSpacing, 0.0),
                                 height: height)
        countLabel.left = swatchView.right + Metrics.swatchSpacing
        countLabel.centerY = height / 2.0
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelWidth = ceil(countLabel.sizeThatFits(.unlimited).width)
        let width = Metrics.swatchSize.width + Metrics.swatchSpacing + labelWidth
        let height = max(Metrics.swatchSize.height, ceil(Metrics.countFont.lineHeight))
        return CGSize(width: width, height: height)
    }
    
    /// 扩大点击范围，便于点击较小的图例元素
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -Metrics.hitTestInset, dy: -Metrics.hitTestInset).contains(point)
    }
    
    // MARK: - 渲染
    /// 更新象限与未完成任务数。传 nil 时清空内容
    func update(with dataItem: WSQuadrantCountsItem?) {
        guard let dataItem = dataItem else {
            swatchView.backgroundColor = nil
            countLabel.text = nil
            setNeedsLayout()
            return
        }
        
        let color = dataItem.quadrant.color
        swatchView.backgroundColor = color
        countLabel.textColor = color
        countLabel.text = "\(dataItem.count)"
        
        setNeedsLayout()
    }
    
    // MARK: - 交互
    @objc private func clickItem(_ gesture: UITapGestureRecognizer) {
        TPImpactFeedback.impactWithSoftStyle()
        didSelectHandler?(quadrant)
    }
}
