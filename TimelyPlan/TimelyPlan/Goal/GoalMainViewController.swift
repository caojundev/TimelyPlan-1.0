//
//  GoalMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/30.
//

import Foundation
import UIKit

class GoalMainViewController: TPMultiColumnViewController,
                              TPSidebarContent {
    
    /// 侧边栏管理器
    var sidebarController: SidebarController? {
        didSet {
            homeViewController.sidebarController = sidebarController
        }
    }
    
    private lazy var detailCoordinator: GoalDetailCoordinator = {
        let coordinator = GoalDetailCoordinator(multiColumnViewController: self)
        coordinator.emptyDetailViewController = self.emptyDetailViewController
        return coordinator
    }()
    
    /// 主页视图控制器
    lazy var homeViewController: GoalHomeViewController = {
        let viewController = GoalHomeViewController(detailCoordinator: self.detailCoordinator)
        return viewController
    }()
    
    private lazy var emptyDetailViewController: UINavigationController = {
        let vc = TPMultiColumnEmptyDetailViewController()
        vc.placeholderImage = resGetImage("goal_placeholder_80")
        vc.placeholderTitle = resGetString("Tap goal to view details")
        return UINavigationController(rootViewController: vc)
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.detailViewController = emptyDetailViewController
        
        let homeNavController = UINavigationController(rootViewController: self.homeViewController)
        self.columnViewControllers = [homeNavController]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
