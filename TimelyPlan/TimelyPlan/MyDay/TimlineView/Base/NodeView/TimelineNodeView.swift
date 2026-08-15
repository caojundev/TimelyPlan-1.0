//
//  TimelineNodeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

// MARK: - 时间线节点容器组件
/// 时间线节点视图组件（可复用的节点容器）
class TimelineNodeView: UIView {
    
    private let topLineLayer = CALayer()
    private let bottomLineLayer = CALayer()
    
    private var style: TimeLineNodeStyle = .independent
    
    private var position: TimelineItemPosition = .middle
    
    var item: TimelineItem?
    
    let contentView = TimelineNodeProgressView()
    
    // MARK: 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(topLineLayer)
        layer.addSublayer(bottomLineLayer)
        addSubview(contentView)
        contentView.clipsToBounds = true
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupView() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margin = 10.0
        var contentFrame = bounds
        
        // 设置线条的固定位置
        let lineX = (bounds.width - TimelineConfig.solidLineWidth) / 2.0
        let lineWidth = TimelineConfig.solidLineWidth
        
        // 上半部分线条（从顶部到中间）
        let topLineFrame = CGRect(x: lineX,
                                  y: 0.0,
                                  width: lineWidth,
                                  height: bounds.height / 2.0)
        
        // 下半部分线条（从中间到底部）
        let bottomLineFrame = CGRect(x: lineX,
                                     y: bounds.height / 2.0,
                                     width: lineWidth,
                                     height: bounds.height / 2.0)
        
        // 根据样式和位置调整内容区域
        switch style {
        case .independent:
            contentFrame.origin.y = margin
            contentFrame.size.height = bounds.height - 2 * margin
        case .connectToPrevious:
            contentFrame.size.height = bounds.height - margin
        case .connectToNext:
            contentFrame.origin.y = margin
            contentFrame.size.height = bounds.height - margin
        case .connectToBoth:
            // 内容占据整个区域
            break
        }
        
        contentView.frame = contentFrame

        executeWithoutAnimation {
            self.topLineLayer.frame = topLineFrame
            self.bottomLineLayer.frame = bottomLineFrame
        }
        
        updateLineVisibility()
        updateNodeColor()
    }
    
    // MARK: 配置方法
    func configure(with item: TimelineItem) {
        self.item = item
        position = item.position
        applyNodeStyle(item.nodeStyle)
        contentView.configure(with: item)
        setNeedsLayout()
    }
    
    func updateTimeProgress() {
        contentView.updateTimeProgress()
        updateLineVisibility()
        updateNodeColor()
    }
    
    /// 更新线条显示状态
    private func updateLineVisibility() {
        // 根据样式决定线条的显示
        switch style {
        case .independent:
            // 独立节点：根据位置显示线条
            switch position {
            case .first:
                topLineLayer.isHidden = true
                bottomLineLayer.isHidden = false
            case .last:
                topLineLayer.isHidden = false
                bottomLineLayer.isHidden = true
            case .only:
                topLineLayer.isHidden = true
                bottomLineLayer.isHidden = true
            case .middle:
                topLineLayer.isHidden = false
                bottomLineLayer.isHidden = false
            }
            
        case .connectToPrevious:
            // 连接到上一个节点：只显示下半部分线条
            topLineLayer.isHidden = true
            if position == .last {
                bottomLineLayer.isHidden = true
            } else {
                bottomLineLayer.isHidden = false
            }
            
        case .connectToNext:
            // 连接到下一个节点：只显示上半部分线条
            bottomLineLayer.isHidden = true
            if position == .first {
                topLineLayer.isHidden = true
            } else {
                topLineLayer.isHidden = false
            }
            
        case .connectToBoth:
            // 同时连接到上下节点：不显示线条
            topLineLayer.isHidden = true
            bottomLineLayer.isHidden = true
        }
    }
    
    private func updateNodeColor() {
        guard let item = item else {
            return
        }

        let backgroundColor: UIColor
        if item.startDate.isToday {
            backgroundColor = TimelineConfig.todayNodeBackgroundColor
        } else if item.startDate.isFutureDay {
            backgroundColor = TimelineConfig.futureNodeBackgroundColor
        } else {
            backgroundColor = item.nodeColor

        }
        
        configureBackgroundColor(backgroundColor)
        
        var topLineColor = backgroundColor
        var bottomLineColor = backgroundColor
        let currentDate = Date()
        if currentDate >= item.startDate {
            topLineColor = item.nodeColor
        }
        
        if currentDate >= item.endDate {
            bottomLineColor = item.nodeColor
        }
        
        executeWithoutAnimation {
            self.topLineLayer.backgroundColor = topLineColor.cgColor
            self.bottomLineLayer.backgroundColor = bottomLineColor.cgColor
        }
    }
    
    /// 配置背景颜色
    func configureBackgroundColor(_ color: UIColor) {
        contentView.backgroundColor = color
    }
    
    /// 应用节点样式（圆角配置）
    private func applyNodeStyle(_ style: TimeLineNodeStyle) {
        self.style = style
        contentView.layer.maskedCorners = []
        
        switch style {
        case .independent:
            contentView.layer.cornerRadius = TimelineConfig.centerNodeWidth / 2
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                               .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .connectToPrevious:
            contentView.layer.cornerRadius = TimelineConfig.centerNodeWidth / 2
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .connectToNext:
            contentView.layer.cornerRadius = TimelineConfig.centerNodeWidth / 2
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .connectToBoth:
            contentView.layer.cornerRadius = 0
        }
        
        setNeedsLayout()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: TimelineConfig.centerNodeWidth, height: size.height)
    }
}

class TimelineNodeProgressView: UIView {
    
    private(set) var item: TimelineItem?
    
    private let gradientLayer = CAGradientLayer()
    
    /// 底部过渡效果的高度，默认20pt
    var transitionHeight: CGFloat = 20.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutGradientLayer()
    }
    
    func updateTimeProgress() {
        layoutGradientLayer()
    }
    
    private func layoutGradientLayer() {
        guard let item = self.item else {
            return
        }
    
        let progress = calculateProgress(currentDate: .now,
                                         startDate: item.startDate,
                                         endDate: item.endDate)
        
        var gradientFrame = bounds
        if progress == 0.0 {
            gradientFrame.origin.y = -gradientFrame.size.height
        } else {
            var progressHeight = progress * bounds.height
            if progressHeight < transitionHeight {
                progressHeight = transitionHeight
            }
            
            gradientFrame.origin.y = progressHeight - bounds.height
        }
        
        // 计算过渡区域在渐变中的位置
        // 如果视图高度小于等于过渡高度，整个视图都是过渡效果
        let transitionRatio: CGFloat
        if gradientFrame.height > transitionHeight {
            transitionRatio = transitionHeight / gradientFrame.height
        } else {
            transitionRatio = 1.0
        }
        
        // 设置渐变的颜色位置
        // 从顶部到 (1 - transitionRatio) 处保持纯色
        // 从 (1 - transitionRatio) 到底部进行渐变过渡
        let startTransitionPoint = 1.0 - transitionRatio
        let fromColor = item.nodeColor
        let toColor: UIColor
        if progress == 1.0 {
            toColor = fromColor
        } else {
            toColor = fromColor.withAlphaComponent(0.0)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = gradientFrame
        gradientLayer.colors = [
            fromColor.cgColor,
            fromColor.cgColor,
            toColor.cgColor
        ]
        gradientLayer.locations = [
            0.0,
            NSNumber(value: startTransitionPoint),
            1.0
        ]
        CATransaction.commit()
    }
    
    /// 配置连接线（子类可重写）
    // MARK: 配置方法
    func configure(with item: TimelineItem) {
        self.item = item
        setNeedsLayout()
    }
    
    /// 计算当前日期在事项日期范围内的进度
    /// - Parameters:
    ///   - currentDate: 当前日期
    ///   - startDate: 事项开始日期
    ///   - endDate: 事项结束日期
    /// - Returns: 进度值（0.0 - 1.0），0表示未开始，1表示已完成
    private func calculateProgress(currentDate: Date, startDate: Date, endDate: Date) -> Double {
        // 如果当前日期早于开始日期，进度为0
        if currentDate < startDate {
            return 0.0
        }
        
        // 如果当前日期晚于结束日期，进度为1
        if currentDate > endDate {
            return 1.0
        }
        
        // 计算总时间间隔
        let totalDuration = endDate.timeIntervalSince(startDate)
        
        // 如果总时间间隔为0或负数，返回0
        guard totalDuration > 0 else {
            return 0.0
        }
        
        // 计算已经过的时间
        let elapsedTime = currentDate.timeIntervalSince(startDate)
        
        // 计算并返回进度
        return min(max(elapsedTime / totalDuration, 0.0), 1.0)
    }
}
