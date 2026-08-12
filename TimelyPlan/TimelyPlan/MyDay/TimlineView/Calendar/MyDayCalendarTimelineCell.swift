//
//  MyDayCalendarTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/11.
//

import Foundation
import UIKit
import EventKit

class MyDayCalendarTimelineCell: TimelineIconCell {

    private(set) var calendarItem: TimelineItem?

    private let infoViewHeight = 50.0
    
    private lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = MyDayTimelineConfig.titleFont
        view.titleConfig.textColor = .label
        view.titleConfig.numberOfLines = 1
        view.subtitleConfig.font = MyDayTimelineConfig.subtitleFont
        view.subtitleConfig.textColor = .secondaryLabel
        view.subtitleConfig.lineBreakMode = .byTruncatingMiddle
        return view
    }()
    
    override func setupEventContentSubviews() {
        let image = resGetImage("myDay_calendar_24")
        let icon = image?.withTintColor(.white)
        iconNodeView.configureIcon(icon)
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
        calendarItem = item
        infoView.title = item.event.title
        
        if let event = item.event.sourceItem as? EKEvent {
            var components: [ASAttributedString] = []
            components.append(event.calendar.title.attributedString)
            if event.hasRecurrenceRules, let indicator = repeatIndicator(color: .secondaryLabel) {
                components.append(indicator)
            }
            
            infoView.subtitle = components.joined(separator: " • ")
        }
        
        setNeedsLayout()
    }
    
    /// 我的一天图标信息
    func repeatIndicator(color: UIColor? = nil) -> ASAttributedString? {
        guard let image = resGetImage("myDay_repeat_24") else {
            return nil
        }
        
        return .string(image: image, imageSize: .size(4), imageColor: color)
    }
}

