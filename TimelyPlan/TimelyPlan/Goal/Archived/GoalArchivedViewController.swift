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
    
    /// 目标计划列表视图
    lazy var listView: GoalPlanListView = {
        let listView = GoalPlanListView(frame: .zero)
        listView.delegate = self
        return listView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.title = resGetString("Archived")
        self.view.addSubview(self.listView)
        self.reloadGoalPlans()
        
        GoalRepository.goalPlansDidChange = { [weak self] change in
            self?.reloadGoalPlans()
        }
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
        group.goalPlans = GoalRepository.getArchivedGoalPlans()
        listView.groups = [group]
        listView.performUpdate()
    }
    
    // MARK: - GoalPlanListViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let goalPlan = collectionView.item(at: indexPath) as? GoalPlan {
            GoalPresenter.showArchivedGoalDetail(goalPlan)
        }
    }
    
    func goalPlanListViewHandleRefresh(_ listView: GoalPlanListView) {
        self.reloadGoalPlans()
    }
}
