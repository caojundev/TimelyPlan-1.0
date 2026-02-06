//
//  MainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/11.
//

import Foundation
import UIKit

class MainViewController : TPSidebarViewController, SideMenuViewControllerDelegate {

    /// 侧边栏控制器
    lazy var sidebarController: SidebarController = {
        let controller = SidebarController()
        controller.sidebarViewController = self
        return controller
    }()
    
    /// 我的一天
    lazy var myDayViewController: UINavigationController = {
        let vc = MyDayMainViewController()
        vc.sidebarController = sidebarController
        return UINavigationController(rootViewController: vc)
    }()
    
    /// 待办
    lazy var todoViewController: TodoMainViewController = {
        let vc = TodoMainViewController()
        vc.sidebarController = sidebarController
        return vc
    }()
    
    /// 四象限
    lazy var quadrantViewController: UINavigationController = {
        let vc = QuadrantMainViewController()
        vc.sidebarController = sidebarController
        return UINavigationController(rootViewController: vc)
    }()
    
    /// 日历
    lazy var calendarViewController: UINavigationController = {
        let vc = CalendarMainViewController()
        vc.sidebarController = sidebarController
        return UINavigationController(rootViewController: vc)
    }()
    
    /// 专注
    lazy var focusViewController: UINavigationController = {
        let vc = FocusMainViewController()
        vc.sidebarController = sidebarController
        return UINavigationController(rootViewController: vc)
    }()
    
    /// 当前选中菜单
    var selectedMenuType: SideMenuType {
        get {
            return menuViewController.selectedMenuType
        }
    }
    
    /// 侧边栏菜单视图控制器
    private var menuViewController = SideMenuViewController(style: .grouped)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.menuViewController.delegate = self
        self.sidebarViewController = self.menuViewController
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.separatorColor = Color(0x888888, 0.1)
        self.replaceViewController(with: selectedMenuType)
    }
    
    private var mainViewSize: CGSize?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if mainViewSize != view.size {
            mainViewSize = view.size
            NotificationCenter.default.post(name: AppNotificationName.mainViewSizeDidChange.name, object: nil)
        }
    }
    
    // MARK: - Private Methods
    private func replaceViewController(with menuType: SideMenuType) {
        var vc: UIViewController
        switch menuType {
        case .myDay:
            vc = myDayViewController
        case .todo:
            vc = todoViewController
        case .quadrants:
            vc = quadrantViewController
        case .calendar:
            vc = calendarViewController
        case .focus:
            vc = focusViewController
        default:
            vc = UIViewController()
        }
   
        replaceDetailViewController(vc)
    }
    
    // MARK: - SideMenuViewControllerDelegate
    func sideMenuViewController(_ vc: SideMenuViewController, didSelect menuType: SideMenuType) {
        replaceViewController(with: menuType)
        sidebarController.hideSidebar()
    }
    
    func sideMenuViewControllerHideSideMenu(_ vc: SideMenuViewController) {
        sidebarController.hideSidebar()
    }

}
