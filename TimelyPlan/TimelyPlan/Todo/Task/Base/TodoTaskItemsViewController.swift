//
//  TodoTaskItemsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/18.
//

import Foundation

protocol TodoTaskItemsViewControllerDelegate: AnyObject {
    
    /// 选中任务改变
    func selectedTasksDidChange()
}

class TodoTaskItemsViewController: TPViewController,
                                    TodoListConfigurationUpdateDelegate {
    
    /// 代理对象
    weak var delegate: TodoTaskItemsViewControllerDelegate?
    
    /// 任务管理器
    let taskController = TodoTaskController()

    /// 任务快速添加控制器
    lazy var quickAddManager: TodoTaskQuickAddManager = {
        let manager = TodoTaskQuickAddManager(containerViewController: self)
        return manager
    }()
    
    /// 是否为选择模式
    private(set) var isSelecting: Bool = false
    
    /// 列表
    private(set) var list: TodoListRepresentable
    
    /// 列表配置
    private(set) var configuration: TodoListConfiguration
    
    init(list: TodoListRepresentable, configuration: TodoListConfiguration) {
        self.list = list
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        todo.addUpdater(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 结束编辑模式
    func endEditing(animated: Bool) {
        
    }
    
    /// 选择模式
    func setSelecting(_ isSelecting: Bool) {
        self.isSelecting = isSelecting
    }

    /// 选中所有任务
    func selectAllTasks() {
        
    }
    
    /// 反选所有任务
    func deselectAllTasks() {
        
    }
    
    /// 是否全部任务都选中
    func isAllTaskSelected() -> Bool {
        return false
    }
    
    /// 选中任务
    func selectedTasks() -> Set<TodoTask> {
        return []
    }
    
    /// 选中任务数目
    func selectedTasksCount() -> Int {
        let tasks = selectedTasks()
        return tasks.count
    }

    /// 选中任务发生改变
    func selectedTasksDidChange() {
        delegate?.selectedTasksDidChange()
    }
    
    // MARK: - TodoListConfigurationUpdateDelegate
    func didUpdateListConfiguration(_ configuration: TodoListConfiguration) {
        self.configuration = configuration
    }
}
