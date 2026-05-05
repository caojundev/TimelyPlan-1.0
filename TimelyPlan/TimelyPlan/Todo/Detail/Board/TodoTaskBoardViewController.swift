//
//  TodoTaskBoardViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation
import UIKit

class TodoTaskBoardViewController: TodoDetailContentViewController {
    
    /// 列表视图
    private lazy var boardView: TodoTaskBoardView = {
        let showDetail = self.interactor.showDetail
        let detailOption = self.interactor.configuration.detailOption()
        let view = TodoTaskBoardView(frame: view.bounds, showDetail: showDetail)
        view.detailOption = detailOption
        view.delegate = self
        return view
    }()
    
    private var reorder: TodoTaskBoardDragInsertReorder?

    override init(interactor: TodoListInteractor) {
        super.init(interactor: interactor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(boardView, at: 0)
        setupBoardReorder()
        boardView.reloadData()
        
        self.interactor.didChangeGroups = { [weak self] change in
            self?.groupsChanged(change)
        }
        
        self.interactor.setNeedsRefresh()
        self.interactor.loadGroups()
    }
    
    func setupBoardReorder() {
        let reorder = TodoTaskBoardDragInsertReorder(boardView: boardView)
        reorder.delegate = self
        self.reorder = reorder
    }

    override func updateListViewFrame() {
        self.boardView.frame = self.listViewFrame()
    }

    // MARK: - 分组改变
    private func groupsChanged(_ change: TodoTaskListChange? = nil) {
        DispatchQueue.main.async {
            self.boardView.groups = self.interactor.groups
            self.boardView.performUpdate()
        }
    }

    // MARK: - Override Base Methods
    override func toggleShowDetail() {
        super.toggleShowDetail()
        let showDetail = self.interactor.showDetail
        self.boardView.setShowDetail(showDetail)
    }
    
    override func editList() {
        guard let configuration = self.interactor.configuration as? TodoUserListConfiguration else {
            return
        }
        
        let listController = TodoUserListController()
        listController.editList(configuration.list)
    }
    
    override func getIsSelecting() -> Bool {
        return boardView.isSelecting
    }
    
    override func performEndEditing(animated: Bool) {
        boardView.endEditing(animated: animated)
    }
    
    override func getSelectedTasks() -> Set<TodoTask> {
        return boardView.selectedTasks
    }
    
    override func setSelecting(_ isSelecting: Bool) {
        guard boardView.isSelecting != isSelecting else {
            return
        }
        
        boardView.setSelecting(isSelecting)
        super.setSelecting(isSelecting)
    }
    
    override func performSelectAllTasks() {
        boardView.selectAllTasks()
    }
    
    override func performDeselectAllTasks() {
        boardView.deselectAllTasks()
    }
    
    override func isAllTasksSelected() -> Bool {
        return boardView.isAllTaskSelected()
    }
}

// MARK: - TodoTaskBoardViewDelegate
extension TodoTaskBoardViewController: TodoTaskBoardViewDelegate {

    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didClickAddForGroup group: TodoGroup?) {
        TPImpactFeedback.impactWithLightStyle()
        let task = self.interactor.configuration.quickAddTask()
        // TODO: 实现快速添加逻辑
    }
    
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didSelectTask task: TodoTask) {
        taskController.editTask(task)
    }
    
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didClickCheckboxForTask task: TodoTask) {
        taskController.clickCheckbox(for: task) { isCompleted, execution in
            boardView.setCompleted(isCompleted, for: task) { _ in
                execution?()
            }
        } progressHandler: { progress, execution in
            boardView.setProgress(progress, for: task) { _ in
                execution?()
            }
        }
    }
    
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, rescheduleTasks tasks: [TodoTask]) {
        taskController.editSchedule(for: tasks, completion: nil)
    }
    
    func todoTaskBoardViewDidChangeSelectedTasks(_ boardView: TodoTaskBoardView) {
        didChangeSelectedTasks()
    }
    
}

extension TodoTaskBoardViewController: TodoTaskBoardDragInsertReorderDelegate {
    
    func todoTaskBoardDragInsertReorder(_ reorder: TodoTaskBoardDragInsertReorder, canMoveItemAt indexPath: PageIndexPath) -> Bool {
        if isSelecting {
            return false
        }
        
        return true
    }
    
    func todoTaskBoardDragInsertReorder(_ reorder: TodoTaskBoardDragInsertReorder, canInsertItemTo targetIndexPath: PageIndexPath, from sourceIndexPath: PageIndexPath) -> Bool {
        return true
    }
    
    func todoTaskBoardDragInsertReorder(_ reorder: TodoTaskBoardDragInsertReorder, willBeginAt indexPath: PageIndexPath) {
    
    }
    
    func todoTaskBoardDragInsertReorderDidEnd(_ reorder: TodoTaskBoardDragInsertReorder) {
    
    }
    
    func todoTaskBoardDragInsertReorder(_ reorder: TodoTaskBoardDragInsertReorder, inserItemTo targetIndexPath: PageIndexPath, from sourceIndexPath: PageIndexPath) {
        
    }
    
}
