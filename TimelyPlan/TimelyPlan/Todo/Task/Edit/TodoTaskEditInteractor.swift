//
//  TodoTaskEditInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/10.
//

import Foundation

class TodoTaskEditInteractor: TodoTaskProcessorDelegate {
    
    var onTaskChange: ((TodoTaskChange) -> Void)?
    
    private(set) var task: TodoTask
    
    init(task: TodoTask) {
        self.task = task
        todo.addUpdater(self, for: [.task])
    }
    
    func setName(_ name: String?) {
        todo.updateTask(task, name: name)
    }
    
    func setCompleted(_ isCompleted: Bool) {
        todo.updateTasks([task], isCompleted: isCompleted)
    }
    
    func setPriority(_ priority: TodoTaskPriority) {
        todo.updateTasks([task], priority: priority)
    }
    
    func setAddedToMyDay(_ isAddedToMyDay: Bool) {
        todo.updateTask(task, isAddedToMyDay: isAddedToMyDay)
    }
    
    func setSchedule(_ schedule: TaskSchedule?) {
        todo.updateTask(task, schedule: schedule)
    }
    
    func setProgress(_ progress: TodoEditProgress?) {
        todo.updateTask(task, progress: progress)
    }
    
    func setTags(_ tags: Set<TodoTag>?) {
        todo.updateTask(task, tags: tags)
    }
    
    func setNote(_ note: String?) {
        todo.updateTask(task, note: note)
    }
    
    func setSteps(_ steps: [TodoStep]?) {
        todo.updateTask(task, steps: steps)
    }
    
    // MARK: - TodoTaskProcessorDelegate
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        guard task.identifier == self.task.identifier else {
            return
        }
        
        /// 更新任务
        if let task = todo.getTask(with: task.identifier) {
            self.task = task
        }
        
        onTaskChange?(change)
    }
}
