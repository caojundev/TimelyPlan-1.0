//
//  WSSeparatorLineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 分割线绘制视图

/// 分割线绘制视图。
///
/// 用 `CAShapeLayer` 在视图垂直居中处画一条横线，样式决定实线 / 虚线及线段间隔。
/// 组件内容视图与配置列表的样式预览共用该视图，保证两处观感一致。
class WSSeparatorLineView: UIView {

    /// 分割线样式。线宽与虚实间隔均由样式决定
    var lineStyle: WSSeparatorStyle = .solid {
        didSet {
            updateLineStyle()
            setNeedsLayout()
        }
    }

    /// 分割线颜色
    var lineColor: UIColor = .lightGray {
        didSet {
            updateLineStyle()
        }
    }

    /// 绘制分割线的图层
    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        isUserInteractionEnabled = false

        shapeLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
        updateLineStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLinePath()
    }

    // MARK: - 绘制
    /// 更新线条样式：横线描边，圆点填充
    private func updateLineStyle() {
        switch lineStyle.drawing {
        case .line(let width, let dashPattern):
            shapeLayer.strokeColor = lineColor.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = width
            shapeLayer.lineDashPattern = dashPattern?.map { NSNumber(value: Double($0)) }
        case .dots:
            shapeLayer.strokeColor = UIColor.clear.cgColor
            shapeLayer.fillColor = lineColor.cgColor
            shapeLayer.lineWidth = 0.0
            shapeLayer.lineDashPattern = nil
        }
    }

    /// 更新绘制路径：横线两端撑满可用宽度，圆点整体水平居中
    private func updateLinePath() {
        guard bounds.width > 0.0 else {
            return
        }

        let path = UIBezierPath()
        switch lineStyle.drawing {
        case .line:
            path.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        case .dots(let count, let diameter, let spacing):
            guard count > 0 else {
                return
            }

            let totalWidth = CGFloat(count) * diameter + CGFloat(count - 1) * spacing
            var dotMinX = bounds.midX - totalWidth / 2.0
            for _ in 0..<count {
                path.append(UIBezierPath(ovalIn: CGRect(x: dotMinX,
                                                        y: bounds.midY - diameter / 2.0,
                                                        width: diameter,
                                                        height: diameter)))
                dotMinX += diameter + spacing
            }
        }

        /// 尺寸变化引起的重绘不参与隐式动画，避免线条闪动
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shapeLayer.frame = bounds
        shapeLayer.path = path.cgPath
        CATransaction.commit()
    }
}
