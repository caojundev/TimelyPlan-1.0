//
//  PieCircleView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/11.
//

import Foundation

class PieCircleView: UIView {
    
    var visual: PieVisual! {
        didSet {
            setNeedsLayout()
        }
    }

    /// 外部边框宽度
    var outerBorderWidth: CGFloat = 2.0  {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 外圆半径
    var outerRadius: CGFloat = 80.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 内环半径
    var innerRadius: CGFloat = 60.0  {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 内部边框宽度
    var innerBorderWidth: CGFloat = 2.0  {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 边框宽度
    var pieBorderWidth = 1.2  {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 其它部分颜色
    let othersColor = Color(0x121212)
    
    /// 遮罩图层
    lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = resGetColor(.title)
        self.layer.mask = maskLayer
        self.updateMaskLayer()
        self.addAnimationIfNeeded()
    }
    
    override func draw(_ rect: CGRect) {
        
        guard visual != nil else { return }
        let context = UIGraphicsGetCurrentContext()!
        let circleCenter = bounds.middlePoint
        let angles = visual.angles
        let colors = visual.colors
        for index in 0..<angles.count {
            draw(angle: angles[index],
                 withColor: colors[index % colors.count],
                 using: context)
        }
        
        // 如果有剩余 灰色补齐剩余
        if angles.count > 0 && visual.totalPercent < 1 {
            let remaining = 1 - visual.totalPercent
            let start = visual.totalPercent
            let slice = PieSlice(title: resGetString("Others"), detail: nil, percent: remaining)
            let lastAngle = PieSliceAngle(index: angles.count,
                                          slice: slice,
                                          percentStart: start,
                                          percentLength: remaining)
            draw(angle: lastAngle, withColor: othersColor, using: context)
        }
        
        /// 绘制内圆
        context.move(to: circleCenter)
        context.addArc(center: circleCenter,
                       radius: innerRadius - pieBorderWidth,
                       startAngle: 0,
                       endAngle: CGFloat.pi * 2,
                       clockwise: false)
        context.closePath()
        context.setFillColor(UIColor.systemBackground.cgColor)
        context.fillPath()
    }
    
    /// 绘制弧线
    func draw(angle: PieSliceAngle,
              withColor color: UIColor,
              using context: CGContext) {
        let circleCenter = bounds.middlePoint
        let path = UIBezierPath()
        path.move(to: circleCenter)
        path.addArc(withCenter: circleCenter,
                    radius: outerRadius + pieBorderWidth,
                    startAngle: angle.startAngle,
                    endAngle: angle.endAngle,
                    clockwise: true)
        path.close()
        path.lineWidth = pieBorderWidth
        
        color.setFill()
        UIColor.systemBackground.setStroke()
        
        path.fill()
        path.stroke()
    }
    
    // MARK: - Mask
    private func updateMaskLayer() {
        let borderWidth = outerRadius - innerRadius
        let radius = innerRadius + borderWidth / 2.0
        let path = UIBezierPath()
        path.addArc(withCenter: bounds.middlePoint,
                    radius: radius,
                    startAngle: -CGFloat.pi / 2.0,
                    endAngle: 1.5 * CGFloat.pi,
                    clockwise: true)
        self.maskLayer.path = path.cgPath
        self.maskLayer.lineWidth = borderWidth
    }
    
    private func addAnimationIfNeeded() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration  = 1.2
        animation.fromValue = 0.0
        animation.toValue   = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true
        maskLayer.add(animation, forKey: "Animation")
    }
}
