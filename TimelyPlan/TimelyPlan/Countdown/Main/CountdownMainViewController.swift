//
//  CountdownMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/13.
//

import Foundation
import UIKit

class CountdownMainViewController: TPViewController,
                                    TPSidebarContent {
    
    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 50.0, height: 50.0)
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
    }
    
    /// 侧边栏控制器
    var sidebarController: SidebarController?
    
    /// 添加视图
    private var addView: TPAddView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = sidebarController?.newMenuButtonItem()
        setupAddView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutAddView()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .gray
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - 添加视图
    private func setupAddView() {
        if canAddCountdown() {
            let addView = TPAddView()
            addView.normalBackgroundColor = .primary
            addView.didClickAdd = { [weak self] _ in
                self?.clickAddCountdown()
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

    /// 点击添加倒数日
    private func clickAddCountdown() {
        guard let addView = addView else {
            return
        }

        TPImpactFeedback.impactWithLightStyle()
        
        // 创建气泡菜单视图（frame 传主视图的 bounds，triggerButtonFrame 传加号按钮的 frame）
        let bubbleMenu = BubbleMenuView(
            frame: view.bounds,
            triggerButtonFrame: addView.frame,
            menuItems: menuItems
        )
        
        bubbleMenu.onSelectMenuItem = { [weak self] menuItem in
            CountdownPresenter.createNewEvent()
        }
        
        // 添加到主视图并展示
        bubbleMenu.show(in: self.view)
    }
    
    func canAddCountdown() -> Bool {
        return true
    }
    
    // MARK: - 添加菜单
    // 菜单数据
    private let menuItems: [BubbleMenuItem] = [
        BubbleMenuItem(title: "Countdown", icon: "⏳"),
        BubbleMenuItem(title: "Anniversary", icon: "🕐"),
        BubbleMenuItem(title: "Birthday", icon: "🎂"),
        BubbleMenuItem(title: "Age", icon: "👶")
    ]
    
}
