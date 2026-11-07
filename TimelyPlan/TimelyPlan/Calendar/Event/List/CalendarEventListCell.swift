//
//  CalendarEventListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/31.
//

import Foundation
import UIKit

class CalendarEventListCell: TPDefaultInfoTableCell {
    
    var date: Date?

    /// 副标题展示项，默认时间与来源都展示
    var detailOption: CalendarEventDetailOption = .all {
        didSet {
            updateSubtitle()
        }
    }
    
    var event: CalendarEvent? {
        didSet {
            updateEventInfo()
        }
    }
    
    lazy var eventInfoView: CalendarEventInfoView = {
        let view = CalendarEventInfoView()
        return view
    }()
    
    override func setupInfoView() {
        self.infoView = eventInfoView
        infoView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        infoView.subtitleConfig.font = .boldSystemFont(ofSize: 10.0)
        eventInfoView.strikethroughColor = infoView.titleConfig.textColor ?? .label
    }
    
    func updateEventInfo() {
        guard let event = event else {
            return
        }
        
        eventInfoView.color = event.color
        eventInfoView.title = event.title
        updateSubtitle()
        updateCompleted()
    }
    
    private func updateCompleted() {
        guard let task = event?.sourceItem as? TodoTask else {
            eventInfoView.setCompleted(false)
            return
        }

        eventInfoView.setCompleted(task.isCompleted)
    }
    
    private func updateSubtitle() {
        guard let event = event else {
            eventInfoView.subtitle = nil
            return
        }

        let provider = CalendarEventDetailProvider(event: event,
                                                   date: date,
                                                   option: detailOption)
        if let info = provider.info() {
            eventInfoView.subtitle = info
        } else {
            eventInfoView.subtitle = nil
        }
    }
}
