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
    
    /// 筛选类型改变
    var filterTypeDidChange: (() -> Void)?
    
    /// 当前筛选类型
    private(set) var filterType: GoalPlanFilterType = .all {
        didSet {
            guard filterType != oldValue else {
                return
            }
            filterTypeDidChange?()
        }
    }
    
    /// 更新筛选类型
    func updateFilterType(_ filterType: GoalPlanFilterType) {
        guard self.filterType != filterType else {
            return
        }
        self.filterType = filterType
    }
    
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
        self.placeholderProvider.emptyImage = resGetImage("goal_placeholder_80")
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
    
    // MARK: - 筛选
    
    /// 按当前筛选类型过滤后的目标计划
    func filteredGoalPlans() -> [GoalPlan]? {
        return filteredGoalPlans(goalPlans, by: filterType)
    }
    
    /// 按指定筛选类型过滤目标计划
    /// - Parameters:
    ///   - goalPlans: 目标计划数组
    ///   - filterType: 筛选类型
    /// - Returns: 过滤后的目标计划数组
    func filteredGoalPlans(_ goalPlans: [GoalPlan]?, by filterType: GoalPlanFilterType) -> [GoalPlan]? {
        guard let goalPlans = goalPlans else {
            return nil
        }
        
        return goalPlans.filter { filterType.matches($0) }
    }
    
    // MARK: - GoalPlanProcessorDelegate
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {
        setNeedsRefresh()
        loadGoalPlans()
    }
    
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
