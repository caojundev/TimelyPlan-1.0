//
//  TodoMultiDateInfoEditor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/21.
//

import Foundation

class TodoMultiDateInfoEditor: TodoDateInfoEditable {
    
    var dateInfo: TaskDateInfo
    
    init(dateInfo: TaskDateInfo) {
        self.dateInfo = dateInfo
    }
    
    func setDate(_ date: Date, editType: DateRangeEditType) {
        if editType == .start {
            setStartDate(date)
        } else {
            setEndDate(date)
        }
    }
    
    private func setStartDate(_ date: Date) {
        var startDate = dateInfo.startDate
        startDate = date.dateByReplacingTime(with: startDate)
        
        var endDate = dateInfo.endDate
        if startDate > endDate {
            endDate = startDate
        }
        
        let days = Date.days(fromDate: startDate, toDate: endDate)
        if days < 1 {
            endDate = startDate.dateByReplacingTime(with: endDate)
            endDate = endDate.dateByAddingDays(1)!
        }
        
        let isAllDay = dateInfo.isAllDay
        if isAllDay {
            startDate = startDate.startOfDay()
            endDate = endDate.endOfDay()
        }
        
        self.dateInfo = TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: isAllDay)
    }
    
    private func setEndDate(_ date: Date) {
        var startDate = dateInfo.startDate
        var endDate = dateInfo.endDate
        endDate = date.dateByReplacingTime(with: endDate)
    
        if endDate < startDate {
            startDate = endDate
        }
        
        let days = Date.days(fromDate: startDate, toDate: endDate)
        if days < 1 {
            /// 调整开始日期
            startDate = endDate.dateByReplacingTime(with: startDate)
            startDate = startDate.dateByAddingDays(-1)!
        }
        
        let isAllDay = dateInfo.isAllDay
        if isAllDay {
            startDate = startDate.startOfDay()
            endDate = endDate.endOfDay()
        }
        
        self.dateInfo = TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: isAllDay)
    }
    
    func setSpecificTime(date: Date, editType: DateRangeEditType) {
        var startDate = dateInfo.startDate
        var endDate = dateInfo.endDate
        var isAllDay = dateInfo.isAllDay
        if isAllDay {
            isAllDay = false
            startDate = startDate.date(withHour: 9, minute: 0)!
            endDate = endDate.date(withHour: 18, minute: 0)!
        }
        
        if editType == .start {
            startDate = startDate.dateByReplacingTime(with: date)
        } else {
            endDate = endDate.dateByReplacingTime(with: date)
        }
        
        self.dateInfo = TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: isAllDay)
    }
    
    func clearSpecificTime() {
        let isAllDay = true
        let startDate = dateInfo.startDate.startOfDay()
        let endDate = dateInfo.endDate.endOfDay()
        self.dateInfo = TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: isAllDay)
    }
}
