//
//  TodoTaskListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation
import UIKit

class TodoTaskListViewController: TodoTaskItemsViewController,
                                  TodoTaskListViewDelegate {
    
    /// 是否可以添加任务
    var canAddTask: Bool = true {
        didSet {
            updateAddView()
        }
    }
    
    /// 添加视图按钮
    private let addViewSize = CGSize(width: 50.0, height: 50.0)
    
    /// 添加视图边界间距
    private let addViewMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 20.0)
    
    /// 添加视图
    private var addView: TodoTaskAddView?
    
    /// 列表视图
    private lazy var listView: TodoTaskListView = {
        let view = TodoTaskListView(frame: .zero, style: style)
        view.delegate = self
        return view
    }()
    
    let style: UITableView.Style
    
    init(list: TodoListRepresentable, configuration: TodoListConfiguration, style: UITableView.Style = .insetGrouped) {
        self.style = style
        super.init(list: list, configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   override func viewDidLoad() {
       super.viewDidLoad()
       view.addSubview(listView)
       updateAddView()
       listView.reloadData()
   }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
        
        /// 布局添加视图
        if let addView = addView {
            let layoutFrame = view.safeAreaFrame()
            addView.size = addViewSize
            addView.bottom = layoutFrame.maxY - addViewMargins.bottom
            addView.right = layoutFrame.maxX - addViewMargins.right
        }
    }
    
    override func endEditing(animated: Bool) {
        listView.endEditing(animated: animated)
    }
    
    override func setSelecting(_ isSelecting: Bool) {
        super.setSelecting(isSelecting)
        listView.setSelecting(isSelecting)
        updateAddView()
    }
    
    override func isAllTaskSelected() -> Bool {
        return listView.isAllTasksSelected()
    }
    
    override func selectAllTasks() {
        guard isSelecting else {
            return
        }
        
        listView.selectAllTasks()
    }
    
    override func deselectAllTasks() {
        guard isSelecting else {
            return
        }
        
        listView.deselectAllTasks()
    }
    
    override func selectedTasks() -> Set<TodoTask> {
        return listView.selectedTasks
    }
    
    override func didUpdateListConfiguration(_ configuration: TodoListConfiguration) {
        super.didUpdateListConfiguration(configuration)
        listView.performUpdate()
    }
    
    // MARK: - 更新 UI
    /// 更新添加视图
    func updateAddView() {
        guard canAddTask else {
            addView?.removeFromSuperview()
            addView = nil
            view.setNeedsLayout()
            return
        }
    
        if addView == nil {
            let addView = TodoTaskAddView()
            addView.didClickAdd = { [weak self] button in
                self?.clickAdd(button)
            }
            
            self.addView = addView
        }
        
        if let addView = addView, !addView.isDescendant(of: view) {
            view.addSubview(addView)
        }
        
        self.addView?.isHidden = isSelecting ? true : false
        view.setNeedsLayout()
    }
    
    // MARK: - Event Response
    
    /// 点击添加
    @objc func clickAdd(_ button: UIButton){
        TPImpactFeedback.impactWithLightStyle()
        let task = TodoQuickAddTask()
        if let list = list as? TodoList {
            task.list = list
        }
        
        quickAddManager.show(with: task)
    }
    
    // MARK: - TodoTaskListViewDelegate
    func todoGroupsForTaskListView(_ listView: TodoTaskListView) -> [TodoGroup]? {
        return todo.getTaskGroups(for: list, with: configuration) { [weak self] group in
            #warning("检查分组是否收起")
            return false
        }
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didSelectTask task: TodoTask) {
        if task.isRemoved {
            taskController.confirmRestoration(for: task)
        } else {
            taskController.editTask(task)
        }
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didClickCheckboxForTask task: TodoTask) {
        taskController.clickCheckbox(for: task)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didChangeCollapsedForGroup group: TodoGroup) {
    }
    
    func todoTaskListViewDidChangeSelectedTasks(_ listView: TodoTaskListView) {
        selectedTasksDidChange()
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, leadingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        if task.isRemoved {
            ///< 恢复
            let restoreAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                self.taskController.restoreTrashTask(task)
                completion(true)
            }
            
            restoreAction.backgroundColor = Color(0x34C759)
            restoreAction.image = resGetImage("todo_task_action_restore_24")?.withTintColor(.white)
            actions.append(restoreAction)
        }
        
        ///< 移动
        let moveAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            self.taskController.moveTask(task)
            completion(true)
        }
        
        moveAction.backgroundColor = Color(0xFF9B00)
        moveAction.image = resGetImage("todo_task_action_move_24")?.withTintColor(.white)
        actions.append(moveAction)
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, trailingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        if task.isRemoved {
            /// 从废纸篓彻底粉碎
            let shredAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
                self.taskController.confirmDeletion(for: task)
                completion(true)
            }
            
            shredAction.image = resGetImage("todo_task_action_shred_24")?.withTintColor(.white)
            actions = [shredAction]
        } else {
            /// 废纸篓
            let trashAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
                self.taskController.moveToTrash(with: task)
                completion(true)
            }
                                
            trashAction.image = resGetImage("todo_task_action_trash_24")?.withTintColor(.white)
            actions = [trashAction]
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
}

extension TodoTaskListViewController: TodoListProcessorDelegate,
                                        TodoTaskProcessorDelegate,
                                        TodoStepProcessorDelegate {
    
    // MARK: - TodoListProcessorDelegate
    func didUpdateTodoList(_ list: TodoList) {
        guard configuration.groupType == .list, let identifier = list.identifier else {
            return
        }
        
        /// 按列表分组，更新头视图
        listView.updateHeaderFooterViewForSection(with: identifier)
    }
    
    func didReorderTodoList(_ list: TodoList) {
        guard configuration.groupType == .list, let identifier = list.identifier else {
            return
        }
        
        if listView.isSectionExist(with: identifier) {
            listView.performUpdate()
        }
    }
    
    func didMoveTodoList(_ list: TodoList, from folder: TodoFolder?) {
        /*
        guard configuration.groupType == .list else {
            return
        }
        
        var bShouldUpdate = false
        for list in lists {
            if  let identifier = list.identifier, listView.isSectionExist(with: identifier) {
                bShouldUpdate = true
                break
            }
        }
        
        if !bShouldUpdate {
            /// 检查移动源列表
            var identifier: String?
            if let sourceParent = sourceParent {
                identifier = sourceParent.identifier
            } else {
                /// 收件箱
                identifier = TodoSmartList.inbox.identifier
            }
            
            if  let identifier = identifier, listView.isSectionExist(with: identifier) {
                bShouldUpdate = true
            }
        }

        if bShouldUpdate {
            listView.performUpdate()
        }
        */
    }
    
    // MARK: - TodoTaskProcessorDelegate
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask]) {
        listView.performUpdate()
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask]) {
        listView.performUpdate()
    }
    
    func didCreateTodoTask(_ task: TodoTask, in list: TodoList?) {
        listView.performUpdate()
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        listView.performUpdate()
        listView.didDeleteTasks(tasks)
    }
    
    func didUpdateTodoTask(with infos: [TodoTaskChangeInfo]) {
        listView.didUpdate(with: infos)
        listView.performUpdate()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        listView.performUpdate()
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        listView.performUpdate()
    }
    
    func didMoveTodoTasks(with infos: [TodoTaskChangeInfo]) {
        listView.performUpdate()
    }
    
    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int) {
        listView.performUpdate()
    }
    
    // MARK: - TodoStepProcessorDelegate
    /// 添加新待办步骤
    func didAddTodoStep(_ step: TodoStep) {
        reloadCellForTask(with: step)
    }

    /// 更新步骤
    func didUpdateTodoStep(_ step: TodoStep, with change: TodoStepChange) {
        reloadCellForTask(with: step)
    }

    /// 删除步骤
    func didDeleteTodoStep(_ step: TodoStep, of task: TodoTask) {
        listView.reloadCell(for: task)
    }
    
    private func reloadCellForTask(with step: TodoStep) {
        guard let task = step.task else {
            return
        }
        
        listView.reloadCell(for: task)
    }
}
