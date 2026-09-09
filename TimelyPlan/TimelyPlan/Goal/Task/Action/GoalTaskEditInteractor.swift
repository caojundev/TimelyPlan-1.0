//
//  GoalTaskEditInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation

/// 目标任务操作交互器
///
/// 参照 `TodoTaskEditInteractor` 实现，负责统一管理对目标任务的各类操作，
/// 并监听目标任务的增删改：任务内容改变时通过 `onTaskChange` 通知，
/// 任务被删除时通过 `onTaskDeleted` 通知。
class GoalTaskEditInteractor: GoalTaskProcessorDelegate {
    
    /// 任务内容改变回调（参数为变更描述，可能为 nil 表示未知变更）
    var onTaskChange: ((GoalTaskChange?) -> Void)?
    
    /// 任务被删除回调
    var onTaskDeleted: (() -> Void)?
    
    /// 目标任务（始终为最新内容）
    private(set) var task: GoalTask
    
    /// 复选框 / 进度记录控制器（弹窗输入场景）
    private let taskController = GoalTaskController()
    
    init(task: GoalTask) {
        self.task = task
        GoalRepository.addUpdater(self, for: [.task])
    }
    
    deinit {
        GoalRepository.removeUpdater(self)
    }
    
    // MARK: - 任务操作
    
    /// 更新完成状态
    func setCompleted(_ isCompleted: Bool) {
        GoalRepository.updateGoalTask(task, isCompleted: isCompleted)
    }
    
    /// 更新步骤
    func setSteps(_ steps: [TodoStep]?) {
        GoalRepository.updateGoalTask(task, steps: steps)
    }
    
    /// 更新备注
    func setNote(_ note: String?) {
        GoalRepository.updateGoalTask(task, note: note)
    }
    
    /// 删除目标任务
    func deleteTask() {
        GoalRepository.deleteGoalTask(task)
    }
    
    /// 点击复选：完成/取消完成/记录进度（含手动输入弹窗）
    func toggleCheckbox() {
        taskController.clickCheckbox(for: task)
    }
    
    // MARK: - 刷新
    
    /// 重新获取最新任务；任务已不存在时触发删除回调
    private func refreshTask(_ change: GoalTaskChange?) {
        if let latestTask = GoalRepository.getGoalTask(withIdentifier: task.identifier) {
            task = latestTask
            dispatchMain { [weak self] in
                self?.onTaskChange?(change)
            }
        } else {
            notifyDeleted()
        }
    }
    
    /// 触发删除回调（保证在主线程）
    private func notifyDeleted() {
        dispatchMain { [weak self] in
            self?.onTaskDeleted?()
        }
    }
    
    /// 将闭包派发到主线程执行
    private func dispatchMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}

// MARK: - GoalTaskProcessorDelegate
extension GoalTaskEditInteractor {
    
    func didChangeRemoteGoalTask(with results: EntityChangeResults<GoalTask>?) {
        refreshTask(nil)
    }
    
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        guard goalTask.identifier == task.identifier else {
            return
        }
        
        refreshTask(change)
    }
    
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {
        guard changeInfos.contains(where: { $0.goalTask.identifier == task.identifier }) else {
            return
        }
        
        refreshTask(nil)
    }
    
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {
        if goalTasks.contains(where: { $0.identifier == task.identifier }) {
            notifyDeleted()
        }
    }
}
