//
//  TodoSingleDateInfoEditor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/21.
//

import Foundation

class TodoSingleDateInfoEditor {
    
    private(set) var dateInfo: TaskDateInfo
    
    init(dateInfo: TaskDateInfo) {
        self.dateInfo = dateInfo
    }
    
    func setDate(_ date: Date, editType: DateRangeEditType) {
        let duration = dateInfo.duration
        var startDate = dateInfo.startDate
        var endDate = dateInfo.endDate
        if editType == .start {
            startDate = date.dateByReplacingTime(with: startDate)
            endDate = startDate.dateByAddingSeconds(duration)!
            if !endDate.isInSameDayAs(startDate) {
                endDate = startDate.endOfDay()
            }
        } else {
            endDate = date.dateByReplacingTime(with: endDate)
            startDate = endDate.dateByAddingSeconds(-duration)!
            if !startDate.isInSameDayAs(endDate) {
                startDate = endDate.startOfDay()
            }
        }
        
        self.dateInfo = TaskDateInfo(startDate: startDate,
                                     endDate: endDate,
                                     isAllDay: dateInfo.isAllDay)
    }

    func setSpecificTime(date: Date, editType: DateRangeEditType) {
        var duration = dateInfo.duration
        var isAllDay = dateInfo.isAllDay
        if isAllDay {
            /// 全天切换到具体时间默认持续时间为 1 分钟
            duration = SECONDS_PER_MINUTE
            isAllDay = false
        }
        
        var startDate = dateInfo.startDate
        var endDate = dateInfo.endDate
        if editType == .start {
            startDate = startDate.dateByReplacingTime(with: date)
            endDate = startDate.dateByAddingSeconds(duration)!
            if !endDate.isInSameDayAs(startDate) {
                endDate = startDate.endOfDay()
            }
        } else {
            endDate = endDate.dateByReplacingTime(with: date)
            startDate = endDate.dateByAddingSeconds(-duration)!
            if !startDate.isInSameDayAs(endDate) {
                startDate = endDate.startOfDay()
            }
        }
        
        self.dateInfo = TaskDateInfo(startDate: startDate,
                                     endDate: endDate,
                                     isAllDay: isAllDay)
    }
    
    func clearSpecificTime() {
        let isAllDay = true
        let startDate = dateInfo.startDate.startOfDay()
        let endDate = dateInfo.startDate.endOfDay()
        self.dateInfo = TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: isAllDay)
    }

    func setDuration(_ duration: Duration) {
        let startDate = dateInfo.startDate
        var endDate = startDate.dateByAddingSeconds(duration)!
        if !endDate.isInSameDayAs(startDate) {
            endDate = startDate.endOfDay()
        }
        
        self.dateInfo = TaskDateInfo(startDate: startDate,
                                     endDate: endDate,
                                     isAllDay: dateInfo.isAllDay)
    }

    func clearDuration() {
        clearSpecificTime()
    }

}
