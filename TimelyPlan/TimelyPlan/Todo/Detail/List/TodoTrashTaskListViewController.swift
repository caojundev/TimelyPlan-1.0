//
//  TodoTrashTaskListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/7.
//

import Foundation

class TodoTrashTaskListViewController: TodoBaseTaskListViewController {
    
    override func selectListOption(_ option: TodoListOption) {
        if option == .emptyTrash {
            self.taskController.emptyTrash()
            return
        }
        
        super.selectListOption(option)
    }
    
    override func todoTaskListView(_ listView: TodoTaskListView, didClickCheckboxForTask task: TodoTask) {
        self.taskController.confirmRestoration(for: task)
    }
    
    override func todoTaskListView(_ listView: TodoTaskListView, didSelectTask task: TodoTask) {
        self.taskController.confirmRestoration(for: task)
    }
    
    override func todoTaskListView(_ listView: TodoTaskListView, leadingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        ///< 恢复
        let restoreAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            self.taskController.restoreTrashTask(task)
            completion(true)
        }
        
        restoreAction.backgroundColor = Color(0x34C759)
        restoreAction.image = resGetImage("todo_task_action_restore_24")?.withTintColor(.white)
        return UISwipeActionsConfiguration(actions: [restoreAction])
    }
    
    override func todoTaskListView(_ listView: TodoTaskListView, trailingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        /// 从废纸篓彻底粉碎
        let shredAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in    
            self.taskController.confirmDeletion(for: task)
            completion(true)
        }
        
        shredAction.image = resGetImage("todo_task_action_shred_24")?.withTintColor(.white)
        return UISwipeActionsConfiguration(actions: [shredAction])
    }
    
}
