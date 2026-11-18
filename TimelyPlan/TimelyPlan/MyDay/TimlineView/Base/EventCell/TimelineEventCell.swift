//
//  TimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

protocol MyDayTimelineEventCellDelegate: AnyObject {
    /// 点击开始时间
    func timelineEventCellDidClickTime(_ cell: MyDayTimelineEventCell)
}

extension MyDayTimelineEventCellDelegate {
    func timelineEventCellDidClickTime(_ cell: MyDayTimelineEventCell) {}
}

class MyDayTimelineEventCell: UICollectionViewCell, MyDayTimelineProgressUpdatable {
    
    weak var delegate: AnyObject?
    
    private lazy var timeView: MyDayTimelineEventTimeView = {
        let view = MyDayTimelineEventTimeView()
        view.onClickTime = { [weak self] in
            self?.clickTime()
        }
        
        return view
    }()
    
    var nodeView: MyDayTimelineNodeView!
    
    private lazy var durationLabel: TPLabel = {
        let durationLabel = TPLabel()
        durationLabel.edgeInsets = UIEdgeInsets(horizontal: 6.0, vertical: 2.0)
        durationLabel.font = MyDayTimelineStyle.durationFont
        durationLabel.textColor = MyDayTimelineStyle.durationColor
        durationLabel.textAlignment = .center
        durationLabel.layer.cornerRadius = MyDayTimelineStyle.durationCornerRadius
        durationLabel.layer.masksToBounds = true
        durationLabel.backgroundColor = MyDayTimelineStyle.durationBackgroundColor
        return durationLabel
    }()

    // MARK: 事件内容容器（子类在此添加内容）
    let eventContentView = UIView()
    
    private(set) var currentItem: MyDayTimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupBaseUI() {
        setupNodeView()
        backgroundColor = .clear
        eventContentView.backgroundColor = .clear
        contentView.addSubview(timeView)
        contentView.addSubview(nodeView)
        contentView.addSubview(durationLabel)
        contentView.addSubview(eventContentView)
        setupEventContentSubviews()
    }
    
    func setupNodeView() {
        nodeView = MyDayTimelineNodeView()
    }
    
    func setupEventContentSubviews() {
        
    }
    
    /// 配置基类公共属性
    func configure(with item: MyDayTimelineItem) {
        currentItem = item
        nodeView.configure(with: item)
        timeView.configure(with: item)
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
        let nodeX = MyDayTimelineStyle.leftTimeWidth + MyDayTimelineStyle.margin + 8

        timeView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: nodeX,
            height: bounds.height
        )
        
        // 节点视图（高度随 cell 高度变化）
        nodeView.frame = CGRect(
            x: nodeX,
            y: 0,
            width: MyDayTimelineStyle.centerNodeWidth,
            height: bounds.height
        )
        
        let eventContentWidth = eventContentWidth()
        let eventContentHeight = eventContentHeight()
        let eventContentX = bounds.width - MyDayTimelineStyle.margin - eventContentWidth
        
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
        let centerX = MyDayTimelineStyle.leftTimeWidth + MyDayTimelineStyle.margin + 8.0
        let eventContentX = centerX + MyDayTimelineStyle.centerNodeWidth + 12.0
        return bounds.width - eventContentX - MyDayTimelineStyle.margin
    }
    
    func eventContentHeight() -> CGFloat {
        return 60.0
    }
    
    /// 点击开始时间
    @objc func clickTime() {
        if let delegate = delegate as? MyDayTimelineEventCellDelegate {
            delegate.timelineEventCellDidClickTime(self)
        }
    }
    
    func updateTimeProgress() {
        nodeView.updateTimeProgress()
        timeView.updateCurrentTime()
    }
}

// MARK: - 带图标的简单时间线 Cell

class MyDayTimelineIconCell: MyDayTimelineEventCell {
    
    let iconNodeView = MyDayTimelineIconNodeView()
    
    override func setupNodeView() {
        self.nodeView = iconNodeView
    }
    
    override func configure(with item: MyDayTimelineItem) {
        super.configure(with: item)
        // 可以在这里添加额外配置
    }
}
