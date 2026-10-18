//
//  WorkspaceMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation
import UIKit

/// 工作台容器视图控制器。
///
/// 本身不承载具体业务，通过 `WorkspaceCoordinator` 协调当前展示的面板视图控制器
/// （`WSDashboardViewController`），并负责导航栏按钮的显示。
class WorkspaceMainViewController: TPContainerViewController,
                                   TPSidebarContent {
    
    struct Constants {
        
        /// 「完成」按钮高度
        static let doneBarButtonHeight = 32.0
        
        /// 「完成」按钮内容左右内边距
        static let doneBarButtonHorizontalPadding = 12.0
    }
    
    /// 侧边栏管理器
    var sidebarController: SidebarController? {
        didSet {
            updateNavigationBarItems()
        }
    }
    
    /// 工作台协调器
    private(set) lazy var coordinator: WorkspaceCoordinator = {
        return WorkspaceCoordinator(containerViewController: self)
    }()
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: WorkspaceMoreBarButtonItem = {
        let item = WorkspaceMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(type)
        }
        
        return item
    }()
    
    /// 完成编辑按钮。仅编辑模式下显示在导航栏右侧
    private lazy var doneEditingBarButtonItem: UIBarButtonItem = {
        let button = TPDefaultButton()
        button.title = resGetString("Done")
        button.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.selectedBackgroundColor = .primary.darkerColor
        button.cornerRadius = .greatestFiniteMagnitude
        button.padding = UIEdgeInsets(horizontal: Constants.doneBarButtonHorizontalPadding)
        button.addTarget(self, action: #selector(clickDoneEditing), for: .touchUpInside)
        
        /// 自定义视图需给出尺寸，否则导航栏无法正确布局
        let height = Constants.doneBarButtonHeight
        let fitSize = button.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: height))
        button.size = CGSize(width: fitSize.width, height: height)
        
        return UIBarButtonItem(customView: button)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator.start()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - 导航栏
    /// 根据当前面板状态更新导航栏显示
    func updateNavigationBarItems() {
        /// 标题取当前面板名称，面板未命名时使用默认标题
        title = coordinator.dashboard?.name ?? resGetString("Workspace")
        
        /// 侧边栏按钮
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        
        /// 编辑模式下右侧仅显示「完成」按钮，添加与更多按钮不显示
        let isReordering = coordinator.dashboardViewController?.isReordering ?? false
        navigationItem.rightBarButtonItems = isReordering ? [doneEditingBarButtonItem]
                                                          : [moreBarButtonItem,
                                                             addBarButtonItem]
    }
    
    // MARK: - Event Response
    override func clickAdd() {
        super.clickAdd()
        coordinator.showPluginPicker()
    }
    
    /// 点击「完成」，退出编辑模式
    @objc private func clickDoneEditing() {
        TPImpactFeedback.impactWithSoftStyle()
        coordinator.endReordering()
    }
    
    // MARK: - 更多菜单
    /// 处理更多菜单动作
    private func performMoreMenuAction(_ type: WorkspaceMoreMenuType) {
        switch type {
        case .editDashboard:
            /// 进入编辑模式，组件抖动并支持拖动排序
            coordinator.beginReordering()
        }
    }
}
