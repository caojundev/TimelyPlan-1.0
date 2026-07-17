//
//  MyDayRangeEventsInfoFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/17.
//

import Foundation

class MyDayRangeEventsInfoFetcher: CalendarRangeEventsProvider,
                                    MyDayEventChangeDelegate {

    private let repository = MyDayRepository()
    
    private let calculationQueue = DispatchQueue(label: "com.myDay.rangeEvents",
                                                  qos: .userInitiated,
                                                  attributes: .concurrent)
    
    private let eventChangeUpdater = CalendarUpdater()
    
    init() {
        self.repository.addUpdaterDelegate(self)
    }
    
    func fetchRangeEventsInfo(in range: DateInterval, completion: @escaping (CalendarRangeEventsInfo) -> Void) {
        
        repository.fetchEvents(in: range) { [weak self] events in
            guard let self = self else { return }
            self.calculationQueue.async {
                
                let dayColors = CalendarEventColorMapper.mapColorsByDay(events: events,
                                                                        range: range)
                let result = CalendarRangeEventsInfo(range: range, dayColors: dayColors)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    func addEventChangeDelegate(_ delegate: CalendarEventChangeDelegate) {
        eventChangeUpdater.addDelegate(delegate)
    }
    
    // MARK: - MyDayEventChangeDelegate
    func myDayEventsDidChange(in ranges: [DateInterval]) {
        eventChangeUpdater.calendarEventsDidChange(in: ranges)
    }
    
}
