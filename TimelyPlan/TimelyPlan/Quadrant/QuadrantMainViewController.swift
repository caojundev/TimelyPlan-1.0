//
//  QuadrantMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/26.
//

import Foundation
import UIKit

class QuadrantMainViewController: TPViewController,
                                  TPSidebarContent,
                                    SettingAgentObserver {

    var sidebarController: SidebarController?
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: QuadrantMoreBarButtonItem = {
        let item = QuadrantMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.didSelectMoreMenuType(type)
        }
        
        return item
    }()
    
    /// 象限矩阵视图
    private lazy var matrixView: QuadrantMatrixView = {
        let layout = QuadrantSetting.shared.layout
        let quadrants = layout.getQuadrants()
        var interactors = [QuadrantHomeListInteractor]()
        for quadrant in quadrants {
            let filterRule = QuadrantSetting.shared.filterRule(for: quadrant)
            let configuration = QuadrantListConfiguration(quadrant: quadrant,
                                                          filterRule: filterRule)
            let interactor = QuadrantHomeListInteractor(configuration: configuration)
            interactors.append(interactor)
        }
        
        let matrixView = QuadrantMatrixView(interactors: interactors)
        matrixView.delegate = self
        return matrixView
    }()
    
    /// 拖动管理器
    private var dragDropController: QuadrantDragDropController?

    /// 任务快速添加控制器
    lazy var quickAddManager: TodoTaskQuickAddManager = {
        let manager = TodoTaskQuickAddManager(containerViewController: self)
        return manager
    }()

    /// 象限任务移动控制器
    private lazy var taskMoveController: QuadrantTaskMoveController = {
        return QuadrantTaskMoveController()
    }()
    
    let taskController = TodoTaskController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Quadrants")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
    
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
        view.addSubview(matrixView)
        matrixView.loadData()
        setupDragDropController()
        QuadrantSetting.shared.addObserver(self)
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
        let showCompleted = !QuadrantSetting.shared.showCompleted
        QuadrantSetting.shared.showCompleted = showCompleted
    }
    
    private func toggleShowDetail() {
        let showDetail = !QuadrantSetting.shared.showDetail
        QuadrantSetting.shared.showDetail = showDetail
    }
    
    private func editViewLayout() {
        let layout = QuadrantSetting.shared.layout
        let vc = QuadrantLayoutEditViewController(layout: layout)
        vc.didEndEditing = { newLayout in
            QuadrantSetting.shared.layout = newLayout
        }
        
        vc.showAsNavigationRoot()
    }
    
    private func customQuadrantRule() {
        let rules = QuadrantSetting.shared.customRules
        let vc = QuadrantCustomRuleViewController(filterRules: rules)
        vc.didEndEditing = { newRules in
            QuadrantSetting.shared.customRules = newRules
        }
        
        vc.showAsNavigationRoot()
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        guard let settingKey = QuadrantSetting.Key(name: keyName) else {
            return
        }
        
        if settingKey == .layout {
            matrixView.updateLayout(animated: true)
        }
    }
}

extension QuadrantMainViewController: QuadrantViewDelegate {

    func quadrantViewDidClickAdd(_ view: QuadrantView) {
        matrixView.endEditingQuadrantViews()
        let task = view.interactor.matchingQuickAddTask
        if let draftTask = quickAddManager.draftTask {
            if !draftTask.matches(filterRule: view.interactor.filterRule) {
                quickAddManager.clearDraftTask()
            }
        }
        
        quickAddManager.show(with: task)
    }

    func quadrantViewDidTapTitleView(_ view: QuadrantView) {
        matrixView.endEditingQuadrantViews()
        let configuration = view.interactor.configuration
        let interactor = QuadrantDetailListInteractor(configuration: configuration)
        let detailVC = configuration.makeContent(with: interactor)
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func quadrantView(_ view: QuadrantView, didSelectTask task: TodoTask) {
        taskController.editTask(task)
    }
    
    func quadrantView(_ view: QuadrantView, didClickCheckboxForTask task: TodoTask) {
        matrixView.endEditingQuadrantViews()
        let dradrantView = view
        taskController.clickCheckbox(for: task) {isCompleted, execution in
            dradrantView.setCompleted(isCompleted, for: task) { _ in
                execution?()
            }
        } progressHandler: { progress, execution in
            dradrantView.setProgress(progress, for: task) {  _ in
                execution?()
            }
        }
    }
    
    func quadrantView(_ view: QuadrantView, leadingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        /// 我的一天
        let myDayAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.taskController.setAddToMyDay(!task.isAddedToMyDay, for: task)
            completion(true)
        }
        
        var myDayImage: UIImage?
        if task.isAddedToMyDay {
            myDayImage = resGetImage("todo_task_action_removeFromMyDay_24@2x")
            myDayAction.backgroundColor = .gray(5)
        } else {
            myDayImage = resGetImage("todo_task_action_addToMyDay_24@2x")
            myDayAction.backgroundColor = .greenPrimary
        }
        
        myDayAction.image = myDayImage?.withTintColor(.white)
        actions.append(myDayAction)
        
        /// 专注
        let focusAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.taskController.quickStartFocus(for: task)
            completion(true)
        }
        
        focusAction.backgroundColor = Color(0x5856D6)
        focusAction.image = resGetImage("focus_24")?.withTintColor(.white)
        actions.append(focusAction)
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func quadrantView(_ view: QuadrantView, trailingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()

        /// 计划
        let scheduleAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.taskController.editSchedule(for: task)
            completion(true)
        }

        scheduleAction.backgroundColor = .primary
        scheduleAction.image = resGetImage("todo_task_action_date_24")?.withTintColor(.white)
        
        /// 废纸篓
        let trashAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithMediumStyle()
            self.taskController.moveTaskToTrash(task)
            completion(true)
        }
                            
        trashAction.image = resGetImage("todo_task_action_trash_24")?.withTintColor(.white)
        actions = [scheduleAction, trashAction]
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func quadrantViewWillBeginDragging(_ view: QuadrantView) {
        matrixView.endEditingQuadrantViews()
    }
    
    func quadrantView(_ view: QuadrantView, willBeginEditingTask task: TodoTask) {
        matrixView.endEditingQuadrantViews(except: view)
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
