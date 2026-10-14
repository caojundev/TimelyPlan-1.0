//
//  GoalFocusStatsDataProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation

/// 目标任务专注统计数据提供者
final class GoalFocusStatsDataProvider: FocusDurationDataProvider,
                                            FocusSessionProcessorDelegate {

    var onSessionChanged: (([DateInterval]) -> Void)?
    
    // MARK: - 数据

    /// 目标任务
    var task: GoalTask

    // MARK: - 初始化

    init(task: GoalTask) {
        self.task = task
        FocusRepository.addUpdater(self, for: [.session])
    }

    // MARK: - FocusDurationDataProvider

    func fetchFocusStatsDataItem(dateRange: DateRange,
                                 completion: @escaping (FocusStatsDataItem) -> Void) {
        /// 指定任务时为特定统计模式，需包含已归档计时器的会话
        FocusRepository.fetchStats(forTask: task,
                                   dateRange: dateRange,
                                   includeArchivedTimer: true,
                                   completion: completion)
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        /// 仅保留当前目标任务的会话
        let filteredSessions = sessions.filter { session in
            return session.taskID == task.identifier
        }
        guard filteredSessions.count > 0 else {
            return
        }

        let intervals = FocusSession.dateIntervals(from: filteredSessions)
        onSessionChanged?(intervals)
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        guard session.taskID == task.identifier else {
            return
        }
        
        onSessionChanged?([session.dateInterval])
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        guard session.taskID == task.identifier else {
            return
        }
        
        onSessionChanged?([session.dateInterval])
    }
}
