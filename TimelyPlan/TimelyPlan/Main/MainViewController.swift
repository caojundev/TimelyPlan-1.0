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
    
    /// 工作台
    lazy var workspaceViewController: UINavigationController = {
        let vc = WorkspaceMainViewController()
        vc.sidebarController = sidebarController
        return UINavigationController(rootViewController: vc)
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
    
    /// 目标
    lazy var goalViewController: GoalMainViewController = {
        let vc = GoalMainViewController()
        vc.sidebarController = sidebarController
        return vc
    }()
    
    /// 时间线
    lazy var timelineViewController: UINavigationController = {
        let vc = GanttTimelineMainViewController()
        vc.sidebarController = sidebarController
        return UINavigationController(rootViewController: vc)
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
    
    /// 习惯
    lazy var habitViewController: UINavigationController = {
        let vc = HabitMainViewController()
        vc.sidebarController = sidebarController
        return UINavigationController(rootViewController: vc)
    }()
        
    lazy var countdownViewController: UIViewController = {
        let vc = CountdownMainViewController()
        vc.sidebarController = sidebarController
        return UINavigationController(rootViewController: vc)
    }()

    var settingsViewController: UIViewController {
        let vc = AppSettingsViewController()
        vc.sidebarController = sidebarController
        return UINavigationController(rootViewController: vc)
    }
    
    /// 当前选中菜单
    var selectedMenuType: SideMenuType {
        get {
            return menuViewController.selectedMenuType
        }
    }
    
    /// 侧边栏菜单视图控制器
    private var menuViewController = SideMenuViewController(style: .grouped)
    
    /// 跳转目标菜单，用于判断是否需要展示返回工作台的按钮
    private var pendingJumpMenuType: SideMenuType?

    /// 返回工作台按钮管理器
    private let jumpBackButtonManager = MainJumpBackButtonManager()

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
        self.jumpBackButtonManager.clickHandler = { [weak self] in
            self?.backToWorkspace()
        }
        self.replaceViewController(with: selectedMenuType)
    }
    
    private var mainViewSize: CGSize?
    
    override func viewWillLayoutSubviews() {
        /// 拖拽侧边栏期间基类会 relayout 重置容器位置，导致不跟手，此时跳过
        if !isDragging {
            super.viewWillLayoutSubviews()
        }

        if mainViewSize != view.size {
            mainViewSize = view.size
            NotificationCenter.default.post(name: .notificationMainViewSizeDidChange, object: nil)
        }
    }

    override func setExpand(_ shouldExpand: Bool, animated: Bool, forceLayout: Bool) {
        super.setExpand(shouldExpand, animated: animated, forceLayout: forceLayout)
        if shouldExpand {
            /// 展开侧边栏时移除返回工作台按钮
            jumpBackButtonManager.hide(animated: animated)
        }
    }

    // MARK: - UIGestureRecognizerDelegate
    /// 触摸落在返回按钮上时不响应侧边栏手势，避免与按钮拖动冲突
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                    shouldReceive touch: UITouch) -> Bool {
        guard !jumpBackButtonManager.isTouchInsideButton(touch) else {
            return false
        }

        return super.gestureRecognizer(gestureRecognizer, shouldReceive: touch)
    }

    private(set) var isFirstAppearance = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppearance {
            isFirstAppearance = false
            handleFirstAppearance()
        }
    }
    
    private func handleFirstAppearance() {
        // 任务通知分发器标记主界面已准备好
        TaskNotificationDispatcher.shared.markMainViewReady()
        
        /// 习惯记录结果弹窗管理器开始监测
        HabitRecordPopupManager.shared.startObserving()
    }
    
    // MARK: - Private Methods
    private func replaceViewController(with menuType: SideMenuType,
                                       transition: DetailTransition = .none) {
        var vc: UIViewController
        switch menuType {
        case .workspace:
            vc = workspaceViewController
        case .myDay:
            vc = myDayViewController
        case .todo:
            vc = todoViewController
        case .timeline:
            vc = timelineViewController
        case .quadrants:
            vc = quadrantViewController
        case .calendar:
            vc = calendarViewController
        case .goal:
            vc = goalViewController
        case .focus:
            vc = focusViewController
        case .habit:
            vc = habitViewController
        case .countdown:
            vc = countdownViewController
        case .settings:
            vc = settingsViewController
        }
   
        replaceDetailViewController(vc, transition: transition)
    }
    
    // MARK: - 跳转
    /// 跳转到指定模块。工作台与设置不作为跳转目标
    func jump(to menuType: SideMenuType) {
        guard menuType != .workspace, menuType != .settings else {
            return
        }

        /// 侧边栏可能尚未加载，先完成加载以初始化菜单列表
        menuViewController.loadViewIfNeeded()
        guard menuType != selectedMenuType else {
            return
        }

        pendingJumpMenuType = menuType
        menuViewController.select(menuType)
    }

    /// 返回工作台
    private func backToWorkspace() {
        menuViewController.loadViewIfNeeded()
        menuViewController.select(.workspace)
    }

    // MARK: - SideMenuViewControllerDelegate
    func sideMenuViewController(_ vc: SideMenuViewController, didSelect menuType: SideMenuType) {
        /// 仅由跳转进入的非工作台模块才提供返回工作台的入口
        let showsBackButton = pendingJumpMenuType == menuType && menuType != .workspace
        /// 跳转进入时新页面向前推入，返回工作台时新页面从后方顶入（反向）
        let isReturningToWorkspace = menuType == .workspace && jumpBackButtonManager.isShowing
        pendingJumpMenuType = nil

        let transition: DetailTransition
        if showsBackButton {
            transition = .push
        } else if isReturningToWorkspace {
            transition = .pop
        } else {
            transition = .none
        }

        /// 过渡快照不参与返回按钮，离开跳转页时先立即移除
        if !showsBackButton {
            jumpBackButtonManager.hide(animated: false)
        }

        replaceViewController(with: menuType, transition: transition)
        sidebarController.hideSidebar()
        if showsBackButton {
            jumpBackButtonManager.show(in: detailContainerView)
        }
        
        if menuType != .settings {
            /// 保存选中侧边栏状态
            AppState.shared.sideMenuType = menuType
        }
    }
    
    func sideMenuViewControllerHideSideMenu(_ vc: SideMenuViewController) {
        sidebarController.hideSidebar()
    }
}
