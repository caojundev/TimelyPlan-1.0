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
    
    let contentView = UIView()
    
    private let lineLayer = CALayer()
    
    private var style: TimeLineNodeStyle = .independent
    
    // MARK: 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(lineLayer)
        addSubview(contentView)
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
        case .connectToPrevious:
            contentFrame.size.height = bounds.height - margin
            lineFrame.origin.y = bounds.height / 2.0
            lineFrame.size.height = bounds.height / 2.0
        case .connectToNext:
            contentFrame.origin.y = margin
            contentFrame.size.height = bounds.height - margin
            lineFrame.size.height = bounds.height / 2.0
        case .connectToBoth:
            lineFrame.size.height = 0.0
        }
        
        contentView.frame = contentFrame
        executeWithoutAnimation {
            self.lineLayer.frame = lineFrame
        }
    }
    
    // MARK: 配置方法
    
    /// 应用节点样式（圆角配置）
    func applyNodeStyle(_ style: TimeLineNodeStyle) {
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

    /// 配置背景颜色
    func configureBackgroundColor(_ color: UIColor) {
        lineLayer.backgroundColor = color.cgColor
        contentView.backgroundColor = color
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: TimelineConfig.centerNodeWidth, height: size.height)
    }
}

class TimelineIconNodeView: TimelineNodeView {
    
    // MARK: 子视图
    let iconImageView = UIImageView()

    override func setupView() {
        super.setupView()
        
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
    }
    
    /// 配置图标
    func configureIcon(_ icon: UIImage?) {
        iconImageView.image = icon
    }
    
    // MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.frame = CGRect(
            x: 0,
            y: (contentView.height - TimelineConfig.iconSize) / 2,
            width: TimelineConfig.centerNodeWidth,
            height: TimelineConfig.iconSize
        )
    }
    
}
