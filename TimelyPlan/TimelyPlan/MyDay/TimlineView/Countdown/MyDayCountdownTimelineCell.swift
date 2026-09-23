//
//  MyDayCountdownTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/23.
//

import Foundation
import UIKit

class MyDayCountdownTimelineCell: TimelineEventCell {
    
    private var countdownItem: TimelineItem?
    
    private let iconNodeView = CountdownTimelineNodeView()
    
    private let infoViewHeight = 50.0
    
    private lazy var infoView: MyDayCountdownEventInfoView = {
        let view = MyDayCountdownEventInfoView()
        return view
    }()
    
    override func setupNodeView() {
        self.nodeView = iconNodeView
    }
    
    override func setupEventContentSubviews() {
        eventContentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = eventContentView.bounds
    }
    
    override func eventContentHeight() -> CGFloat {
        return infoViewHeight
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        countdownItem = item
        
        guard let event = item.event.sourceItem as? CountdownEvent else {
            return
        }
        
        configureNode(with: item, event: event)
        infoView.title = item.event.title
        infoView.subtitle = event.myDayDetail(on: item.startDate)
        setNeedsLayout()
    }
    
    /// 更新节点（展示表情）
    private func configureNode(with item: TimelineItem, event: CountdownEvent) {
        iconNodeView.configure(icon: TPIcon(text: event.emoji ?? event.type.emoji))
    }
}

/// 倒数日事项时间线节点（展示表情，类似 HabitTimelineNodeView）
class CountdownTimelineNodeView: TimelineNodeView {
    
    let iconSize = CGSize(width: 32.0, height: 32.0)
    
    /// 表情图标视图
    lazy var iconView: TPIconView = {
        let view = TPIconView()
        view.borderWidth = 0.0
        view.size = iconSize
        view.cornerRadius = iconSize.halfHeight
        view.backColor = .clear
        view.font = UIFont.systemFont(ofSize: 18.0)
        return view
    }()
    
    override func setupView() {
        addSubview(iconView)
    }
    
    // MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.frame = CGRect(
            x: (width - iconSize.width) / 2,
            y: contentView.centerY - iconSize.height / 2.0,
            width: iconSize.width,
            height: iconSize.height
        )
    }
    
    func configure(icon: TPIcon) {
        iconView.icon = icon
    }
}
