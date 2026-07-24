//
//  MyDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation
import UIKit

class MyDayTimelineView: TimelineView, TimelineViewDelegate {
    
    private let eventViewModel = MyDayTimelineViewModel()
    
    private let eventProcessor = MyDayEventProcessor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        eventViewModel.onEventsChanged = { [weak self] in
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
        eventViewModel.startObserving()
        eventViewModel.loadEvents(on: date)
    }
    
    func clear() {
        eventViewModel.stopObserving()
        eventViewModel.clear()
        reloadData()
    }
    
    // MARK: - TimelineViewDelegate
    func timelineViewEvents(_ timelineView: TimelineView) -> [MyDayEvent]? {
        return eventViewModel.events
    }
    
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent) {
        TPImpactFeedback.impactWithSoftStyle()
        eventProcessor.clickEvent(event)
    }
}

extension MyDayTimelineView: MyDayFocusTimelineCellDelegate {
    
    func myDayFocusTimelineCellDidClickStart(_ cell: MyDayFocusTimelineCell) {
        guard let event = cell.focusItem?.event else {
            return
        }
        
        eventProcessor.clickStart(for: event)
    }
}
