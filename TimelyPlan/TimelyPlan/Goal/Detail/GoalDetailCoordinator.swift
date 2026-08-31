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
    
    init(multiColumnViewController: TPMultiColumnViewController) {
        self.multiColumnVC = multiColumnViewController
    }
    
    /// 显示目标计划详情
    func showDetail(for goalPlan: GoalPlan) {
        guard let multiColumnVC = multiColumnVC else {
            return
        }
        
        let vc = GoalDetailViewController(goalPlan: goalPlan)
        let navController = UINavigationController(rootViewController: vc)
        multiColumnVC.replaceDetail(with: navController)
        multiColumnVC.showDetailView()
    }
}
