//
//  TodoTaskBoardViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation

class TodoTaskBoardViewController: TodoTaskItemsViewController {
    
    /// 列表视图
    private lazy var boardView: TodoTaskBoardView = {
        let view = TodoTaskBoardView()
        view.delegate = self
        return view
    }()
    
    private var reorder: TodoTaskBoardDragInsertReorder?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(boardView)
        boardView.reloadData()
        setupBoardReorder()
   }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        boardView.frame = view.bounds
    }

    override func setSelecting(_ isSelecting: Bool) {
        super.setSelecting(isSelecting)
        boardView.setSelecting(isSelecting)
    }

    override func isAllTaskSelected() -> Bool {
        return boardView.isAllTaskSelected()
    }
    
    override func selectAllTasks() {
        guard isSelecting else {
            return
        }
        
        boardView.selectAllTasks()
    }
    
    override func deselectAllTasks() {
        guard isSelecting else {
            return
        }
        
        boardView.deselectAllTasks()
    }
    
    override func selectedTasks() -> Set<TodoTask> {
        return boardView.selectedTasks()
    }
    
    override func didUpdateListConfiguration(_ configuration: TodoListConfiguration) {
        super.didUpdateListConfiguration(configuration)
        boardView.performUpdate()
    }
    
    func setupBoardReorder() {
        self.reorder = TodoTaskBoardDragInsertReorder(boardView: boardView)
    }
    
}

extension TodoTaskBoardViewController: TodoTaskBoardViewDelegate {
    
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didClickAddForGroup group: TodoGroup?) {
        TPImpactFeedback.impactWithLightStyle()
        
        let task = TodoQuickAddTask()
        if let list = list as? TodoList {
            task.list = list
        }
        
        quickAddManager.show(with: task)
    }
    
    func todoGroupsForTaskBoardView(_ boardView: TodoTaskBoardView) -> [TodoGroup]? {
        return todo.getTaskGroups(for: list, with: configuration)
    }
    
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didSelectTask task: TodoTask) {
        if task.isRemoved {
            taskController.confirmRestoration(for: task)
        } else {
            taskController.editTask(task)
        }
    }
    
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didClickCheckboxForTask task: TodoTask) {
        taskController.clickCheckbox(for: task)
    }
    
    func todoTaskBoardViewDidChangeSelectedTasks(_ boardView: TodoTaskBoardView) {
        selectedTasksDidChange()
    }
}

extension TodoTaskBoardViewController: TodoListProcessorDelegate,
                                        TodoTaskProcessorDelegate,
                                        TodoStepProcessorDelegate {
    
    // MARK: - TodoListProcessorDelegate
    func didUpdateTodoList(_ list: TodoList) {
        guard configuration.groupType == .list, let identifier = list.identifier else {
            return
        }
        
        /// 按列表分组，更新头视图
        boardView.updateTopView(for: identifier)
    }
    
    func didReorderTodoList(_ list: TodoList) {
        guard configuration.groupType == .list, let identifier = list.identifier else {
            return
        }
        
        if boardView.isPageExist(with: identifier) {
            /// 移动列表对应的页面存在则更新看板
            boardView.performUpdate()
        }
    }
    
    func didMoveTodoList(_ list: TodoList, from folder: TodoFolder?) {
        guard configuration.groupType == .list else {
            return
        }
        
        boardView.performUpdate()
    }
    
    // MARK: - TodoTaskProcessorDelegate
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask]) {
        boardView.updateCellContent(for: tasks)
        boardView.performUpdate()
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask]) {
        boardView.performUpdate()
    }
    
    func didCreateTodoTask(_ task: TodoTask, in list: TodoList?) {
        boardView.performUpdate()
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        boardView.performUpdate()
    }
    
    func didUpdateTodoTask(with infos: [TodoTaskChangeInfo]) {
        boardView.didUpdate(with: infos)
        boardView.performUpdate()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        boardView.performUpdate()
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        boardView.performUpdate()
    }
    
    func didMoveTodoTasks(with infos: [TodoTaskChangeInfo]) {
        boardView.performUpdate()
    }
    
    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int) {
        boardView.performUpdate()
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
        boardView.reloadCell(for: task)
    }
    
    private func reloadCellForTask(with step: TodoStep) {
        guard let task = step.task else {
            return
        }

        boardView.reloadCell(for: task)
    }
}
