//
//  GoalTaskEditInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation

/// 目标任务编辑交互器观察者
///
/// 「概览」「步骤」「备注」等多个视图控制器共用同一个交互器，
/// 交互器内部以弱引用保存观察者，多个视图控制器可同时观察而互不覆盖。
protocol GoalTaskEditInteractorObserver: AnyObject {
    
    /// 任务内容改变
    /// - Parameters:
    ///   - task: 最新的目标任务
    ///   - change: 变更描述，nil 表示未知变更（如远程同步）
    func goalTaskEditInteractor(_ interactor: GoalTaskEditInteractor,
                                didUpdateTask task: GoalTask,
                                with change: GoalTaskChange?)
    
    /// 任务被删除
    func goalTaskEditInteractorDidDeleteTask(_ interactor: GoalTaskEditInteractor)
}

extension GoalTaskEditInteractorObserver {
    
    func goalTaskEditInteractor(_ interactor: GoalTaskEditInteractor,
                                didUpdateTask task: GoalTask,
                                with change: GoalTaskChange?) {}
    
    func goalTaskEditInteractorDidDeleteTask(_ interactor: GoalTaskEditInteractor) {}
}

/// 目标任务操作交互器
///
/// 参照 `TodoTaskEditInteractor` 实现，负责统一管理对目标任务的各类操作，
/// 并监听目标任务的增删改，通过观察者协议通知所有观察者。
class GoalTaskEditInteractor: GoalTaskProcessorDelegate {
    
    /// 目标任务（始终为最新内容）
    private(set) var task: GoalTask
    
    /// 复选框 / 进度记录控制器（弹窗输入场景）
    private let taskController = GoalTaskController()
    
    /// 观察者集合（弱引用，无需手动移除）
    private let observers = TPWeakDelegateCollection()
    
    init(task: GoalTask) {
        self.task = task
        GoalRepository.addUpdater(self, for: [.task])
    }
    
    deinit {
        GoalRepository.removeUpdater(self)
    }
    
    // MARK: - 观察者
    
    /// 添加观察者
    func addObserver(_ observer: GoalTaskEditInteractorObserver) {
        observers.addDelegate(observer)
    }
    
    /// 移除观察者
    func removeObserver(_ observer: GoalTaskEditInteractorObserver) {
        observers.removeDelegate(observer)
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
    
    /// 重新获取最新任务；任务已不存在时触发删除通知
    private func refreshTask(_ change: GoalTaskChange?) {
        if let latestTask = GoalRepository.getGoalTask(withIdentifier: task.identifier) {
            task = latestTask
            dispatchMain { [weak self] in
                self?.notifyTaskChanged(change)
            }
        } else {
            notifyDeleted()
        }
    }
    
    /// 通知任务内容改变
    private func notifyTaskChanged(_ change: GoalTaskChange?) {
        let task = self.task
        observers.notifyDelegates { (observer: GoalTaskEditInteractorObserver) in
            observer.goalTaskEditInteractor(self, didUpdateTask: task, with: change)
        }
    }
    
    /// 通知任务被删除（保证在主线程）
    private func notifyDeleted() {
        dispatchMain { [weak self] in
            guard let self = self else {
                return
            }
            
            self.observers.notifyDelegates { (observer: GoalTaskEditInteractorObserver) in
                observer.goalTaskEditInteractorDidDeleteTask(self)
            }
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
