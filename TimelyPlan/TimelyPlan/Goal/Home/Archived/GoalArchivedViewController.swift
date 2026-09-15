//
//  GoalArchivedViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

class GoalArchivedViewController: TPViewController,
                                  GoalPlanListViewDelegate {
    
    /// 已归档目标计划视图模型
    private let viewModel = GoalArchivedPlanViewModel()
    
    /// 目标计划列表视图
    lazy var listView: GoalPlanListView = {
        let listView = GoalPlanListView(frame: .zero)
        listView.delegate = self
        listView.placeholderProvider = viewModel.placeholderProvider
        return listView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.title = resGetString("Archived")
        self.view.addSubview(self.listView)
        
        self.viewModel.goalPlansDidChange = { [weak self] change in
            self?.goalPlansChanged(change)
        }
        self.viewModel.loadGoalPlans()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.listView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 加载并刷新已归档目标计划
    private func reloadGoalPlans() {
        let group = GoalPlanGroup(identifier: "ArchivedGoalPlanGroup")
        group.goalPlans = viewModel.goalPlans
        listView.groups = [group]
        listView.performUpdate()
    }
    
    /// 处理目标计划变更
    private func goalPlansChanged(_ change: GoalPlanChange?) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadGoalPlans()
        }
    }
    
    // MARK: - GoalPlanListViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let goalPlan = collectionView.item(at: indexPath) as? GoalPlan {
            GoalPresenter.showArchivedGoalDetail(goalPlan)
        }
    }
    
    func goalPlanListViewHandleRefresh(_ listView: GoalPlanListView) {
        self.viewModel.setNeedsRefresh()
        self.viewModel.loadGoalPlans()
    }
}
