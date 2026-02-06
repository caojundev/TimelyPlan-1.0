//
//  CalendarDayTimelineIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/6.
//

import Foundation
import UIKit

class CalendarDayTimelineIndicatorView: UIView {
    
    var title: String? {
        get {
            return titleView.title
        }
        
        set { 
            titleView.title = newValue
        }
    }
    
    private let titleViewSize = CGSize(width: 64.0, height: 26.0)
    private let titleView: CalendarTimelineIndicatorTitleView = {
        let titleView = CalendarTimelineIndicatorTitleView()
        return titleView
    }()
    
    private let separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(value: 4.0)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        addSubview(separatorLineView)
        addSubview(titleView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = layoutFrame()
        titleView.size = titleViewSize
        titleView.left = layoutFrame.minX
        titleView.alignVerticalCenter()
        
        separatorLineView.width = layoutFrame.width - titleView.halfWidth
        separatorLineView.height = 1.0
        separatorLineView.left = titleView.centerX
        separatorLineView.alignVerticalCenter()
    }
}

class CalendarTimelineIndicatorTitleView: UIView {
    
    var title: String? {
        get {
            return timeLabel.text
        }
        
        set {
            timeLabel.text = newValue
        }
    }
    
    // 尖头宽度
    var arrowWidth: CGFloat = 24.0 {
        didSet {
            if arrowWidth != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var cornerRadius: CGFloat = 6.0 {
        didSet {
            if cornerRadius != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "00:00"
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let backgroundShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        layer.addSublayer(backgroundShapeLayer)
        addSubview(timeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupBackgroundShape()
        timeLabel.frame = bounds.inset(by: UIEdgeInsets(left: cornerRadius, right: arrowWidth))
    }
    
    private func setupBackgroundShape() {
        let path = UIBezierPath()
        // 获取视图的尺寸
        let width = bounds.width
        let height = bounds.height
        
        // 绘制左上圆角
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi, clockwise: false)

        // 绘制左下圆角
        path.addLine(to: CGPoint(x: 0, y: height - cornerRadius))
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 0.5, clockwise: false)
          
        
        // 绘制右下到尖头的三阶贝塞尔曲线
        path.addLine(to: CGPoint(x: width - arrowWidth, y: height))
        path.addCurve(to: CGPoint(x: width, y: height / 2),
                      controlPoint1: CGPoint(x: width - arrowWidth / 2, y: height),
                      controlPoint2: CGPoint(x: width - arrowWidth / 2, y: height / 2))
        
        // 绘制尖头到右上的三阶贝塞尔曲线
        path.addCurve(to: CGPoint(x: width - arrowWidth, y: 0),
                      controlPoint1: CGPoint(x: width - arrowWidth / 2, y: height / 2),
                      controlPoint2: CGPoint(x: width - arrowWidth / 2, y: 0))
        
        // 绘制右上到左上的直线
        path.addLine(to: CGPoint(x: cornerRadius, y: 0))
        
        // 设置路径到背景形状图层
        backgroundShapeLayer.path = path.cgPath
        backgroundShapeLayer.fillColor = UIColor.red.cgColor
        backgroundShapeLayer.strokeColor = UIColor.clear.cgColor
    }
}
