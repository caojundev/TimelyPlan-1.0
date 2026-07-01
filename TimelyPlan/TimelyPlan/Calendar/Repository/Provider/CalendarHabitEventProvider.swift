//
//  CalendarHabitEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/30.
//

import Foundation

class CalendarHabitEventProvider: CalendarEventProvider, SettingAgentObserver {
    
    /// 事项改变代理
    weak var delegate: CalendarEventChangeDelegate?

    init() {
        /// 添加任务处理监听
        HabitRepository.addUpdater(self, for: [.task])
        CalendarSetting.shared.addObserver(self, forKeys: [.showHabit, .habitDisplayRange])
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = CalendarSetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .showHabit, .habitDisplayRange:
            delegate?.calendarEventsDidChange(in: [.infiniteInterval])
        default:
            break
        }
    }
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        guard CalendarSetting.shared.showHabit else {
            completion(nil)
            return
        }
        
        let interval = CalendarSetting.shared.habitDisplayRange.interval
        guard let displayRange = interval.intersection(with: range) else {
            completion(nil)
            return
        }
        
        HabitRepository.fetchEventTasks(in: displayRange) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let events = tasks.toCalendarEvents(in: displayRange)
                DispatchQueue.main.async {
                    completion(events)
                }
            }
        }
    }
}

extension CalendarHabitEventProvider: HabitTaskProcessorDelegate {
    
    /// 远程习惯任务改变
    func didChangeRemoteHabitTask(with results: EntityChangeResults<HabitTask>?) {
        delegate?.calendarEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 添加任务时通知
    func didCreateHabitTask(_ task: HabitTask) {
        let interval = task.dateRange.interval
        delegate?.calendarEventsDidChange(in: [interval])
    }
    
    /// 更新任务通知
    func didUpdateHabitTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        let oldInterval = task.dateRange.interval
        let newInterval = editingTask.dateRange.interval
        guard oldInterval != newInterval || task.timePlan != editingTask.timePlan else {
            return
        }
        
        delegate?.calendarEventsDidChange(in: [oldInterval, newInterval])
    }
    
    /// 删除任务通知
    func didDeleteHabitTask(_ task: HabitTask) {
        let interval = task.dateRange.interval
        delegate?.calendarEventsDidChange(in: [interval])
    }
    
    /// 改变了任务的归档状态
    func didChangeArchivedState(for task: HabitTask) {
        let interval = task.dateRange.interval
        delegate?.calendarEventsDidChange(in: [interval])
    }
}

