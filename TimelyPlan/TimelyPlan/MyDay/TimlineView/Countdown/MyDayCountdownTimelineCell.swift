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
    
    /// 数值视图最大宽度
    private let valueViewMaximumWidth: CGFloat = 80.0
    
    /// 信息视图与数值视图的间距
    private let infoValueMargin: CGFloat = 8.0
    
    private lazy var infoView: MyDayCountdownEventInfoView = {
        let view = MyDayCountdownEventInfoView()
        return view
    }()
    
    /// 数值视图（显示剩余数目）
    private let valueView: CountdownVerticalValueView = {
        let view = CountdownVerticalValueView()
        view.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        view.subtitleConfig.font = .boldSystemFont(ofSize: 14.0)
        return view
    }()
    
    override func setupNodeView() {
        self.nodeView = iconNodeView
    }
    
    override func setupEventContentSubviews() {
        eventContentView.addSubview(infoView)
        eventContentView.addSubview(valueView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentBounds = eventContentView.bounds
        
        /// 数值视图：靠右、宽度按内容自适应并限制最大宽度，高度撑满内容区
        let availableValueWidth = max(0.0, contentBounds.width - infoValueMargin)
        let valueFitSize = valueView.sizeThatFits(CGSize(width: availableValueWidth,
                                                        height: contentBounds.height))
        let valueWidth = min(valueFitSize.width, valueViewMaximumWidth, availableValueWidth)
        valueView.frame = CGRect(x: contentBounds.maxX - valueWidth,
                                 y: contentBounds.minY,
                                 width: valueWidth,
                                 height: contentBounds.height)
        
        /// 信息视图：占据左侧剩余空间（无数值时占满整行）
        let infoWidth: CGFloat
        if valueWidth > 0.0 {
            infoWidth = max(0.0, valueView.left - infoValueMargin - contentBounds.minX)
        } else {
            infoWidth = contentBounds.width
        }
        infoView.frame = CGRect(x: contentBounds.minX,
                                y: contentBounds.minY,
                                width: infoWidth,
                                height: contentBounds.height)
    }
    
    override func eventContentHeight() -> CGFloat {
        return infoViewHeight
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        countdownItem = item
        
        guard let event = item.event.sourceItem as? CountdownEvent else {
            /// 复用时清空数值，避免残留上一次的内容
            valueView.title = nil
            valueView.subtitle = nil
            return
        }
        
        configureNode(with: item, event: event)
        infoView.title = item.event.title
        infoView.subtitle = event.myDayDetail(on: item.startDate)
        
        let timeResult = event.remainingTimeResult(with: item.startDate)
        valueView.setResult(timeResult)
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
