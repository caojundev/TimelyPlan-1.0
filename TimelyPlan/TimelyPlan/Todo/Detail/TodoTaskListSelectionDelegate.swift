//
//  TodoTaskListSelectionDelegate.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/13.
//

import Foundation

protocol TodoTaskListSelectionDelegate: AnyObject {
    /// 选择模式状态发生变化时调用
    func todoTaskListDidUpdateSelectionMode(to isSelecting: Bool)
    
    /// 选中的任务集合发生变化时调用
    func todoTaskListDidUpdateSelectedTasks(to selectedTasks: Set<TodoTask>)
}
