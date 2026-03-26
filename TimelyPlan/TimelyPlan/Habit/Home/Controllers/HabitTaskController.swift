//
//  HabitTaskController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/5.
//

import Foundation

class HabitTaskController {
    
    func createNewTask(){
        HabitPresenter.createNewHabitTask()
    }
    
    /// 编辑任务
    func editTask(_ task: HabitTask){
        HabitPresenter.editHabitTask(task)
    }
    
    func archiveTask(_ task: HabitTask){
        habit.setArchived(true, for: task)
    }
    
    func unarchiveTask(_ task: HabitTask){
        habit.setArchived(false, for: task)
    }
    
    /// 删除任务
    func deleteTask(_ task: HabitTask){
        confirmTaskDeletion(for: task) { confirmed in
            if confirmed {
                habit.deleteTask(task)
            }
        }
    }
    
    /// 弹窗确认删除任务
    func confirmTaskDeletion(for task: HabitTask, completion: @escaping(Bool) -> Void) {
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            completion(true)
        }
        
        /// 在 dismiss 后处理回调
        deleteAction.handleBeforeDismiss = false
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel")) { action in
            completion(false)
        }
        
        let format: String = resGetString("\"%@\" will be permanently deleted.")
        let message = String(format: format, task.name ?? "Untitled")
        let alertController = TPAlertController(title: resGetString("Delete Habit"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    func reorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        habit.reorderTask(in: tasks, fromIndex: fromIndex, toIndex: toIndex)
    }
}
