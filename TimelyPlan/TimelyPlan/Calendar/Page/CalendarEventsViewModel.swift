//
//  CalendarEventsViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

class CalendarEventsViewModel {

    /// 当前日期范围事项改变
    var onEventsChanged: (() -> Void)?

    private(set) var range: DateInterval?
    
    /// 所有事件
    private(set) var events: [CalendarEvent]?

    private let requestManager = TPRequestManager()
    
    private let repository: CalendarRepository
    
    init() {
        self.repository = CalendarRepository()
    }

    func refresh() {
        guard let range = range else {
            return
        }

        loadEvents(in: range)
    }
    
    func loadEvents(in range: DateInterval) {
        self.range = range
        let requestID = requestManager.executeRequest()
        repository.fetchEvents(in: range) { [weak self] events in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            self.events = events
            self.onEventsChanged?()
        }
    }
}
