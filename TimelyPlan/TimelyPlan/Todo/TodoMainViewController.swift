//
//  TodoMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/29.
//

import Foundation

class TodoMainViewController: TPMultiColumnViewController,
                                TPSidebarContent {
    
    /// 侧边栏管理器
    var sidebarController: SidebarController? {
        didSet {
            homeViewController.sidebarController = sidebarController
        }
    }

    private lazy var detailCoordinator: TodoDetailCoordinator = {
        return TodoDetailCoordinator(multiColumnViewController: self)
    }()
    
    /// 主页视图控制器
    lazy var homeViewController: TodoHomeViewController = {
        let viewController = TodoHomeViewController(detailCoordinator: self.detailCoordinator)
        return viewController
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let homeNavigationController = UINavigationController(rootViewController: self.homeViewController)
        self.columnViewControllers = [homeNavigationController]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
