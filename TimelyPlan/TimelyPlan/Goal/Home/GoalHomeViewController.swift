//
//  GoalHomeViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/30.
//

import Foundation
import UIKit

class GoalHomeViewController: TPTableViewController,
                               TPSidebarContent {
    
    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 50.0, height: 50.0)
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
    }
    
    /// 侧边栏控制器
    var sidebarController: SidebarController?
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: GoalMoreBarButtonItem = {
        let item = GoalMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(type)
        }
        
        return item
    }()
    
    /// 添加视图
    private var addView: TPAddView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Goal")
        navigationItem.leftBarButtonItem = sidebarController?.newMenuButtonItem()
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
        setupAddView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutAddView()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - 添加视图
    private func setupAddView() {
        if canAddGoal() {
            let addView = TPAddView()
            addView.normalBackgroundColor = .primary
            addView.didClickAdd = { [weak self] _ in
                self?.clickAddGoal()
            }
            
            self.addView = addView
            self.view.insertSubview(addView, at: 999)
        }
    }
    
    private func layoutAddView() {
        let layoutFrame = view.safeAreaFrame()
        if let addView = addView {
            addView.size = Config.addViewSize
            addView.bottom = layoutFrame.maxY - Config.addViewMargins.bottom
            addView.right = layoutFrame.maxX - Config.addViewMargins.right
        }
    }
    
    // MARK: - Event Response
    /// 执行更多菜单操作
    func performMoreMenuAction(_ type: GoalMoreMenuType) {
        switch type {
        case .archived:
            GoalPresenter.showArchived()
            break
        case .settings:
            GoalPresenter.showSetting()
            break
        }
    }
    
    /// 点击添加目标
    private func clickAddGoal() {
        TPImpactFeedback.impactWithLightStyle()
        GoalPresenter.createNewGoalPlan()
    }
    
    func canAddGoal() -> Bool {
        return true
    }
    
}
