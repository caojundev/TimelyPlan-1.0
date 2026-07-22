//
//  MyDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation
import UIKit

class MyDayTimelineView: TimelineView, TimelineViewDelegate {
    
    private let eventsViewModel = MyDayTimelineViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        eventsViewModel.onEventsChanged = { [weak self] in
            self?.handleEventsChanged()
        }
    }
    
    private func handleEventsChanged() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.reloadData()
        }
    }
    
    override func eventCellClass(for item: TimelineItem) -> AnyClass {
        guard let event = item.event else {
            return TimelineCell.self
        }
        
        switch event.source {
        case .todo:
            return MyDayTodoTimelineCell.self
        case .focus:
            return MyDayFocusTimelineCell.self
        case .habit:
            return MyDayHabitTimelineCell.self
        }
    }

    func loadEvents(on date: Date) {
        eventsViewModel.startObserving()
        eventsViewModel.loadEvents(on: date)
    }
    
    func clear() {
        eventsViewModel.stopObserving()
        eventsViewModel.clear()
        reloadData()
    }
    
    // MARK: - TimelineViewDelegate
    func timelineViewEvents(_ timelineView: TimelineView) -> [MyDayEvent]? {
        return eventsViewModel.events
    }
    
    func timelineViewWillBeginDragging(_ timelineView: TimelineView) {
        
    }
    
    
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent) {

    }
}
