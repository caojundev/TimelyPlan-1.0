//
//  WSMyDayTimelineConnectionView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 连接线行视图

/// 插件时间线的连接线行，移植自 `TimelineSolidConnectionCell`、
/// `TimelineDashedConnectionCell` 与 `TimelineOverlappingConnectionCell`，
/// 去掉添加 / 绑定按钮，仅保留线条、当前时间进度与重叠渐变。
class WSMyDayTimelineConnectionView: UIView, TimelineProgressUpdatable {
    
    /// 背景渐变层，负责连接线的底色
    private let backgroundGradientLayer = CAGradientLayer()
    
    /// 背景线条遮罩
    private let backgroundShapeLayer = CAShapeLayer()
    
    /// 进度渐变层
    private let progressGradientLayer = CAGradientLayer()
    
    /// 进度线条遮罩
    private let progressShapeLayer = CAShapeLayer()
    
    /// 连接线数据
    private var item: TimelineConnectionItem?
    
    /// 连接线样式
    private var style: TimelineConnectionStyle = .solid
    
    /// 上下溢出量，覆盖相邻行因像素取整产生的缝隙
    private let overscan: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        backgroundGradientLayer.mask = backgroundShapeLayer
        layer.addSublayer(backgroundGradientLayer)
        
        progressGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        progressGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        progressGradientLayer.mask = progressShapeLayer
        layer.addSublayer(progressGradientLayer)
        
        for shapeLayer in [backgroundShapeLayer, progressShapeLayer] {
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.black.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 配置
    /// 配置连接线
    func configure(with item: TimelineConnectionItem) {
        self.item = item
        self.style = item.style
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let lineWidth: CGFloat
        let dashPattern: [NSNumber]?
        switch item.style {
        case .solid:
            lineWidth = TimelineConfig.solidLineWidth
            dashPattern = nil
        case .dashed:
            lineWidth = TimelineConfig.dashedLineWidth
            dashPattern = TimelineConfig.dashedPattern
        case .overlapping:
            lineWidth = TimelineConfig.overlappingLineWidth
            dashPattern = nil
        }
        
        backgroundShapeLayer.lineWidth = lineWidth
        backgroundShapeLayer.lineDashPattern = dashPattern
        progressShapeLayer.lineWidth = lineWidth
        progressShapeLayer.lineDashPattern = dashPattern
        
        CATransaction.commit()
        
        setNeedsLayout()
    }
    
    // MARK: - TimelineProgressUpdatable
    func updateTimeProgress() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateBackgroundColors()
        updateProgressLayer()
        CATransaction.commit()
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        /// 上下各溢出 1pt，覆盖与相邻行之间因像素取整产生的缝隙
        let layerFrame = CGRect(x: 0.0,
                                y: -overscan,
                                width: bounds.width,
                                height: bounds.height + overscan * 2.0)
        backgroundGradientLayer.frame = layerFrame
        progressGradientLayer.frame = layerFrame
        
        let lineCenterX = TimelineConfig.centerNodeWidth / 2.0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineCenterX, y: 0.0))
        path.addLine(to: CGPoint(x: lineCenterX, y: layerFrame.height))
        backgroundShapeLayer.path = path.cgPath
        
        updateBackgroundColors()
        updateProgressLayer()
        
        CATransaction.commit()
    }
    
    /// 更新背景颜色
    private func updateBackgroundColors() {
        guard let item = item else {
            return
        }
        
        /// 底色固定为深色，避免浅色模式下未开始事项取到浅灰底色
        let backColor = WSMyDayTimelineLayoutManager.trackColor
        
        guard style == .overlapping else {
            backgroundGradientLayer.colors = [backColor.cgColor, backColor.cgColor]
            return
        }
        
        /// 重叠连接线按当前时间切换上下两段的颜色
        let currentDate = Date()
        let colors: [CGColor]
        if currentDate >= item.topDate && currentDate >= item.bottomDate {
            colors = [item.topColor.cgColor, item.bottomColor.cgColor]
        } else if currentDate >= item.topDate {
            colors = [item.topColor.cgColor, backColor.cgColor]
        } else if currentDate >= item.bottomDate {
            colors = [backColor.cgColor, item.bottomColor.cgColor]
        } else {
            colors = [backColor.cgColor, backColor.cgColor]
        }
        
        backgroundGradientLayer.colors = colors
    }
    
    /// 更新进度线条。重叠连接线只展示底色渐变，不再叠加进度
    private func updateProgressLayer() {
        guard style != .overlapping, let item = item else {
            progressShapeLayer.path = nil
            return
        }
        
        let currentDate = Date()
        let totalHeight = bounds.height
        let lineCenterX = TimelineConfig.centerNodeWidth / 2.0
        
        let progressEndY: CGFloat
        if currentDate >= item.bottomDate {
            progressEndY = totalHeight + overscan * 2.0
        } else if currentDate <= item.topDate {
            progressShapeLayer.path = nil
            return
        } else {
            let totalDuration = item.bottomDate.timeIntervalSince(item.topDate)
            guard totalDuration > 0.0 else {
                progressShapeLayer.path = nil
                return
            }
            
            progressEndY = overscan + totalHeight * CGFloat(currentDate.timeIntervalSince(item.topDate) / totalDuration)
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineCenterX, y: 0.0))
        path.addLine(to: CGPoint(x: lineCenterX, y: progressEndY))
        progressShapeLayer.path = path.cgPath
        
        progressGradientLayer.colors = [item.topColor.cgColor, item.bottomColor.cgColor]
    }
}
