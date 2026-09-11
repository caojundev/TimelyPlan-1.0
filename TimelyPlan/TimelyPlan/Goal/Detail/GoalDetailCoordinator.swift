//
//  GoalDetailCoordinator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

class GoalDetailCoordinator {
    
    /// 多边栏视图管理器
    private(set) weak var multiColumnVC: TPMultiColumnViewController?
    
    /// 空详情视图控制器
    var emptyDetailViewController: UIViewController?

    private var configuration: GoalListConfiguration?
    
    init(multiColumnViewController: TPMultiColumnViewController) {
        self.multiColumnVC = multiColumnViewController
        GoalRepository.addUpdater(self, for: [.plan])
    }

    /// 显示目标计划详情
    func showDetail(for goalPlan: GoalPlan) {
        guard let multiColumnVC = multiColumnVC else {
            return
        }
        
        let newConfiguration = GoalPlanConfiguration(goalPlan: goalPlan)
        guard newConfiguration != self.configuration else {
            multiColumnVC.showDetailView()
            return
        }
        
        self.configuration = newConfiguration
        let vc = GoalDetailViewController(configuration: newConfiguration)
        let navController = UINavigationController(rootViewController: vc)
        multiColumnVC.replaceDetail(with: navController)
        multiColumnVC.showDetailView()
    }
    
    /// 显示收件箱详情（未归属任何目标计划的目标任务）
    func showInboxDetail() {
        guard let multiColumnVC = multiColumnVC else {
            return
        }
        
        let newConfiguration = GoalInboxConfiguration()
        guard newConfiguration != self.configuration else {
            multiColumnVC.showDetailView()
            return
        }
        
        self.configuration = newConfiguration
        let vc = GoalInboxViewController(configuration: newConfiguration)
        let navController = UINavigationController(rootViewController: vc)
        multiColumnVC.replaceDetail(with: navController)
        multiColumnVC.showDetailView()
    }
    
    func showEmptyDetail() {
        guard let multiColumnVC = multiColumnVC else {
            return
        }
        
        self.configuration = nil
        multiColumnVC.replaceDetail(with: emptyDetailViewController)
    }
    
}

extension GoalDetailCoordinator: GoalPlanProcessorDelegate {
    
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {
        guard let configuration = configuration as? GoalPlanConfiguration else {
            return
        }
        
        if GoalRepository.getGoalPlan(withIdentifier: configuration.identifier) == nil {
            /// 显示空白详情页
            showEmptyDetail()
        }
    }
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {
        guard let configuration = configuration as? GoalPlanConfiguration else {
            return
        }
        
        if goalPlan.identifier == configuration.identifier {
            showEmptyDetail()
        }
    }
}
