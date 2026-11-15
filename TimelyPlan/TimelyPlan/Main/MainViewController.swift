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

    /// 返回工作台按钮尺寸
    private let jumpBackButtonSize = CGSize(width: 30.0, height: 60.0)

    /// 返回工作台按钮是否显示
    private var isJumpBackButtonVisible = false

    /// 吸附在内容区左侧中间边缘的返回工作台按钮
    private lazy var jumpBackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = resGetImage("chevron_left_24")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryLabel
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = self.jumpBackButtonSize.width / 2.0
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 6.0
        button.layer.shadowOffset = CGSize(width: 2.0, height: 0.0)
        button.addTarget(self, action: #selector(clickJumpBackButton(_:)), for: .touchUpInside)
        return button
    }()

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
            NotificationCenter.default.post(name: .notificationMainViewSizeDidChange, object: nil)
        }
        layoutJumpBackButton()
    }

    override func setExpand(_ shouldExpand: Bool, animated: Bool, forceLayout: Bool) {
        super.setExpand(shouldExpand, animated: animated, forceLayout: forceLayout)
        if shouldExpand {
            /// 展开侧边栏时移除返回工作台按钮
            setJumpBackButtonVisible(false, animated: animated)
        }
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
    private func replaceViewController(with menuType: SideMenuType) {
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
   
        replaceDetailViewController(vc)
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
        peekSidebar(width: sidebarWidth * 0.8) { [weak self] in
            self?.menuViewController.select(menuType)
        }
    }

    /// 返回工作台
    private func backToWorkspace() {
        menuViewController.loadViewIfNeeded()
        menuViewController.select(.workspace)
    }

    // MARK: - 返回工作台按钮
    /// 设置返回工作台按钮的显示状态
    private func setJumpBackButtonVisible(_ visible: Bool, animated: Bool = true) {
        guard visible != isJumpBackButtonVisible else {
            return
        }
        
        isJumpBackButtonVisible = visible
        if visible {
            detailContainerView.addSubview(jumpBackButton)
            jumpBackButton.left = -jumpBackButtonSize.width
            jumpBackButton.alpha = 0.0

            let animations = {
                self.layoutJumpBackButton()
                self.jumpBackButton.alpha = 1.0
            }

            guard animated else {
                animations()
                return
            }

            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations: animations)
            return
        }

        guard animated else {
            jumpBackButton.removeFromSuperview()
            return
        }

        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .beginFromCurrentState,
                       animations: {
            self.jumpBackButton.alpha = 0.0
        }, completion: { _ in
            guard !self.isJumpBackButtonVisible else {
                return
            }
            
            self.jumpBackButton.removeFromSuperview()
        })
    }

    private func layoutJumpBackButton() {
        guard isJumpBackButtonVisible, jumpBackButton.superview != nil else {
            return
        }

        jumpBackButton.size = jumpBackButtonSize
        jumpBackButton.left = 0.0
        jumpBackButton.centerY = detailContainerView.bounds.midY
    }

    @objc private func clickJumpBackButton(_ button: UIButton) {
        TPImpactFeedback.impactWithLightStyle()
        backToWorkspace()
    }

    // MARK: - SideMenuViewControllerDelegate
    func sideMenuViewController(_ vc: SideMenuViewController, didSelect menuType: SideMenuType) {
        /// 仅由跳转进入的非工作台模块才提供返回工作台的入口
        let showsBackButton = pendingJumpMenuType == menuType && menuType != .workspace
        pendingJumpMenuType = nil

        replaceViewController(with: menuType)
        sidebarController.hideSidebar()
        setJumpBackButtonVisible(showsBackButton)
        
        if menuType != .settings {
            /// 保存选中侧边栏状态
            AppState.shared.sideMenuType = menuType
        }
    }
    
    func sideMenuViewControllerHideSideMenu(_ vc: SideMenuViewController) {
        sidebarController.hideSidebar()
    }
}
