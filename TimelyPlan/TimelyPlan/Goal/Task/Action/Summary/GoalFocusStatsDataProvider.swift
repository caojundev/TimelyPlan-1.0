//
//  GoalFocusStatsDataProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation

/// 目标任务专注时长数据提供者
final class GoalFocusStatsDataProvider: FocusSessionProcessorDelegate {

    /// 专注时长更新回调，参数为任务的总专注时长（秒）
    var onDurationChanged: ((Int64) -> Void)?

    /// 目标任务
    var task: GoalTask

    // MARK: - 初始化

    init(task: GoalTask) {
        self.task = task
        FocusRepository.addUpdater(self, for: [.session])
    }

    // MARK: - 获取时长

    /// 异步获取目标任务的总专注时长
    func fetchDuration() {
        FocusRepository.fetchDuration(forTask: task) { [weak self] duration in
            self?.onDurationChanged?(duration)
        }
    }

    // MARK: - FocusSessionProcessorDelegate

    func didAddFocusSessions(_ sessions: [FocusSession]) {
        /// 仅当前任务的会话变化才会影响时长
        guard sessions.contains(where: isRelated(_:)) else {
            return
        }

        fetchDuration()
    }

    func didUpdateFocusSession(_ session: FocusSession) {
        guard isRelated(session) else {
            return
        }

        fetchDuration()
    }

    func didDeleteFocusSession(_ session: FocusSession) {
        guard isRelated(session) else {
            return
        }

        fetchDuration()
    }

    // MARK: - 判断

    /// 会话是否属于当前任务
    private func isRelated(_ session: FocusSession) -> Bool {
        return session.taskID == task.identifier
    }
}
