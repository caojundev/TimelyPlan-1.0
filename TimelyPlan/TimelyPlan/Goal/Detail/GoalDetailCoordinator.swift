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
    
    init(multiColumnViewController: TPMultiColumnViewController) {
        self.multiColumnVC = multiColumnViewController
    }
    
    /// 显示目标计划详情
    func showDetail(for goalPlan: GoalPlan) {
        guard let multiColumnVC = multiColumnVC else {
            return
        }
        
        let vc = GoalDetailViewController(goalPlan: goalPlan)
        vc.didDeleteGoalPlan = { [weak self] _ in
            self?.showEmptyDetail()
        }
        
        let navController = UINavigationController(rootViewController: vc)
        multiColumnVC.replaceDetail(with: navController)
        multiColumnVC.showDetailView()
    }
    
    /// 显示空详情
    func showEmptyDetail() {
        guard let multiColumnVC = multiColumnVC else {
            return
        }
        
        let vc = emptyDetailViewController ?? makeEmptyDetailViewController()
        let navController = UINavigationController(rootViewController: vc)
        multiColumnVC.replaceDetail(with: navController)
        multiColumnVC.showFirstColumn()
    }
    
    /// 生成默认空详情视图控制器
    private func makeEmptyDetailViewController() -> UIViewController {
        let vc = TPMultiColumnEmptyDetailViewController()
        vc.placeholderImage = resGetImage("goal_list_80")
        vc.placeholderTitle = resGetString("Tap goal to view details")
        return vc
    }
}
