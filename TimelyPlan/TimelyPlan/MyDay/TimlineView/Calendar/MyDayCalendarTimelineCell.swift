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
            infoView.subtitle = event.calendar.title
        }
        
        setNeedsLayout()
    }
}

