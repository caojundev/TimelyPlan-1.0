//
//  MyDayFocusTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

protocol MyDayFocusTimelineCellDelegate: TimelineEventCellDelegate {
    
    /// 点击开始专注
    func myDayFocusTimelineCellDidClickStart(_ cell: MyDayFocusTimelineCell)
}

class MyDayFocusTimelineCell: TimelineIconCell {

    private(set) var focusItem: TimelineItem?
    
    /// 开始按钮
    lazy var startButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(value: 10.0)
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.image = resGetImage("triangle_right_32")
        button.imageConfig.color = .label
        button.addTarget(self, action: #selector(clickStart(_:)), for: .touchUpInside)
        return button
    }()

    private let infoViewHeight = 50.0
    
    private lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = MyDayTimelineConfig.titleFont
        view.titleConfig.textColor = .label
        view.titleConfig.numberOfLines = 1
        view.subtitleConfig.font = MyDayTimelineConfig.subtitleFont
        view.subtitleConfig.textColor = .secondaryLabel
        return view
    }()
    
    override func setupEventContentSubviews() {
        infoView.rightAccessoryView = startButton
        infoView.rightAccessorySize = .mini
        infoView.rightAccessoryMargins = UIEdgeInsets(left: 6.0, right: 12.0)
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
        self.focusItem = item
        startButton.isHidden = item.startDate.isFutureDay
        
        let imageConfig = startButton.imageConfig
        imageConfig.color = item.nodeColor
        startButton.imageConfig = imageConfig
        
        guard let timer = item.event.sourceItem as? FocusTimer else {
            return
        }
    
        configureIcon(with: item, timer: timer)
        infoView.title = timer.displayName
        infoView.subtitle = timer.timerDescription
        setNeedsLayout()
    }
    
    /// 更新图标
    private func configureIcon(with item: TimelineItem, timer: FocusTimer) {
        let color: UIColor
        if item.startDate.isFutureDay {
            color = item.nodeColor
        } else {
            color = .white
        }
        
        let icon = timer.timerType.iconImage?.withTintColor(color)
        iconNodeView.configureIcon(icon)
    }

    @objc func clickStart(_ button: UIButton) {
        if let delegate = delegate as? MyDayFocusTimelineCellDelegate {
            delegate.myDayFocusTimelineCellDidClickStart(self)
        }
    }
}

