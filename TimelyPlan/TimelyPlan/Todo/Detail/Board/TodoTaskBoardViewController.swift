//
//  TodoTaskBoardViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation
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
        let view = TodoTaskBoardView()
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
        view.addSubview(boardView)
        setupBoardReorder()
        boardView.reloadData()
        self.interactor.didChangeGroups = { [weak self] change in
            self?.groupsChanged(change)
        }
        
        if self.interactor.loadingState == .initialLoading {
            self.interactor.loadGroups()
        }
    }
    
    func setupBoardReorder() {
        self.reorder = TodoTaskBoardDragInsertReorder(boardView: boardView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        boardView.frame = view.bounds
    }
    
    // MARK: - 分组改变
    private func groupsChanged(_ change: TodoTaskListChange? = nil) {
        DispatchQueue.main.async {
            self.boardView.groups = self.interactor.groups
            self.boardView.performUpdate()
        }
    }

    // MARK: - Override Base Methods
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
    
    override func getSelectedTasksCount() -> Int {
        return boardView.selectedTasks.count
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
    
    func todoTaskBoardViewDidChangeSelectedTasks(_ boardView: TodoTaskBoardView) {
        self.selectionDelegate?.todoTaskListDidUpdateSelectedTasks(to: boardView.selectedTasks)
    }
}
