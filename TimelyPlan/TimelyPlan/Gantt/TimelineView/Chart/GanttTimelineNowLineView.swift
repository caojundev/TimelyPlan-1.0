//
//  GanttTimelineNowLineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/30.
//

import Foundation
import UIKit

/// 今天当前时间指示线视图（竖直布局）
///
/// 参照 CalendarTimelineDotIndicator 实现，采用竖直布局：
/// 顶部一个小圆点 + 向下延伸贯穿整个视图高度的竖直线，用于标记「今天当前时间」所在位置。
/// 不响应任何交互，仅作为覆盖在甘特图上方的指示器。
class GanttTimelineNowLineView: UIView {

    private lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.redPrimary.cgColor
        layer.fillColor = layer.strokeColor
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        self.padding = UIEdgeInsets(horizontal: 2.0)
        self.isUserInteractionEnabled = false
        layer.addSublayer(shapeLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            self.shapeLayer.frame = bounds
        }

        updateLayerPath()
    }

    private func updateLayerPath() {
        let dotSize: CGSize = .size(1)
        let layoutFrame = layoutFrame()
        let bezierPath = UIBezierPath()
        // 圆点位于顶部中间
        let dotCenter = CGPoint(x: layoutFrame.midX, y: layoutFrame.minY + dotSize.halfWidth)
        bezierPath.addArc(withCenter: dotCenter,
                          radius: dotSize.halfWidth,
                          startAngle: radians(of: 0.0),
                          endAngle: radians(of: 360.0),
                          clockwise: true)
        // 竖直线从圆点向下延伸至底部
        bezierPath.move(to: dotCenter)
        bezierPath.addLine(to: CGPoint(x: layoutFrame.midX, y: layoutFrame.maxY))
        self.shapeLayer.path = bezierPath.cgPath
    }
}
