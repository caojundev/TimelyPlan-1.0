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
        infoView.titleConfig.font = .boldSystemFont(ofSize: 15.0)
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
        guard let event = event, let date = date else {
            return
        }

        let allDayString = resGetString("All day")
        var infos = [String]()
        if event.spansMultipleDays {
            /// 横跨多天
            if date.isInSameDayAs(event.startDate) {
                if event.startDate.isStartOfDay {
                    infos.append(allDayString)
                } else {
                    infos.append(event.startDate.timeString)
                }
            } else if date.isInSameDayAs(event.endDate) {
                if event.startDate.isEndOfDay {
                    infos.append(allDayString)
                } else {
                    let format = resGetString("Until %@")
                    let endString = String(format: format, event.endDate.timeString)
                    infos.append(endString)
                }
            } else {
                /// 非开始和结束日，显示全天
                infos.append(allDayString)
            }
  
            let index = event.getDayIndex(targetDate: date) + 1
            let spanDays = event.spanDays
            if index > 0, spanDays > 0 {
                let indexFormat = resGetString("Day %ld/%ld")
                let indexString = String(format: indexFormat, index, spanDays)
                infos.append(indexString)
            }
        } else {
            /// 单日
            if event.isAllDay {
                infos.append(allDayString)
            } else {
                let timeString = "\(event.startDate.timeString) - \(event.endDate.timeString)"
                infos.append(timeString)
            }
        }

        eventInfoView.subtitle = infos.joined(separator: " • ")
    }
}
