//
//  WSQuadrantMediumDonutContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·中·圆环的内容视图。
///
/// 左侧为按象限计数分段的圆环，环心展示总的任务数目；
/// 右侧为图例列表，自上而下展示各象限的图标、名称、未完成任务数与占比。
class WSQuadrantMediumDonutContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 10.0)
        
        /// 圆环区域占内容宽度的比例
        static let ringAreaRatio: CGFloat = 0.45
        
        /// 环边长占圆环区域短边的比例
        static let ringSizeRatio: CGFloat = 0.95
        
        /// 圆环与图例的间距
        static let ringSpacing: CGFloat = 10.0
    }
    
    /// 圆环
    private let ringView = WSQuadrantDonutRingView()
    
    /// 图例
    private let legendView = WSQuadrantDetailLegendView(rowCount: Quadrant.allCases.count)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        legendView.didSelectQuadrantHandler = { [weak self] quadrant in
            self?.showDetail(for: quadrant)
        }
        
        addSubview(ringView)
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
        
        /// 圆环在左侧，保持正方形并垂直居中
        let ringAreaWidth = contentFrame.width * Metrics.ringAreaRatio
        let side = max(min(ringAreaWidth, contentFrame.height) * Metrics.ringSizeRatio, 0.0)
        ringView.size = CGSize(value: side)
        ringView.left = contentFrame.minX + (ringAreaWidth - side) / 2.0
        ringView.centerY = contentFrame.midY
        
        /// 图例在右侧，自上而下排列
        let legendLeft = contentFrame.minX + ringAreaWidth + Metrics.ringSpacing
        legendView.size = CGSize(width: max(contentFrame.maxX - legendLeft, 0.0),
                                 height: contentFrame.height)
        legendView.left = legendLeft
        legendView.top = contentFrame.minY
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
            legendView.update(with: [])
            
            setNeedsLayout()
            return
        }
        
        ringView.segments = dataItem.items.map { item in
            return WSQuadrantDonutRingView.Segment(color: item.quadrant.color, count: item.count)
        }
        ringView.total = dataItem.items.reduce(0) { $0 + $1.count }
        legendView.update(with: dataItem.items)
        
        setNeedsLayout()
    }
}
