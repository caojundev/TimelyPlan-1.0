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
    
    private let lineLayer = CALayer()
    
    private var style: TimeLineNodeStyle = .independent
    
    private var position: TimelineItemPosition = .middle
    
    var item: TimelineItem?
    
    let contentView = TimelineNodeProgressView()
    
    // MARK: 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(lineLayer)
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
        var lineFrame = CGRect(x: (bounds.width - TimelineConfig.solidLineWidth) / 2.0,
                               y: 0.0,
                               width: TimelineConfig.solidLineWidth,
                               height: bounds.height)
        switch style {
        case .independent:
            contentFrame.origin.y = margin
            contentFrame.size.height = bounds.height - 2 * margin
            if position == .first {
                lineFrame.origin.y = bounds.height / 2.0
                lineFrame.size.height = bounds.height / 2.0
            } else if position == .last {
                lineFrame.size.height = bounds.height / 2.0
            } else if position == .only {
                lineFrame.size.height = .zero
            }
        case .connectToPrevious:
            contentFrame.size.height = bounds.height - margin
            if position == .last {
                lineFrame.size.height = 0.0
            } else {
                lineFrame.origin.y = bounds.height / 2.0
                lineFrame.size.height = bounds.height / 2.0
            }
        case .connectToNext:
            contentFrame.origin.y = margin
            contentFrame.size.height = bounds.height - margin
            if position == .first {
                lineFrame.size.height = 0.0
            } else {
                lineFrame.size.height = bounds.height / 2.0
            }
        case .connectToBoth:
            lineFrame.size.height = 0.0
        }
        
        contentView.frame = contentFrame

        executeWithoutAnimation {
            self.lineLayer.frame = lineFrame
        }
        
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
    
    private func updateNodeColor() {
        guard let item = item else {
            return
        }

        if item.startDate.isToday {
            configureBackgroundColor(TimelineConfig.todayNodeBackgroundColor)
        } else if item.startDate.isFutureDay {
            configureBackgroundColor(TimelineConfig.futureNodeBackgroundColor)
        } else {
            configureBackgroundColor(item.nodeColor)
        }
    }
    
    /// 配置背景颜色
    func configureBackgroundColor(_ color: UIColor) {
        contentView.backgroundColor = color
        executeWithoutAnimation {
            self.lineLayer.backgroundColor = color.cgColor
        }
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
        guard let item = self.item else {
            return
        }
    
        let progress = calculateProgress(currentDate: .now,
                                         startDate: item.startDate,
                                         endDate: item.endDate)
        
        var gradientFrame = bounds
        gradientFrame.size.height = bounds.height + transitionHeight
        if progress == 0.0 {
            gradientFrame.origin.y = -gradientFrame.size.height
        } else {
            gradientFrame.origin.y = (progress - 1.0) * bounds.height
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
        let toColor = fromColor.withAlphaComponent(0.0)
    
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
