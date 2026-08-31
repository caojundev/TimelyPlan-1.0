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
    
    /// 主页视图控制器
    lazy var homeViewController: GoalHomeViewController = {
        let viewController = GoalHomeViewController()
        return viewController
    }()
    
    private lazy var emptyDetailViewController: TPMultiColumnEmptyDetailViewController = {
        let vc = TPMultiColumnEmptyDetailViewController()
        vc.placeholderImage = resGetImage("goal_list_80")
        vc.placeholderTitle = resGetString("Tap goal to view details")
        return vc
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let detailNavController = UINavigationController(rootViewController: self.emptyDetailViewController)
        self.detailViewController = detailNavController
        
        let homeNavController = UINavigationController(rootViewController: self.homeViewController)
        self.columnViewControllers = [homeNavController]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
