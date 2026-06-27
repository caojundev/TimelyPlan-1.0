//
//  HabitNotifiableTaskProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/25.
//

import Foundation

class HabitNotifiableTaskProvider: LocalNotifiableTaskProvider {
    
    /// 通知任务改变代理
    weak var delegate: LocalNotifiableTaskChangeDelegate?

    /// 任务数组
    private var results: [LocalNotifiable] = []
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    init() {
        /// 添加任务和记录处理监听
        HabitRepository.addUpdater(self, for: [.task, .record])
    }
    
    func setNeedsRefresh() {
        needsRefresh = true
    }
    
    func fetchNotifiableTasks(completion: @escaping ([LocalNotifiable]) -> Void) {
        guard needsRefresh else {
            completion(results)
            return
        }
        
        /// 重新获取
        let requestID = requestManager.executeRequest()
        HabitRepository.fetchNotifiablePeriodItems { [weak self] items in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion([])
                return
            }

            self.needsRefresh = false
            self.results = items
            completion(self.results)
        }
    }
}

extension HabitNotifiableTaskProvider: HabitTaskProcessorDelegate,
                                        HabitRecordProcessorDelegate {
    
    // MARK: - HabitTaskProcessorDelegate
    
    func didChangeRemoteHabitTask(with results: EntityChangeResults<HabitTask>?) {
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    func didCreateHabitTask(_ task: HabitTask) {
        if task.hasAlarm {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didUpdateHabitTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        var shouldRefresh = false
        if task.isReminderChanged(editingTask) {
            shouldRefresh = true
        } else if task.name != editingTask.name, task.hasAlarm {
            shouldRefresh = true
        }
        
        if shouldRefresh {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        if task.hasAlarm {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        if task.hasAlarm {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    
    // MARK: - HabitRecordProcessorDelegate
    
    func didChangeRemoteHabitRecord(with results: EntityChangeResults<HabitRecord>?) {
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    func didUpdateHabitRecord(_ record: HabitRecord,
                              for task: HabitTask,
                              on date: Date,
                              with change: HabitRecordChange) {
        if task.hasAlarm {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didDeleteHabitRecords(for task: HabitTask?, in dateRange: DateRange) {
        guard dateRange.contains(date: .now) else {
            return
        }
        
        if let task = task, !task.hasAlarm {
            return
        }
    
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
   
}

