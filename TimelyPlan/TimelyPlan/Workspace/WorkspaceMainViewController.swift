//
//  WorkspaceMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation
import UIKit

class WorkspaceMainViewController: TPViewController,
                                   TPSidebarContent,
                                   WSDashboardViewDelegate {
    
    struct Constants {
        
        /// 「完成编辑」按钮高度
        static let doneEditingButtonHeight = 50.0
        
        /// 「完成编辑」按钮内容左右内边距
        static let doneEditingButtonHorizontalPadding = 28.0
        
        /// 「完成编辑」按钮与底部安全区的间距
        static let doneEditingButtonBottomMargin = 16.0
    }
    
    var sidebarController: SidebarController?
    
    /// 仪表盘视图
    private lazy var dashboardView: WSDashboardView = {
        let dashboardView = WSDashboardView(frame: .zero)
        dashboardView.delegate = self
        dashboardView.elements = WSPluginElement.mockElements()
        return dashboardView
    }()
    
    /// 完成编辑按钮。仅排序模式下显示在底部中间
    private lazy var doneEditingButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.title = resGetString("Done Editing")
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.selectedBackgroundColor = .primary.darkerColor
        button.cornerRadius = .greatestFiniteMagnitude
        button.padding = UIEdgeInsets(horizontal: Constants.doneEditingButtonHorizontalPadding)
        button.isHidden = true
        button.addTarget(self, action: #selector(clickDoneEditing), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Workspace")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        navigationItem.rightBarButtonItem = addBarButtonItem
        self.setupSubviews()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dashboardView.frame = view.bounds
        layoutDoneEditingButton()
    }
    
    /// 布局底部中间的「完成编辑」按钮
    private func layoutDoneEditingButton() {
        let layoutFrame = view.safeLayoutFrame()
        let fitSize = doneEditingButton.sizeThatFits(CGSize(width: layoutFrame.width,
                                                            height: .greatestFiniteMagnitude))
        doneEditingButton.width = min(fitSize.width, layoutFrame.width)
        doneEditingButton.height = Constants.doneEditingButtonHeight
        doneEditingButton.bottom = layoutFrame.maxY - Constants.doneEditingButtonBottomMargin
        doneEditingButton.alignHorizontalCenter()
    }
    
    // MARK: - Event Response
    override func clickAdd() {
        super.clickAdd()
        showPluginPicker()
    }
    
    /// 点击「完成编辑」，退出排序模式
    @objc private func clickDoneEditing() {
        dashboardView.endReordering()
    }
    
    // MARK: - 组件选择
    /// 显示组件选择器
    private func showPluginPicker() {
        let pickerViewController = WSPluginPickerViewController()
        pickerViewController.didSelectModule = { [weak self] module in
            self?.addPlugin(for: module)
        }
        
        let navController = UINavigationController(rootViewController: pickerViewController)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 添加组件到工作台
    private func addPlugin(for module: WSPluginModule) {
        /// TODO: 待模块下的插件列表与组件增删能力就绪后补全
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.addSubview(dashboardView)
        /// 按钮浮在仪表盘之上，排序模式下显示
        view.addSubview(doneEditingButton)
        dashboardView.reloadData()
    }
}

// MARK: - WSDashboardViewDelegate
extension WorkspaceMainViewController {
    
    func dashboardView(_ dashboardView: WSDashboardView, didChangeReordering isReordering: Bool) {
        /// 排序模式下在底部中间显示「完成编辑」
        doneEditingButton.isHidden = !isReordering
        if isReordering {
            view.bringSubviewToFront(doneEditingButton)
        }
        
        /// 让内容让出按钮高度，避免最后一行被按钮遮挡
        let bottomInset = Constants.doneEditingButtonHeight + Constants.doneEditingButtonBottomMargin * 2.0
        dashboardView.contentInset = isReordering ? UIEdgeInsets(bottom: bottomInset) : .zero
    }
    
    func dashboardView(_ dashboardView: WSDashboardView,
                       didSelectMenuAction action: WSPluginCell.MenuActionType,
                       for element: WSPluginElement) {
        switch action {
        case .addPlugin:
            showPluginPicker()
        case .edit:
            /// 进入排序模式，组件抖动并支持长按拖动排序
            dashboardView.beginReordering()
        case .remove:
            /// TODO: 待组件增删能力就绪后补全
            break
        }
    }
}
