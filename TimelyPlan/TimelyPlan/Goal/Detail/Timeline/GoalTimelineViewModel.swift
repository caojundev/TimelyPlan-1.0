//
//  GoalTimelineViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/26.
//

import Foundation

class GoalTimelineViewModel {

    /// 事项改变回调（外部在此刷新 UI）
    var onEventsChanged: (() -> Void)?
    
    /// 当前目标计划下的时间线事项
    private(set) var events: [GanttEvent]?
    
    private(set) var tasks: [GoalTask]?
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    /// 占位视图
    private(set) var placeholderProvider = TPLoadableListPlaceholderProvider()
        
    /// 加载状态
    private(set) var loadingState: TPListLoadingState = .initialLoading {
        didSet {
            placeholderProvider.state = loadingState
        }
    }
    
    /// 列表配置
    let configuration: GoalListConfiguration
    
    init(configuration: GoalListConfiguration) {
        self.configuration = configuration
        self.placeholderProvider.emptyImage = resGetImage("goal_placeholder_80")
        self.placeholderProvider.emptyTitle = resGetString("No Goal")
        self.placeholderProvider.state = self.loadingState
        GoalRepository.addUpdater(self)
    }

    func resetLoadingState() {
        self.loadingState = .initialLoading
    }
    
    func setNeedsRefresh() {
        self.needsRefresh = true
    }
    
    func loadEvents() {
        self.loadingState = .loading
        let requestID = requestManager.executeRequest()
        loadTasksIfNeeded { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let events = tasks?.toGanttEvents()
                DispatchQueue.main.async {
                    guard self.requestManager.shouldProceed(with: requestID) else {
                        return
                    }
                    
                    self.tasks = tasks
                    self.events = events
                    self.needsRefresh = false
                    self.loadingState = .loaded
                    self.onEventsChanged?()
                }
            }
        }
    }
    
    private func loadTasksIfNeeded(completion: @escaping ([GoalTask]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.tasks)
            return
        }
        
        fetchTasks(completion: completion)
    }
    
    /// 获取任务方法
    private func fetchTasks(completion: @escaping ([GoalTask]?) -> Void) {
        configuration.fetchTasks(completion: completion)
    }
}

extension GoalTimelineViewModel: GoalTaskProcessorDelegate {
    
    func didChangeRemoteGoalTask(with results: EntityChangeResults<GoalTask>?) {
        setNeedsRefresh()
        loadEvents()
    }
      
    func didCreateGoalTask(_ goalTask: GoalTask) {
        setNeedsRefresh()
        loadEvents()
    }
    
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        setNeedsRefresh()
        loadEvents()
    }
    
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {
        setNeedsRefresh()
        loadEvents()
    }
    
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {
        setNeedsRefresh()
        loadEvents()
    }
}
