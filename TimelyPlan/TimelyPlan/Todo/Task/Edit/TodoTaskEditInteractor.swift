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
        guard self.task.identifier == task.identifier else {
            return
        }
        
        switch change {
        case .name(_, let name):
            self.task.name = name
        case .priority(_, let priority):
            self.task.priority = priority
        case .completed(_, let isCompleted):
            self.task.isCompleted = isCompleted
        case .progress(_, let progress):
            self.task.progress = progress
        case .tag(_, let tags):
            if let tags = tags {
                self.task.tags = Array(tags)
            } else {
                self.task.tags = nil
            }
        case .schedule(_, let schedule):
            self.task.schedule = schedule
        case .note(_, let note):
            self.task.note = note
        case .myDay(_, let isAddedToMyDay):
            self.task.isAddedToMyDay = isAddedToMyDay
        case .list(_, let list):
            self.task.list = list?.feature
        case .step(_, let steps):
            self.task.updateSteps(steps)
        }
        
        #warning("重新获取任务，可能更新了多个属性了，修改日期等属性可能也改变了")
        onTaskChange?(change)
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        for changeInfo in changeInfos {
            didUpdateTodoTask(changeInfo.task, with: changeInfo.change)
        }
    }
}
