//
//  CalendarLocalEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

class CalendarLocalEventProvider: CalendarEventProvider, SettingAgentObserver {
    
    /// 事项改变代理
    weak var delegate: CalendarEventChangeDelegate?

    init() {
        /// 添加任务处理监听
        todo.addUpdater(self, for: [.task])
        CalendarSetting.shared.addObserver(self, forKey: .showCompletedTask)
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        if keyName == CalendarSetting.Key.showCompletedTask.name {
            delegate?.calendarEventsDidChange(in: [.infiniteInterval])
        }
    }
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        let showCompleted = CalendarSetting.shared.showCompletedTask
        todo.fetchScheduledTasks(in: range, showCompleted: showCompleted) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }

            let events = self.events(for: tasks)
            completion(events)
        }
    }
    
    // MARK: - Helpers
    private func events(for tasks: [TodoTask]) -> [CalendarEvent] {
        var results = [CalendarEvent]()
        for task in tasks {
            if let event = event(with: task) {
                results.append(event)
            }
        }
        
        return results
    }
    
    private func event(with task: TodoTask) -> CalendarEvent? {
        guard let dateInfo = task.schedule?.dateInfo else {
            return nil
        }
        
        let color = task.priority.color
        var isAllDay = dateInfo.isAllDay
        if !isAllDay && dateInfo.style == .multiDay {
            /// 跨天任务，显示为全天事项
            isAllDay = true
        }
        
        let event = CalendarEvent(identifier: task.identifier,
                                  source: .local,
                                  name: task.name,
                                  color: color,
                                  startDate: dateInfo.startDate,
                                  endDate: dateInfo.endDate,
                                  isAllDay: isAllDay,
                                  sourceItem: task)
        return event
    }
}

extension CalendarLocalEventProvider: TodoTaskProcessorDelegate {
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        delegate?.calendarEventsDidChange(in: ranges)
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        guard let ranges = affectedRanges(for: [task]) else {
            return
        }
        
        delegate?.calendarEventsDidChange(in: ranges)
    }

    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        delegate?.calendarEventsDidChange(in: ranges)
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        delegate?.calendarEventsDidChange(in: ranges)
    }

    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        guard let ranges = ranges(for: task, with: change) else {
            return
        }
        
        delegate?.calendarEventsDidChange(in: ranges)
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        var results = [DateInterval]()
        for changeInfo in changeInfos {
            if let ranges = ranges(for:changeInfo.task, with: changeInfo.change) {
                results.append(contentsOf: ranges)
            }
        }
        
        delegate?.calendarEventsDidChange(in: results)
    }
    
    private func affectedRanges(for tasks: [TodoTask]) -> [DateInterval]? {
        var ranges = [DateInterval]()
        for task in tasks {
            if let range = task.schedule?.dateInfo?.dateInterval {
                ranges.append(range)
            }
        }
        
        if ranges.count == 0 {
            return nil
        }
        
        return ranges
    }
    
    private func ranges(for task: TodoTask, with change: TodoTaskChange) -> [DateInterval]? {
        if case let .schedule(oldValue, newValue) = change {
            var ranges = [DateInterval]()
            if let oldRange = oldValue?.dateInfo?.dateInterval {
                ranges.append(oldRange)
            }
            
            if let newRange = newValue?.dateInfo?.dateInterval {
                ranges.append(newRange)
            }
            
            return ranges
        }
        
        return affectedRanges(for: [task])
    }
}

