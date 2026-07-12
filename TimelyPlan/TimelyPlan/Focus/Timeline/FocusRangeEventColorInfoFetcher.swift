//
//  FocusRangeEventColorInfoFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/12.
//

import Foundation

class FocusRangeEventColorInfoFetcher: CalendarRangeEventsProvider {

    private let updater = CalendarUpdater()
    
    init() {
        FocusRepository.addUpdater(self, for: [.session])
    }
    
    func fetchRangeEventsInfo(in range: DateInterval, completion: @escaping (CalendarRangeEventsInfo) -> Void) {
        let dateRange = DateRange(startDate: range.start, endDate: range.end)
        FocusRepository.fetchSessions(forTask: nil,
                                      timer: nil,
                                      dateRange: dateRange,
                                      includeArchivedTimer: true) { sessions in
            guard let sessions = sessions else {
                completion(.empty(with: range))
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let dayColors = self.mapColorsByDay(events: sessions, range: range)
                let result = CalendarRangeEventsInfo(range: range, dayColors: dayColors)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    func addEventChangeDelegate(_ delegate: CalendarEventChangeDelegate) {
        updater.addDelegate(delegate)
    }
       
    private func mapColorsByDay(
        events: [FocusSession],
        range: DateInterval
    ) -> DailyEventColors {
        let calendar = Calendar.current
        var dayColorsMap: [DateComponents: OrderedSet<UIColor>] = [:]
        
        for session in events {
            guard let startDate = session.startDate,
                  let colorHex = session.timerSnapshotColorHex,
                  range.contains(startDate) else {
                continue
            }
            
            let dayComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
            let color = UIColor(RGBString: colorHex) ?? FocusConstant.sessionDefaultColor
            dayColorsMap[dayComponents, default: OrderedSet<UIColor>()].append(color)
        }
        
        return dayColorsMap.mapValues { $0.array }
    }
}

extension FocusRangeEventColorInfoFetcher: FocusSessionProcessorDelegate {
    
    /// 远程专注会话改变
    func didChangeRemoteFocusSession(with results: EntityChangeResults<FocusSession>?) {
        updater.calendarEventsDidChange(in: [.infiniteInterval])
    }
        
    /// 添加专注会话
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        let intervals = FocusSession.dateIntervals(from: sessions)
        updater.calendarEventsDidChange(in: intervals)
    }
    
    /// 更新专注会话
    func didUpdateFocusSession(_ session: FocusSession) {
        updater.calendarEventsDidChange(in: [session.dateInterval])
    }
    
    /// 删除专注会话
    func didDeleteFocusSession(_ session: FocusSession) {
        updater.calendarEventsDidChange(in: [session.dateInterval])
    }
}

extension FocusSession {
    
    var dateInterval: DateInterval {
        let start = startDate ?? .distantPast
        let end = endDate ?? .distantFuture
        return DateInterval(start: start, end: end)
    }
    
    static func dateIntervals(from sessions: [FocusSession]) -> [DateInterval] {
        return sessions.map { $0.dateInterval }
    }
}
