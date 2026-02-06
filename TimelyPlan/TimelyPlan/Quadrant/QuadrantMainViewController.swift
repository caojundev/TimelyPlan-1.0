//
//  QuadrantMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/26.
//

import Foundation
import UIKit

class QuadrantMainViewController: TPViewController,
                                  TFSidebarContent {

    var sidebarController: SidebarController?
    
    /// 象限矩阵视图
    private lazy var matrixView: QuadrantMatrixView = {
        let matrixView = QuadrantMatrixView(frame: view.bounds)
        matrixView.delegate = self
        return matrixView
    }()
    
    /// 拖动管理器
    private var dragDropController: QuadrantDragDropController?
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: QuadrantMoreBarButtonItem = {
        let item = QuadrantMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.didSelectMoreMenuType(type)
        }
        
        return item
    }()
    
    /// 任务快速添加控制器
    lazy var quickAddManager: TodoTaskQuickAddManager = {
        let manager = TodoTaskQuickAddManager(containerViewController: self)
        return manager
    }()

    /// 象限任务移动控制器
    private lazy var taskMoveController: QuadrantTaskMoveController = {
        return QuadrantTaskMoveController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Quadrants")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
    
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
        view.addSubview(matrixView)
        setupDragDropController()
        matrixView.asyncReloadData()
        todo.addUpdater(self)
        
        QuadrantSettingAgent.shared.didChangeSettingValue = { [weak self] key in
            self?.changeSettingValue(forKey: key)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        matrixView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func setupDragDropController() {
        let controller = QuadrantDragDropController(matrixView: matrixView)
        controller.delegate = self
        controller.isEnabled = true
        self.dragDropController = controller
    }
    
    // MARK: - 菜单操作
    private func didSelectMoreMenuType(_ type: QuadrantMoreMenuType) {
        switch type {
        case .showCompleted:
            toggleShowCompleted()
        case .showDetail:
            toggleShowDetail()
        case .viewLayout:
            editViewLayout()
        case .customRule:
            customQuadrantRule()
        }
    }
    
    private func toggleShowCompleted() {
        let showCompleted = !QuadrantSettingAgent.shared.showCompleted
        QuadrantSettingAgent.shared.showCompleted = showCompleted
    }
    
    private func toggleShowDetail() {
        let showDetail = !QuadrantSettingAgent.shared.showDetail
        QuadrantSettingAgent.shared.showDetail = showDetail
    }
    
    private func editViewLayout() {
        let layout = QuadrantSettingAgent.shared.layout
        let vc = QuadrantLayoutEditViewController(layout: layout)
        vc.didEndEditing = { newLayout in
            QuadrantSettingAgent.shared.layout = newLayout
        }
        
        vc.showAsNavigationRoot()
    }
    
    private func customQuadrantRule() {
        let rules = QuadrantSettingAgent.shared.customRules
        let vc = QuadrantCustomRuleViewController(filterRules: rules)
        vc.didEndEditing = { newRules in
            QuadrantSettingAgent.shared.customRules = newRules
        }
        
        vc.showAsNavigationRoot()
    }
    
    // MARK: - SettingAgentObserver
    private func changeSettingValue(forKey key: QuadrantSettingKey) {
        switch key {
        case .showCompleted:
            matrixView.asyncPerformUpdate()
        case .showDetail:
            matrixView.updateQuadrantShowDetail()
        case .layout:
            matrixView.updateLayout(animated: true)
        case .customRules:
            matrixView.asyncReloadData()
        }
    }
}

extension QuadrantMainViewController: QuadrantDragDropControllerDelegate {
    
    func quadrantDragDropController(_ controller: QuadrantDragDropController, canMoveItemAt indexPath: QuadrantIndexPath) -> Bool {
        return true
    }
    
    func quadrantDragDropController(_ controller: QuadrantDragDropController, canMoveItemTo quadrant: Quadrant) -> Bool {
        return true
    }
    
    func quadrantDragDropController(_ controller: QuadrantDragDropController, moveItemAt indexPath: QuadrantIndexPath, to quadrant: Quadrant) {
        guard let task = matrixView.task(at: indexPath) else {
            return
        }
        
        taskMoveController.moveTask(task, to: quadrant)
    }
}

extension QuadrantMainViewController: QuadrantMatrixViewDelegate {
    
    func quadrantMatrixView(_ view: QuadrantMatrixView, fetcherForQuadrant quadrant: Quadrant) -> QuadrantFetcher {
        return QuadrantFetcher(quadrant: quadrant)
    }
    
    func quadrantMatrixView(_ view: QuadrantMatrixView, didClickAddForQuadrant quadrant: Quadrant) {
        let task = TodoQuickAddTask.defaultTask(for: quadrant)
        quickAddManager.show(with: task)
    }
    
    func quadrantMatrixView(_ view: QuadrantMatrixView, didClickTapTitleForQuadrant quadrant: Quadrant) {
        
    }
}

extension QuadrantMainViewController: TodoTaskProcessorDelegate,
                                      TodoStepProcessorDelegate {
    
    // MARK: - TodoTaskProcessorDelegate
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask]) {
        matrixView.asyncPerformUpdate()
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask]) {
        matrixView.asyncPerformUpdate()
    }
    
    func didCreateTodoTask(_ task: TodoTask, in list: TodoList?) {
        matrixView.asyncPerformUpdate()
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        matrixView.didDeleteTasks(tasks)
        matrixView.asyncPerformUpdate()
    }
    
    func didUpdateTodoTask(with infos: [TodoTaskChangeInfo]) {
        matrixView.didUpdate(with: infos)
        matrixView.asyncPerformUpdate()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        matrixView.asyncPerformUpdate()
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        matrixView.asyncPerformUpdate()
    }
    
    func didMoveTodoTasks(with infos: [TodoTaskChangeInfo]) {
        matrixView.asyncPerformUpdate()
    }
    
    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int) {
        matrixView.asyncPerformUpdate()
    }
    
    // MARK: - TodoStepProcessorDelegate
    func didAddTodoStep(_ step: TodoStep) {
        if let task = step.task {
            matrixView.reloadCell(for: task)
        }
    }

    func didUpdateTodoStep(_ step: TodoStep, with change: TodoStepChange) {
        if let task = step.task {
            matrixView.reloadCell(for: task)
        }
    }

    func didDeleteTodoStep(_ step: TodoStep, of task: TodoTask) {
        matrixView.reloadCell(for: task)
    }
}
