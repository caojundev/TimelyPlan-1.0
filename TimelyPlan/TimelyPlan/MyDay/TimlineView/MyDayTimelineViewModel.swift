//
//  MyDayTimelineViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/22.
//

import Foundation

class MyDayTimelineViewModel: MyDayEventChangeDelegate {

    /// 当前日期范围事项改变
    var onEventsChanged: (() -> Void)?

    /// 日期
    private(set) var date: Date?

    /// 所有事件
    private(set) var events: [MyDayEvent]?

    private let repository = MyDayRepository()

    private let requestManager = TPRequestManager()
    
    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            self.placeholderProvider.state = state
        }
    }
    
    private(set) var placeholderProvider = TPLoadableListPlaceholderProvider()
    
    init() {
        self.placeholderProvider.state = state
    }

    func clear() {
        date = nil
        events = nil
        requestManager.executeRequest()
    }
    
    func startObserving() {
        repository.addUpdaterDelegate(self)
    }
    
    func stopObserving() {
        repository.removeUpdaterDelegate(self)
    }
    
    func refresh() {
        guard let date = date else {
            return
        }

        loadEvents(on: date)
    }
    
    func loadEvents(on date: Date) {
        self.date = date
        self.state = .loading
        let requestID = requestManager.executeRequest()
        let range = DateInterval.rangeOfDay(date)
        repository.fetchEvents(in: range) { [weak self] events in
            guard let self = self,
                  self.requestManager.shouldProceed(with: requestID),
                  range.contains(date) else {
                return
            }
            
            self.state = .loaded
            self.events = events
            self.onEventsChanged?()
        }
    }
    
    // MARK: - MyDayEventChangeDelegate
    func myDayEventsDidChange(in ranges: [DateInterval]) {
        guard let date = date else {
            return
        }
        
        let currentRange = DateInterval.rangeOfDay(date)
        var shouldReload: Bool = false
        for range in ranges {
            if range.intersects(currentRange) {
                shouldReload = true
                break
            }
        }
        
        if shouldReload {
            loadEvents(on: date)
        }
    }
}
