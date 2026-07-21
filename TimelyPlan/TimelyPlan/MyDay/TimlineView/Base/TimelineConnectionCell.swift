//
//  TimelineConnectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

// MARK: - 连接线基类 Cell

class TimelineConnectionCell: UICollectionViewCell {
    
    let gradientLayer = CAGradientLayer()
    let shapeLayer = CAShapeLayer()
    
    // MARK: 连接线内容容器（子类在此添加内容）
    let connectionContentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        layer.speed = 0
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeLayer
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.speed = 0
        shapeLayer.speed = 0
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        // 添加连接线内容容器
        connectionContentView.backgroundColor = .clear
        contentView.addSubview(connectionContentView)
        setupConnectionContentSubviews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupConnectionContentSubviews() {
        
    }
    
    func layoutConnectionContentSubviews() {
        
    }
    
    /// 配置连接线（子类可重写）
    func configure(with item: TimelineConnectionItem) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.colors = [item.topColor.cgColor, item.bottomColor.cgColor]
        
        CATransaction.commit()
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.frame = bounds
        
        let lineCenterX = TimelineConfig.leftTimeWidth + TimelineConfig.margin + 8 + TimelineConfig.centerNodeWidth / 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineCenterX, y: 0))
        path.addLine(to: CGPoint(x: lineCenterX, y: bounds.height))
        shapeLayer.path = path.cgPath
        
        CATransaction.commit()
        
        // 布局连接线内容容器
        let contentX = lineCenterX + TimelineConfig.centerNodeWidth / 2 + 12
        let contentWidth = bounds.width - contentX - TimelineConfig.margin
        connectionContentView.frame = CGRect(
            x: contentX,
            y: 0,
            width: contentWidth,
            height: bounds.height
        )
        
        layoutConnectionContentSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.colors = nil
        shapeLayer.path = nil
        
        CATransaction.commit()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        super.apply(layoutAttributes)
        CATransaction.commit()
    }
}

// MARK: - 实线连接线 Cell

class TimelineSolidConnectionCell: TimelineConnectionCell {
    
    override func configure(with item: TimelineConnectionItem) {
        super.configure(with: item)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.lineWidth = TimelineConfig.solidLineWidth
        shapeLayer.lineDashPattern = nil
        
        CATransaction.commit()
    }
}

// MARK: - 虚线连接线 Cell

class TimelineDashedConnectionCell: TimelineConnectionCell {
    
    lazy var titleView: TPImageTitleView = {
        let view = TPImageTitleView()
        view.accessoryPosition = .left
        view.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        view.titleConfig.textAlignment = .left
        view.imageConfig.margins = UIEdgeInsets(right: 2.0)
        view.imageConfig.size = .size(3)
        view.imageConfig.shouldRenderImageWithColor = true
        view.imageConfig.color = .secondaryLabel
        view.titleConfig.textColor = .secondaryLabel
        return view
    }()
    
    override func setupConnectionContentSubviews() {
        connectionContentView.addSubview(titleView)
    }
    
    override func layoutConnectionContentSubviews() {
        titleView.width = connectionContentView.width
        titleView.height = 20.0
        titleView.alignVerticalCenter()
    }
    
    override func configure(with item: TimelineConnectionItem) {
        super.configure(with: item)
        if let interval = item.timeInterval, interval > 0 {
            titleView.title = Duration(interval).hourMinuteDurationString
        } else {
            titleView.title = nil
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.lineWidth = TimelineConfig.dashedLineWidth
        shapeLayer.lineDashPattern = TimelineConfig.dashedPattern
        
        CATransaction.commit()
    }
}

// MARK: - 重叠连接线 Cell

class TimelineOverlappingConnectionCell: TimelineConnectionCell {
    
    lazy var titleView: TPImageTitleView = {
        let view = TPImageTitleView()
        view.accessoryPosition = .left
        view.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        view.titleConfig.textAlignment = .left
        view.imageConfig.margins = UIEdgeInsets(right: 2.0)
        view.imageConfig.size = .size(3)
        view.imageConfig.shouldRenderImageWithColor = true
        view.imageConfig.color = .secondaryLabel
        view.titleConfig.textColor = .secondaryLabel
        view.image = resGetImage("myDay_overlapping_12")
        view.title = resGetString("Overlapping")
        return view
    }()
    
    override func setupConnectionContentSubviews() {
        connectionContentView.addSubview(titleView)
    }
    
    override func layoutConnectionContentSubviews() {
        titleView.width = connectionContentView.width
        titleView.height = 20.0
        titleView.alignVerticalCenter()
    }
    
    override func configure(with item: TimelineConnectionItem) {
        super.configure(with: item)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.lineWidth = TimelineConfig.overlappingLineWidth
        shapeLayer.lineDashPattern = nil
        
        CATransaction.commit()
    }
}
