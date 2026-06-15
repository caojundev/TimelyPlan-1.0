//
//  FocusTimelineViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/29.
//

import Foundation

class FocusTimelineViewModel: FocusSessionProcessorDelegate {
    
    var eventsDidChange: (() -> Void)?
    
    private(set) var events: [FocusTimelineEvent]?
    
    private(set) var date: Date?
    
    init() {
        FocusRepository.addUpdater(self, for: [.session])
    }
    
    func loadEvents(for date: Date) {
        self.date = date
        let sessionDate = date
        FocusRepository.fetchSessions(for: sessionDate, includeArchivedTimer: true) { sessions in
            guard self.date == sessionDate else {
                /// 非当前日期
                return
            }
            
            let sessions = sessions ?? []
            var events: [FocusTimelineEvent] = []
            for session in sessions {
                let event = FocusTimelineEvent(session: session)
                events.append(event)
            }
            
            self.events = events
            self.eventsDidChange?()
        }
    }
    
    private func loadEvents() {
        guard let date = date else {
            return
        }

        self.loadEvents(for: date)
    }
    
    private func shouldReloadDay(for session: FocusSession) -> Bool {
        guard let date = self.date, let sessionDate = session.startDate else {
            return false
        }

        return sessionDate.isInSameDayAs(date)
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        var shouldReload: Bool = false
        for session in sessions {
            if shouldReloadDay(for: session) {
                shouldReload = true
                break
            }
        }
        
        if shouldReload{
            loadEvents()
        }
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        if shouldReloadDay(for: session) {
            loadEvents()
        }
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        if shouldReloadDay(for: session) {
            loadEvents()
        }
    }
}
