//
//  GoalPlanViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

/// 目标计划变更
enum GoalPlanChange {
    case create(GoalPlan)
    case update(GoalPlan)
}

class GoalPlanViewModel: GoalPlanProcessorDelegate {
    
    private(set) var goalPlans: [GoalPlan]?
    
    /// 目标计划改变
    var goalPlansDidChange: ((GoalPlanChange?) -> Void)?
    
    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            self.placeholderProvider.state = state
        }
    }
    
    private var needsRefresh = true
    
    private let requestManager = TPRequestManager()
    
    var placeholderProvider = TPLoadableListPlaceholderProvider()
    
    init() {
        self.placeholderProvider.state = self.state
        self.placeholderProvider.emptyImage = resGetImage("goal_list_80")
        self.placeholderProvider.emptyTitle = resGetString("No Goal")
        GoalRepository.addUpdater(self)
    }
    
    func setNeedsRefresh(_ refresh: Bool = true) {
        self.needsRefresh = refresh
    }
    
    // MARK: - 加载数据
    func loadGoalPlans(with change: GoalPlanChange? = nil, completion: (() -> Void)? = nil) {
        let change = change
        let requestID = requestManager.executeRequest()
        loadGoalPlansIfNeeded { [weak self] goalPlans in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion?()
                return
            }
            
            self.goalPlans = goalPlans
            self.needsRefresh = false
            self.state = .loaded
            self.goalPlansDidChange?(change)
            completion?()
        }
    }
    
    private func loadGoalPlansIfNeeded(completion: @escaping ([GoalPlan]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.goalPlans)
            return
        }
        
        fetchGoalPlans(completion: completion)
    }
    
    func fetchGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        GoalRepository.fetchActiveGoalPlans(completion: completion)
    }
    
    // MARK: - GoalPlanProcessorDelegate
    func didCreateGoalPlan(_ goalPlan: GoalPlan) {
        setNeedsRefresh()
        loadGoalPlans(with: .create(goalPlan))
    }
    
    func didUpdateGoalPlan(_ goalPlan: GoalPlan) {
        setNeedsRefresh()
        loadGoalPlans(with: .update(goalPlan))
    }
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {
        setNeedsRefresh()
        loadGoalPlans()
    }
    
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {
        setNeedsRefresh()
        loadGoalPlans(with: .update(goalPlan))
    }
    
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {
        setNeedsRefresh()
        loadGoalPlans(with: .update(goalPlan))
    }
    
    func didReorderGoalPlan(in goalPlans: [GoalPlan], fromIndex: Int, toIndex: Int) {
        setNeedsRefresh()
        loadGoalPlans()
    }
}
