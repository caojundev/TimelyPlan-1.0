//
//  WSQuadrantSmallStackedBarContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·小·比例条的内容视图。
///
/// 自上而下依次为总任务数目、按象限计数分段的圆角堆叠比例条、图例列表。
/// 点击图例进入对应象限详情。
class WSQuadrantSmallStackedBarContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 10.0)
        
        /// 总任务数目字体
        static let totalFont = UIFont.monospacedDigitSystemFont(ofSize: 20.0, weight: .bold)
        
        /// 总任务数目与比例条的间距
        static let totalSpacing: CGFloat = 4.0
        
        /// 比例条高度占内容宽度的比例及最小值
        static let barHeightRatio: CGFloat = 0.1
        static let barMinimumHeight: CGFloat = 10.0
        
        /// 比例条与图例的间距
        static let legendSpacing: CGFloat = 8.0
    }
    
    /// 总任务数目
    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.totalFont
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    /// 堆叠比例条
    private let barView = WSQuadrantStackedBarView()
    
    /// 图例
    private let legendView = WSQuadrantBriefLegendView(rowCount: Quadrant.allCases.count)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        legendView.didSelectQuadrantHandler = { [weak self] quadrant in
            self?.showDetail(for: quadrant)
        }
        
        addSubview(totalLabel)
        addSubview(barView)
        addSubview(legendView)
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
        
        /// 总任务数目贴顶居中
        totalLabel.size = CGSize(width: contentFrame.width, height: ceil(Metrics.totalFont.lineHeight))
        totalLabel.origin = contentFrame.origin
        
        /// 比例条在总任务数目下方，高度按内容宽度换算
        let barHeight = max(floor(contentFrame.width * Metrics.barHeightRatio), Metrics.barMinimumHeight)
        barView.size = CGSize(width: contentFrame.width, height: barHeight)
        barView.left = contentFrame.minX
        barView.top = totalLabel.bottom + Metrics.totalSpacing
        
        /// 图例在比例条下方，占满剩余高度
        let legendTop = barView.bottom + Metrics.legendSpacing
        legendView.size = CGSize(width: contentFrame.width,
                                 height: max(contentFrame.maxY - legendTop, 0.0))
        legendView.left = contentFrame.minX
        legendView.top = legendTop
    }
    
    /// 进入象限详情，与四象限主页面点击象限标题的行为一致
    private func showDetail(for quadrant: Quadrant) {
        WSQuadrantDetailPresenter.showDetail(for: quadrant, from: self)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSQuadrantCountsDataItem else {
            totalLabel.text = nil
            barView.segments = []
            legendView.update(with: [])
            
            setNeedsLayout()
            return
        }
        
        totalLabel.text = "\(dataItem.items.reduce(0) { $0 + $1.count })"
        barView.segments = dataItem.items.map { item in
            return WSQuadrantStackedBarView.Segment(color: item.quadrant.color, count: item.count)
        }
        legendView.update(with: dataItem.items)
        
        setNeedsLayout()
    }
}
