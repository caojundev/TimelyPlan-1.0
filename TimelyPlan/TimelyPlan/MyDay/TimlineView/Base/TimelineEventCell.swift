//
//  TimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

protocol TimelineEventCellDelegate: AnyObject {
    /// 点击开始时间
    func timelineEventCellDidClickStartTime(_ cell: TimelineEventCell)
}

extension TimelineEventCellDelegate {
    func timelineEventCellDidClickStartTime(_ cell: TimelineEventCell) {}
}

class TimelineEventCell: UICollectionViewCell, TimelineProgressUpdatable {
    
    weak var delegate: AnyObject?
    
    // MARK: 基类控件
    private lazy var startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = TimelineConfig.timeFont
        label.textColor = TimelineConfig.timeColor
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var startTimeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(clickStartTime), for: .touchUpInside)
        return button
    }()
    
    var nodeView: TimelineNodeView!
    
    private lazy var durationLabel: TPLabel = {
        let durationLabel = TPLabel()
        durationLabel.edgeInsets = UIEdgeInsets(horizontal: 6.0, vertical: 2.0)
        durationLabel.font = TimelineConfig.durationFont
        durationLabel.textColor = TimelineConfig.durationColor
        durationLabel.textAlignment = .center
        durationLabel.layer.cornerRadius = TimelineConfig.durationCornerRadius
        durationLabel.layer.masksToBounds = true
        durationLabel.backgroundColor = TimelineConfig.durationBackgroundColor
        return durationLabel
    }()

    // MARK: 事件内容容器（子类在此添加内容）
    let eventContentView = UIView()
    
    private(set) var currentItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupBaseUI() {
        setupNodeView()
        backgroundColor = .clear
        eventContentView.backgroundColor = .clear
        contentView.addSubview(startTimeButton)
        contentView.addSubview(startTimeLabel)
        contentView.addSubview(nodeView)
        contentView.addSubview(durationLabel)
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
        currentItem = item
        nodeView.configure(with: item)
        if item.event.isAllDay {
            startTimeLabel.text = resGetString("All-Day")
        } else {
            startTimeLabel.text = item.startDate.timeString
        }
        
        configureDurationLabel(for: item.event)
        setNeedsLayout()
    }
    
    func configureDurationLabel(for event: MyDayEvent) {
        if event.isAllDay {
            durationLabel.text = nil
            durationLabel.isHidden = true
            return
        }
    
        durationLabel.isHidden = false
        
        let interval = event.endDate.timeIntervalSince(event.startDate)
        durationLabel.text = Duration(interval).localizedTitle
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let verticalCenterY = bounds.height / 2
        let nodeX = TimelineConfig.leftTimeWidth + TimelineConfig.margin + 8
        
        // 时间标签
        startTimeLabel.sizeToFit()
        startTimeLabel.frame = CGRect(
            x: (nodeX - startTimeLabel.width) / 2.0,
            y: verticalCenterY - startTimeLabel.halfHeight,
            width: TimelineConfig.leftTimeWidth,
            height: startTimeLabel.bounds.height
        )
        
        startTimeButton.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: nodeX,
            height: bounds.height
        )
        
        // 节点视图（高度随 cell 高度变化）
        nodeView.frame = CGRect(
            x: nodeX,
            y: 0,
            width: TimelineConfig.centerNodeWidth,
            height: bounds.height
        )
        
        let eventContentWidth = eventContentWidth()
        let eventContentHeight = eventContentHeight()
        let eventContentX = bounds.width - TimelineConfig.margin - eventContentWidth
        
        let eventContentY: CGFloat
        if !durationLabel.isHidden {
            durationLabel.sizeToFit()
            durationLabel.top = (bounds.height - durationLabel.height - eventContentHeight) / 2.0
            eventContentY = durationLabel.bottom + 8.0
        } else {
            durationLabel.size = .zero
            eventContentY = (bounds.height - eventContentHeight ) / 2.0
        }
        
        durationLabel.left = eventContentX
        
        eventContentView.frame = CGRect(
            x: eventContentX,
            y: eventContentY,
            width: eventContentWidth,
            height: eventContentHeight
        )
    }
    
    func eventContentWidth() -> CGFloat {
        let centerX = TimelineConfig.leftTimeWidth + TimelineConfig.margin + 8.0
        let eventContentX = centerX + TimelineConfig.centerNodeWidth + 12.0
        return bounds.width - eventContentX - TimelineConfig.margin
    }
    
    func eventContentHeight() -> CGFloat {
        return 60.0
    }
    
    /// 点击开始时间
    @objc func clickStartTime() {
        if let delegate = delegate as? TimelineEventCellDelegate {
            delegate.timelineEventCellDidClickStartTime(self)
        }
    }
    
    func updateTimeProgress() {
        nodeView.updateTimeProgress()
    }
}

// MARK: - 带图标的简单时间线 Cell

class TimelineIconCell: TimelineEventCell {
    
    let iconNodeView = TimelineIconNodeView()
    
    override func setupNodeView() {
        self.nodeView = iconNodeView
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        // 可以在这里添加额外配置
    }
}
