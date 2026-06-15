//
//  TodoTaskEditInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/10.
//

import Foundation

class TodoTaskEditInteractor: TodoTaskProcessorDelegate {
    
    var onTaskChange: ((TodoTaskChange?) -> Void)?
    
    private(set) var task: TodoTask
    
    init(task: TodoTask) {
        self.task = task
        TodoRepository.addUpdater(self, for: [.task])
    }
    
    func setName(_ name: String?) {
        TodoRepository.updateTask(task, name: name)
    }
    
    func setCompleted(_ isCompleted: Bool) {
        TodoRepository.updateTasks([task], isCompleted: isCompleted)
    }
    
    func setPriority(_ priority: TodoTaskPriority) {
        TodoRepository.updateTasks([task], priority: priority)
    }
    
    func setAddedToMyDay(_ isAddedToMyDay: Bool) {
        TodoRepository.updateTask(task, isAddedToMyDay: isAddedToMyDay)
    }
    
    func setSchedule(_ schedule: TaskSchedule?) {
        TodoRepository.updateTask(task, schedule: schedule)
    }
    
    func setProgress(_ progress: TodoEditProgress?) {
        TodoRepository.updateTask(task, progress: progress)
    }
    
    func setTags(_ tags: Set<TodoTag>?) {
        TodoRepository.updateTask(task, tags: tags)
    }
    
    func setNote(_ note: String?) {
        TodoRepository.updateTask(task, note: note)
    }
    
    func setSteps(_ steps: [TodoStep]?) {
        TodoRepository.updateTask(task, steps: steps)
    }
    
    func moveToTrash() {
        TodoRepository.moveTasksToTrash([task])
    }
    
    // MARK: - TodoTaskProcessorDelegate
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        guard task.identifier == self.task.identifier else {
            return
        }
        
        /// 更新任务
        if let task = TodoRepository.getTask(with: task.identifier) {
            self.task = task
        }
        
        onTaskChange?(change)
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        let updatedTask = updatedTasks.first(where: { task in
            return task.identifier == self.task.identifier
        })
        
        if let updatedTask = updatedTask {
            self.task = updatedTask
            onTaskChange?(nil)
        }
    }
}
