//
//  WSFocusWeekActivityView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

/// 一周活动视图。
///
/// 按天展示 7 根圆角柱条，柱条高度由当天的活动进度决定；
/// 背景柱条保持满高，用于提示没有活动的日期。
class WSFocusWeekActivityView: UIView {
    
    /// 每天的活动进度，取值为 0~1，按展示顺序排列
    var dailyActivity: [Float]? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 柱条间距
    var barSpacing: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 活动柱条颜色
    var progressColor: UIColor = Color(0x66D065) {
        didSet {
            activityLayer.fillColor = progressColor.cgColor
        }
    }
    
    /// 背景柱条颜色
    var trackColor: UIColor = Color(light: 0x000000, 0.06, dark: 0xFFFFFF, 0.10) {
        didSet {
            backLayer.fillColor = trackColor.cgColor
        }
    }
    
    /// 单根柱条的最小宽度
    var minimumBarWidth: CGFloat = 8.0
    
    /// 活动绘制图层
    private lazy var activityLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = progressColor.cgColor
        return layer
    }()
    
    /// 背景图层
    private lazy var backLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = trackColor.cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(backLayer)
        layer.addSublayer(activityLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = minimumBarWidth * CGFloat(DAYS_PER_WEEK)
            + barSpacing * CGFloat(DAYS_PER_WEEK - 1)
        return CGSize(width: width + padding.horizontalLength, height: 60.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backLayer.frame = layoutFrame()
        activityLayer.frame = backLayer.frame
        updateBackLayer()
        updateActivityLayer()
    }
    
    private func updateBackLayer() {
        let bounds = backLayer.bounds
        let barWidth = barWidth(in: bounds.width)
        guard barWidth > 0.0, bounds.height > 0.0 else {
            backLayer.path = nil
            return
        }
        
        let path = UIBezierPath()
        for index in 0..<DAYS_PER_WEEK {
            let rect = CGRect(x: originX(for: index, barWidth: barWidth),
                              y: 0.0,
                              width: barWidth,
                              height: bounds.height)
            path.append(UIBezierPath(roundedRect: rect, cornerRadius: barWidth / 2.0))
        }
        
        backLayer.path = path.cgPath
    }
    
    private func updateActivityLayer() {
        let bounds = activityLayer.bounds
        let barWidth = barWidth(in: bounds.width)
        guard barWidth > 0.0, bounds.height > 0.0 else {
            activityLayer.path = nil
            return
        }
        
        let path = UIBezierPath()
        for index in 0..<DAYS_PER_WEEK {
            guard let progress = dailyActivity?[safe: index], progress > 0 else {
                continue
            }
            
            /// 进度大于 0 时保证至少显示为圆点
            let height = max(validatedProgress(CGFloat(progress)) * bounds.height, barWidth)
            let rect = CGRect(x: originX(for: index, barWidth: barWidth),
                              y: bounds.height - height,
                              width: barWidth,
                              height: height)
            path.append(UIBezierPath(roundedRect: rect, cornerRadius: min(barWidth, height) / 2.0))
        }
        
        activityLayer.path = path.cgPath
    }
    
    private func barWidth(in width: CGFloat) -> CGFloat {
        let spacing = barSpacing * CGFloat(DAYS_PER_WEEK - 1)
        return max((width - spacing) / CGFloat(DAYS_PER_WEEK), 0.0)
    }
    
    private func originX(for index: Int, barWidth: CGFloat) -> CGFloat {
        return CGFloat(index) * (barWidth + barSpacing)
    }
}
