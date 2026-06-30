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
//        CalendarSetting.shared.addObserver(self, forKey: .showCompletedTask)
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
//        if keyName == CalendarSetting.Key.showCompletedTask.name {
//            delegate?.calendarEventsDidChange(in: [.infiniteInterval])
//        }
    }
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        HabitRepository.fetchEventTasks(in: range) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let events = tasks.toCalendarEvents(in: range)
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
        delegate?.calendarEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 更新任务通知
    func didUpdateHabitTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        delegate?.calendarEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 删除任务通知
    func didDeleteHabitTask(_ task: HabitTask) {
        delegate?.calendarEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 改变了任务的归档状态
    func didChangeArchivedState(for task: HabitTask) {
        delegate?.calendarEventsDidChange(in: [.infiniteInterval])
    }
}

