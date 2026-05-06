//
//  TodoBaseTaskListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

class TodoBaseTaskListViewController: TodoDetailContentViewController,
                                      TodoTaskListViewDelegate {

    /// 列表视图
    private lazy var listView: TodoTaskListView = {
        let showDetail = self.interactor.showDetail
        let detailOption = self.interactor.configuration.detailOption()
        let listView = TodoTaskListView(frame: view.bounds,
                                        style: .insetGrouped,
                                        showDetail: showDetail)
        listView.detailOption = detailOption
        listView.expansionState = self.expansionState
        listView.delegate = self
        return listView
    }()

    private var reorder: TPTableDragInsertReorder?
    
    let expansionState: TodoTaskGroupExpansionState
    
    override init(interactor: TodoListInteractor) {
        let identifier = interactor.configuration.identifier
        self.expansionState = TodoTaskGroupExpansionState(identifier: identifier)
        super.init(interactor: interactor)
        self.interactor.resetLoadingState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listView.placeholderProvider = self.interactor.placeholderProvider
        self.listView.addRefreshControl()
        self.view.insertSubview(self.listView, at: 0)
        self.setupReorder()
        self.listView.reloadData()
        self.interactor.didChangeGroups = { [weak self] change in
            self?.groupsChanged(change)
        }
        
        self.interactor.setNeedsRefresh()
        self.interactor.loadGroups()
    }
    
    // MARK: - 分组改变
    private func groupsChanged(_ change: TodoTaskListChange? = nil) {
        var rowAnimation: UITableView.RowAnimation = .fade
        if change != nil {
            rowAnimation = .top
        }
        
        DispatchQueue.main.async {
            self.listView.groups = self.interactor.groups
            self.listView.performUpdate(with: rowAnimation)
            if case let .create(task) = change {
                self.listView.revealTask(task)
            }
        }
    }
    
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: self.listView.tableView)
        reorder.delegate = self
        reorder.isEnabled = true
        self.reorder = reorder
    }
    
    override func updateListViewFrame() {
        self.listView.frame = listViewFrame()
    }
    
    override func updateContentInset(with bottom: CGFloat) {
        listView.contentInset = UIEdgeInsets(bottom: bottom)
    }

    // MARK: - Override Base Methods
    override func toggleShowDetail() {
        super.toggleShowDetail()
        let showDetail = self.interactor.showDetail
        self.listView.setShowDetail(showDetail)
    }
    
    override func getIsSelecting() -> Bool {
        return listView.isSelecting
    }
    
    override func performEndEditing(animated: Bool) {
        listView.endEditing(animated: animated)
    }
    
    override func getSelectedTasks() -> Set<TodoTask> {
        return listView.selectedTasks
    }
    
    override func setSelecting(_ isSelecting: Bool) {
        guard listView.isSelecting != isSelecting else {
            return
        }
        
        listView.setSelecting(isSelecting)
        super.setSelecting(isSelecting)
    }
    
    override func performSelectAllTasks() {
        listView.selectAllTasks()
    }
    
    override func performDeselectAllTasks() {
        listView.deselectAllTasks()
    }
    
    override func isAllTasksSelected() -> Bool {
        return listView.isAllTasksSelected()
    }
    
    // MARK: - TodoTaskListViewDelegate
    func todoTaskListViewHandlePullRefresh(_ listView: TodoTaskListView) {
        self.interactor.setNeedsRefresh()
        self.interactor.loadGroups(with: nil)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didSelectTask task: TodoTask) {
        taskController.editTask(task)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, rescheduleTasks tasks: [TodoTask]) {
        taskController.editSchedule(for: tasks, completion: nil)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didClickCheckboxForTask task: TodoTask) {
        taskController.clickCheckbox(for: task) {isCompleted, execution in
            listView.setCompleted(isCompleted, for: task) { _ in
                execution?()
            }
        } progressHandler: { progress, execution in
            listView.setProgress(progress, for: task) {  _ in
                execution?()
            }
        }
    }
    
    func todoTaskListViewDidChangeSelectedTasks(_ listView: TodoTaskListView) {
        self.selectionDelegate?.todoTaskListDidUpdateSelectedTasks(to: listView.selectedTasks)
        self.updateToolView()
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, leadingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
        
        /// 优先级
        let priorityAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            let sourceView = listView.cellForRow(at: indexPath)
            self.taskController.editPriority(for: [task],
                                            sourceView: sourceView,
                                            preferredPosition: .bottomLeft)
            completion(true)
        }
        
        priorityAction.backgroundColor = .orange(4)
        priorityAction.image = resGetImage("todo_task_action_priority_24")?.withTintColor(.white)
        actions.append(priorityAction)
        
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
    
    func todoTaskListView(_ listView: TodoTaskListView, trailingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        
        /// 移动
        let moveAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.taskController.moveTask(task)
            completion(true)
        }
        
        moveAction.backgroundColor = Color(0xFF9B00)
        moveAction.image = resGetImage("todo_task_action_move_24")?.withTintColor(.white)
        
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
        actions = [scheduleAction, trashAction, moveAction]
        return UISwipeActionsConfiguration(actions: actions)
    }
}

// MARK: - 任务排序
extension TodoBaseTaskListViewController: TPTableDragInsertReorderDelegate {
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        listView.endEditing()
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        if isSelecting {
            return false
        }
        
        guard interactor is TodoUserListInteractor || interactor is TodoInboxListInteractor else {
            return false
        }
        
        return self.interactor.sort.type == .manually
    }

    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canInsertRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        return true
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard targetIndexPath.row != sourceIndexPath.row,
                let sourceTask = listView.task(at: sourceIndexPath),
                let targetTask = listView.task(at: targetIndexPath) else {
            return nil
        }
    
        var insertPosition: TodoTaskInsertPosition = .after
        if sourceIndexPath.row > targetIndexPath.row {
            insertPosition = .before
        }
        
        var list: TodoList?
        if let userListInteractor = self.interactor as? TodoUserListInteractor {
            list = userListInteractor.list
        }
        
        listView.moveRow(at: sourceIndexPath, to: targetIndexPath)
        todo.reorderTask(sourceTask, postion: insertPosition, targetTask: targetTask, in: list)
        return targetIndexPath
    }
}


