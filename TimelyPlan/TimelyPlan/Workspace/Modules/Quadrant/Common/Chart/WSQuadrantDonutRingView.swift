//
//  WSQuadrantDonutRingView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 环形视图

/// 四象限圆环的环形视图。
///
/// 按各段计数占比绘制圆环，每段两端为圆角；全部为 0 时绘制一个浅灰色整环。
/// 环心展示总的任务数目。
class WSQuadrantDonutRingView: UIView {
    
    /// 环上的一段
    struct Segment {
        
        /// 段颜色
        let color: UIColor
        
        /// 段的计数
        let count: Int
    }
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 环线宽占环边长的比例及最小值
        static let lineWidthRatio: CGFloat = 0.12
        static let minimumLineWidth: CGFloat = 12.0
        
        /// 环心数目字号占内径的比例及上限
        static let centerFontRatio: CGFloat = 0.34
        static let centerMaximumFontSize: CGFloat = 34.0
        
        /// 全部为 0 时的整环颜色
        static let emptyRingColor = Color(0x8E8E93, 0.25)
    }
    
    /// 各段数据，按象限顺序排列
    var segments: [Segment] = [] {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 环心展示的总任务数目
    var total: Int = 0 {
        didSet {
            centerLabel.text = "\(total)"
        }
    }
    
    /// 环心数目
    private lazy var centerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .label
        return label
    }()
    
    /// 段图层，最多四段，复用避免每次刷新重建
    private var segmentLayers: [CAShapeLayer] = []
    
    /// 全部为 0 时的整环
    private let emptyRingLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.isHidden = true
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.addSublayer(emptyRingLayer)
        
        for _ in 0..<Quadrant.allCases.count {
            let segmentLayer = CAShapeLayer()
            segmentLayer.fillColor = UIColor.clear.cgColor
            segmentLayer.lineCap = .round
            segmentLayer.isHidden = true
            segmentLayers.append(segmentLayer)
            self.layer.addSublayer(segmentLayer)
        }
        
        addSubview(centerLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let side = min(bounds.width, bounds.height)
        guard side > 0.0 else {
            return
        }
        
        let lineWidth = max(floor(side * Metrics.lineWidthRatio), Metrics.minimumLineWidth)
        let radius = max((side - lineWidth) / 2.0, 0.0)
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                radius: radius,
                                startAngle: -CGFloat.pi / 2.0,
                                endAngle: CGFloat.pi * 1.5,
                                clockwise: true).cgPath
        
        for segmentLayer in segmentLayers {
            segmentLayer.frame = bounds
            segmentLayer.path = path
            segmentLayer.lineWidth = lineWidth
            segmentLayer.isHidden = true
        }
        
        emptyRingLayer.frame = bounds
        emptyRingLayer.path = path
        emptyRingLayer.lineWidth = lineWidth
        emptyRingLayer.strokeColor = Metrics.emptyRingColor.cgColor
        emptyRingLayer.isHidden = true
        
        applySegments()
        layoutCenterLabel(lineWidth: lineWidth)
    }
    
    /// 按各段占比绘制圆环。相邻两段首尾相接，圆角端相互重叠，形成连续的圆环
    private func applySegments() {
        let totalCount = segments.reduce(0) { $0 + $1.count }
        guard totalCount > 0 else {
            emptyRingLayer.isHidden = false
            return
        }
        
        let visibleSegments = segments.filter { $0.count > 0 }
        
        var cursor: CGFloat = 0.0
        for (index, segment) in visibleSegments.enumerated() {
            let segmentLayer = segmentLayers[index]
            let start = cursor
            let end = min(start + CGFloat(segment.count) / CGFloat(totalCount), 1.0)
            
            segmentLayer.strokeColor = segment.color.cgColor
            segmentLayer.strokeStart = start
            segmentLayer.strokeEnd = end
            segmentLayer.isHidden = false
            
            cursor = end
        }
    }
    
    private func layoutCenterLabel(lineWidth: CGFloat) {
        let innerSide = max(min(bounds.width, bounds.height) - lineWidth * 2.0, 0.0)
        let fontSize = min(floor(innerSide * Metrics.centerFontRatio), Metrics.centerMaximumFontSize)
        
        centerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: max(fontSize, 1.0), weight: .bold)
        centerLabel.size = CGSize(width: innerSide, height: ceil(centerLabel.font.lineHeight))
        centerLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
