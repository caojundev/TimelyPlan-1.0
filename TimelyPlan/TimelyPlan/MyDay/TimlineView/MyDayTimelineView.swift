//
//  MyDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation
import UIKit

class MyDayTimelineView: TimelineView, TimelineViewDelegate {
    
    /// 习惯记录供应器
    weak var habitRecordProvider: MyDayHabitRecordProvider?
    
    weak var eventAddController: MyDayEventAddController?
    
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
        switch item.event.source {
        case .calendar:
            return MyDayCalendarTimelineCell.self
        case .todo:
            return MyDayTodoTimelineCell.self
        case .focus:
            return MyDayFocusTimelineCell.self
        case .habit:
            return MyDayHabitTimelineCell.self
        }
    }
    
    override func configureEventCell(_ cell: TimelineEventCell, with item: TimelineItem) {
        super.configureEventCell(cell, with: item)
        if let cell = cell as? MyDayHabitTimelineCell {
            cell.configure(with: item, recordProvider: habitRecordProvider)
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
        eventProcessor.clickEvent(event)
    }
}

extension MyDayTimelineView: TimelineEventCellDelegate {
    
    func timelineEventCellDidClickStartTime(_ cell: TimelineEventCell) {
        guard let event = cell.currentItem?.event else {
            return
        }
        
        MyDayEventScheduleEditor.editSchedule(for: event)
    }
}

extension MyDayTimelineView: TimelineDashedConnectionCellDelegate {
    
    func timelineDashedConnectionCellDidClickAdd(_ cell: TimelineDashedConnectionCell) {
        TPImpactFeedback.impactWithSoftStyle()
        let addTypes: [MyDayEventAddType] = [.calendar, .todo, .habit, .focus]
        let menuController = MyDayEventAddMenuController(addTypes: addTypes)
        menuController.didSelectMenuActionType = { [weak self] type in
            self?.selectAddType(type, with: cell.item)
        }
                            
        let sourceView = cell.addButton
        let sourceRect = sourceView.bounds.insetBy(dx: -4.0, dy: -4.0)
        menuController.showMenu(from: sourceView,
                                sourceRect: sourceRect,
                                isCovered: true)
    }
    
    func timelineDashedConnectionCellDidClickBind(_ cell: TimelineDashedConnectionCell) {
        TPImpactFeedback.impactWithSoftStyle()
        selectAddType(.bind, with: cell.item)
    }
    
    private func selectAddType(_ addType: MyDayEventAddType, with connectionItem: TimelineConnectionItem?) {
        guard let eventAddController = eventAddController else {
            return
        }
        
        guard let connectionItem = connectionItem else { return }
        let timeCalculator = MyDayEventTimeCalculator(config: .compact)
        
        let dateInfo: TaskDateInfo
        if let suggestedTime = timeCalculator.calculateSuggestedTime(
            topDate: connectionItem.topDate,
            bottomDate: connectionItem.bottomDate
        ) {
            dateInfo = TaskDateInfo(startDate: suggestedTime.startDate,
                                    endDate: suggestedTime.endDate,
                                    isAllDay: false)
        } else {
            let startDate = connectionItem.topDate.startOfDay()
            let endDate = connectionItem.topDate.endOfDay()
            dateInfo = TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: true)
        }
        
        eventAddController.performAddMenuAction(with: addType, with: dateInfo)
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
