//
//  TimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

class TimelineCell: UICollectionViewCell {
    
    weak var delegate: AnyObject?
    
    // MARK: 基类控件
    let startTimeLabel = UILabel()
    
    var nodeView: TimelineNodeView!
    
    // MARK: 事件内容容器（子类在此添加内容）
    let eventContentView = UIView()
    
    private var currentItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupBaseUI() {
        setupNodeView()
        backgroundColor = .clear
        
        startTimeLabel.font = TimelineConfig.timeFont
        startTimeLabel.textColor = TimelineConfig.timeColor
        startTimeLabel.textAlignment = .right
        
        eventContentView.backgroundColor = .clear
        
        contentView.addSubview(startTimeLabel)
        contentView.addSubview(nodeView)
        contentView.addSubview(eventContentView)
        setupEventContentSubviews()
    }
    
    func setupNodeView() {
        nodeView = TimelineNodeView()
    }
    
    func setupEventContentSubviews() {
        
    }
    
    /// 配置基类公共属性
    func configure(with item: TimelineItem) {
        self.currentItem = item
        
        startTimeLabel.text = item.timeStart
        nodeView.configureBackgroundColor(item.nodeColor)
    
        // 应用节点样式
        nodeView.applyNodeStyle(item.nodeStyle)
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let verticalCenterY = bounds.height / 2
        let centerX = TimelineConfig.leftTimeWidth + TimelineConfig.margin + 8
        
        // 时间标签
        startTimeLabel.sizeToFit()
        startTimeLabel.frame = CGRect(
            x: 0,
            y: verticalCenterY - startTimeLabel.bounds.height / 2,
            width: TimelineConfig.leftTimeWidth,
            height: startTimeLabel.bounds.height
        )
        
        // 节点视图（高度随 cell 高度变化）
        nodeView.frame = CGRect(
            x: centerX,
            y: 0,
            width: TimelineConfig.centerNodeWidth,
            height: bounds.height
        )
        
        // 事件内容区域
        let eventContentX = centerX + TimelineConfig.centerNodeWidth + 12
        let eventContentWidth = bounds.width - eventContentX - TimelineConfig.margin
        eventContentView.frame = CGRect(
            x: eventContentX,
            y: 0,
            width: eventContentWidth,
            height: bounds.height
        )
    }
}

// MARK: - 带图标的简单时间线 Cell

class TimelineIconCell: TimelineCell {
    
    let iconNodeView = TimelineIconNodeView()
    
    override func setupNodeView() {
        self.nodeView = iconNodeView
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        // 可以在这里添加额外配置
    }
}
