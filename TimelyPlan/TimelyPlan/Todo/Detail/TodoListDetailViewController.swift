//
//  TodoListDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

protocol TodoDetailContent {
    
    var selectionDelegate: TodoTaskListSelectionDelegate? { get set}
    
    /// 导航栏标题
    var navigationTitle: TextRepresentable? { get }
    
    /// 导航栏副标题
    var navigationSubtitle: TextRepresentable? { get }
    
    /// 左侧导航栏按钮项（通常用于返回、菜单等）
    var navigationLeftBarButtonItems: [UIBarButtonItem]? { get }
    
    /// 右侧导航栏按钮项（通常用于操作、保存、更多等）
    var navigationRightBarButtonItems: [UIBarButtonItem]? { get }
    
    /// 结束编辑模式
    func endSelecting()
}

class TodoDetailViewController: TPMultiColumnDetailViewController,
                                TodoTaskListSelectionDelegate {

    /// 标题视图
    private lazy var titleView: TPInfoView = {
        let view = TPInfoView()
        view.padding = .zero
        view.titleConfig.font = BOLD_SYSTEM_FONT
        view.titleConfig.textAlignment = .center
        view.subtitleConfig.textAlignment = .center
        return view
    }()
    
    var configuration: TodoListConfiguration {
        return interactor.configuration
    }
    
    let interactor: TodoListInteractor
    
    init(configuration: TodoListConfiguration) {
        self.interactor = TodoListInteractor.interactor(for: configuration)
        super.init(nibName: nil, bundle: nil)
        self.interactor.didChangeLayoutType = { [weak self] in
            self?.setupContentViewController()
        }
        
        self.interactor.didChangeListInfo = { [weak self] in
            self?.updateTitle()
        }
        
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
        if let contentVC = self.contentViewController as? TodoDetailContent {
            contentVC.endSelecting()
        }
    }
    
    func setupContentViewController() {
        let contentVC = configuration.makeContent(with: self.interactor)
        if var contentVC = contentVC as? TodoDetailContent {
            contentVC.selectionDelegate = self
        }
        
        self.setContentViewController(contentVC)
        self.updateTitle()
        self.updateBarButtonItems()
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
    
    // MARK: - TodoTaskListSelectionDelegate
    func todoTaskListDidUpdateSelectionMode(to isSelecting: Bool) {
        self.updateBarButtonItems()
        self.updateSubtitle()
        
        if isSelecting {
            multiColumnViewController?.setUserInteractionEnabled(false, except: self)
        } else {
            multiColumnViewController?.setUserInteractionEnabled(true)
        }
    }
    
    func todoTaskListDidUpdateSelectedTasks(to selectedTasks: Set<TodoTask>) {
        self.updateSubtitle()
        self.updateBarButtonItems()
    }
    
}
