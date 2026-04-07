//
//  TodoListDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

protocol TodoDetailContent {
    
    /// 导航栏标题
    var navigationTitle: TextRepresentable? { get }
    
    /// 导航栏副标题
    var navigationSubtitle: TextRepresentable? { get }
    
    /// 左侧导航栏按钮项（通常用于返回、菜单等）
    var navigationLeftBarButtonItems: [UIBarButtonItem]? { get }
    
    /// 右侧导航栏按钮项（通常用于操作、保存、更多等）
    var navigationRightBarButtonItems: [UIBarButtonItem]? { get }
}

class TodoDetailViewController: TPMultiColumnDetailViewController,
                                TodoTaskListViewControllerDelegate {

    /// 标题视图
    private lazy var titleView: TPInfoView = {
        let view = TPInfoView()
        view.padding = .zero
        view.titleConfig.font = BOLD_SYSTEM_FONT
        view.titleConfig.textAlignment = .center
        view.subtitleConfig.textAlignment = .center
        return view
    }()
    
    let configuration: TodoListConfiguration
    
    init(configuration: TodoListConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        self.setupContentViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = titleView
        self.updateTitle()
        self.updateBarButtonItems()
    }
    
    /// 左侧导航栏按钮
    override func leftBarButtonItems() -> [UIBarButtonItem]? {
        if let items = self.detailContent?.navigationLeftBarButtonItems, items.count > 0 {
            return items
        }
        
        return super.leftBarButtonItems()
    }
    
    override func didClickMask(for containerView: TPColumnContainerView) {
        if let contentVC = self.contentViewController as? TodoTaskListViewController {
            contentVC.endSelecting()
        }
    }
    
    func setupContentViewController() {
        let contentVC = self.configuration.makeContent()
        if let contentVC = contentVC as? TodoTaskListViewController {
            contentVC.delegate = self
        }
        
        self.setContentViewController(contentVC)
    }
    
    var detailContent: TodoDetailContent? {
        return self.contentViewController as? TodoDetailContent
    }
    
    // MARK: - Update
    /// 更新标题
    private func updateTitle() {
        titleView.title = self.detailContent?.navigationTitle
        titleView.sizeToFit()
    }
    
    /// 更新副标题
    private func updateSubtitle() {
        titleView.subtitle = self.detailContent?.navigationSubtitle
        titleView.sizeToFit()
    }

    /// 更新导航栏按钮
    func updateBarButtonItems() {
        updateLeftBarButtonItems()
        navigationItem.rightBarButtonItems = self.detailContent?.navigationRightBarButtonItems
    }
    
    // MARK: - TodoTaskListViewControllerDelegate
    func taskListViewController(_ vc: TodoTaskListViewController, didChangeSelectionMode isSelecting: Bool) {
        self.updateBarButtonItems()
        self.updateSubtitle()
        
        if isSelecting {
            multiColumnViewController?.setUserInteractionEnabled(false, except: self)
        } else {
            multiColumnViewController?.setUserInteractionEnabled(true)
        }
    }
    
    func taskListViewController(_ vc: TodoTaskListViewController, didChangeSelectedTasks selectedTasks: Set<TodoTask>) {
        self.updateSubtitle()
        self.updateBarButtonItems()
    }
}
