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

    private var configuration: GoalPlanConfiguration?
    
    init(multiColumnViewController: TPMultiColumnViewController) {
        self.multiColumnVC = multiColumnViewController
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
    
}
