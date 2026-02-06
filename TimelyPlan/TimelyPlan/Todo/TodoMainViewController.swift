//
//  TodoMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/29.
//

import Foundation

class TodoMainViewController: TPMultiColumnViewController,
                                TFSidebarContent,
                                TodoHomeViewControllerDelegate,
                                TodoListProcessorDelegate {
    
    /// 侧边栏管理器
    var sidebarController: SidebarController? {
        didSet {
            homeViewController.sidebarController = sidebarController
        }
    }

    /// 主页视图控制器
    lazy var homeViewController: TodoHomeViewController = {
        let viewController = TodoHomeViewController(style: .grouped)
        viewController.delegate = self
        return viewController
    }()
    
    /// 当前视图控制器
    private var currentViewController: TodoDetailViewController?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        self.columnViewControllers = [homeNavigationController]
        todo.addUpdater(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - TodoHomeViewControllerDelegate
    func homeViewController(_ viewController: TodoHomeViewController, didSelectSmartList list: TodoSmartList) {
        self.showList(list)
        self.showDetailView()
    }
    
    func homeViewController(_ viewController: TodoHomeViewController, didSelectUserList list: TodoList) {
        self.showList(list)
        self.showDetailView()
    }
    
    // MARK: - 显示列表
    /// 显示列表详情
    func showList(_ list: TodoListRepresentable) {
        if let vc = self.currentViewController, vc.list.isEqual(list) {
            return
        }

        let vc = TodoDetailViewController(list: list)
        self.currentViewController = vc
        let navController = UINavigationController(rootViewController: vc)
        self.replaceDetail(with: navController)
    }
    
    // MARK: - TodoListProcessorDelegate
    func didDeleteTodoList(_ list: TodoList, from folder: TodoFolder?) {
        guard let vc = self.currentViewController, let currentList = vc.list as? TodoList else {
            return
        }

        if list == currentList {
            /// 默认选择收件箱列表
            showList(TodoSmartList.inbox)
        }
    }
}
