//
//  CalendarEventsViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

class CalendarEventsViewModel: CalendarEventChangeDelegate {

    /// 当前日期范围事项改变
    var onEventsChanged: (() -> Void)?

    private(set) var range: DateInterval?
    
    /// 所有事件
    private(set) var events: [CalendarEvent]?

    private let requestManager = TPRequestManager()
    
    private let repository: CalendarRepository
    
    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            self.placeholderProvider.state = state
        }
    }
    
    private(set) var placeholderProvider = TPLoadableListPlaceholderProvider()
    
    init() {
        self.placeholderProvider.state = state
        self.repository = CalendarRepository()
        self.repository.addUpdater(self)
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
    
    // MARK: - CalendarEventChangeDelegate
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        guard let currentRange = self.range else {
            return
        }
        
        var shouldReload: Bool = false
        for range in ranges {
            if currentRange.intersects(range) {
                shouldReload = true
                break
            }
        }
        
        if shouldReload {
            loadEvents(in: currentRange)
        }
    }
}
