//
//  GoalNotifiableTaskProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/8.
//

import Foundation

class GoalNotifiableTaskProvider: LocalNotifiableTaskProvider {
    
    /// 通知任务改变代理
    weak var delegate: LocalNotifiableTaskChangeDelegate?

    /// 任务数组
    private var results: [LocalNotifiable] = []
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    init() {
        /// 添加计划、任务和记录处理监听
        GoalRepository.addUpdater(self, for: [.plan, .task, .record])
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
        GoalRepository.fetchNotifiableGoalTasks { [weak self] tasks in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion([])
                return
            }

            self.needsRefresh = false
            self.results = tasks ?? []
            completion(self.results)
        }
    }
}

extension GoalNotifiableTaskProvider: GoalPlanProcessorDelegate,
                                      GoalTaskProcessorDelegate,
                                      GoalRecordProcessorDelegate {
    
    // MARK: - GoalPlanProcessorDelegate
    
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {
        /// 归档目标计划后，其下任务不再通知
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {
        /// 取消归档目标计划后，其下任务恢复通知
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {
        /// 删除目标计划会级联删除其下任务，需要刷新通知
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    // MARK: - GoalTaskProcessorDelegate
    
    func didChangeRemoteGoalTask(with results: EntityChangeResults<GoalTask>?) {
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    func didCreateGoalTask(_ goalTask: GoalTask) {
        if goalTask.hasReminder {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        var shouldRefresh = false
        switch change {
        case .content(let oldValue, let newValue):
            /// 提醒相关改变
            if isReminderChanged(oldValue, newValue) {
                shouldRefresh = true
            } else if oldValue.name != newValue.name {
                shouldRefresh = goalTask.hasReminder
            }
            
        case .name:
            shouldRefresh = goalTask.hasReminder
            
        case .completed:
            shouldRefresh = goalTask.hasReminder
            
        case .progress:
            shouldRefresh = goalTask.hasReminder
            
        case .move:
            shouldRefresh = goalTask.hasReminder
            
        case .note, .myDay, .step:
            break
        }
        
        if shouldRefresh {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {
        let shouldRefresh = changeInfos.anySatisfy { self.shouldNotify(with: $0) }
        if shouldRefresh {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {
        let shouldRefresh = goalTasks.anySatisfy { $0.hasReminder }
        if shouldRefresh {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    
    // MARK: - GoalRecordProcessorDelegate
    
    func didChangeRemoteGoalRecord(with results: EntityChangeResults<GoalRecord>?) {
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    func didCreateGoalRecord(_ record: GoalRecord, for task: GoalTask) {
        if task.hasReminder {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didUpdateGoalRecord(_ record: GoalRecord,
                             for task: GoalTask,
                             with change: GoalRecordChange) {
        if task.hasReminder {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didDeleteGoalRecords(for task: GoalTask?, in dateRange: DateRange?) {
        if let task = task, !task.hasReminder {
            return
        }
        
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    // MARK: - 辅助
    
    /// 判断提醒是否发生改变
    private func isReminderChanged(_ oldValue: GoalEditingTask,
                                   _ newValue: GoalEditingTask) -> Bool {
        if oldValue.shouldRemind != newValue.shouldRemind {
            return true
        }
        
        return oldValue.reminder != newValue.reminder
    }
    
    /// 判断目标任务变化是否需要通知刷新
    private func shouldNotify(with changeInfo: GoalTaskChangeInfo) -> Bool {
        switch changeInfo.change {
        case .content(let oldValue, let newValue):
            if isReminderChanged(oldValue, newValue) {
                return true
            }
            
            if oldValue.name != newValue.name {
                return changeInfo.goalTask.hasReminder
            }
            
            return false
            
        case .name, .completed, .progress, .move:
            return changeInfo.goalTask.hasReminder
            
        case .note, .myDay, .step:
            return false
        }
    }
}
