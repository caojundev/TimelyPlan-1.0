//
//  TodoStepManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/27.
//

import Foundation
import CoreData

class TodoStepManager {
    
    /// 步骤处理更新器
    let updater = TodoStepProcessorUpdater()

    /// 创建步骤
    func addStep(named name: String?,
                 onTop: Bool = false,
                 for task: TodoTask,
                 completion:((TodoStep) -> Void)? = nil){
        let step = TodoStep.newStep(name: name)
        task.addStep(step, onTop: onTop)
        task.modificationDate = .now
        
        completion?(step)
        updater.didAddTodoStep(step)
        todo.save()
    }
    
    /// 创建特定步骤的上一步
    func addPreviousStep(of step: TodoStep, completion:((TodoStep?) -> Void)? = nil) {
        guard let task = step.task, var steps = task.orderedSteps(), let index = steps.indexOf(step) else {
            completion?(nil)
            return
        }
        
        let previousStep = TodoStep.newStep()
        task.addToSteps(previousStep)
        task.modificationDate = .now
        
        steps.insert(previousStep, at: index)
        steps.updateOrders()
        completion?(previousStep)
        updater.didAddTodoStep(previousStep)
        todo.save()
    }
    
    /// 创建特定步骤的下一步
    func addNextStep(of step: TodoStep, completion:((TodoStep?) -> Void)? = nil) {
        guard let task = step.task, var steps = task.orderedSteps(), let index = steps.indexOf(step) else {
            completion?(nil)
            return
        }
    
        let nextStep = TodoStep.newStep()
        task.addToSteps(nextStep)
        task.modificationDate = .now
        
        steps.insert(nextStep, at: index + 1)
        steps.updateOrders()
        completion?(nextStep)
        updater.didAddTodoStep(nextStep)
        todo.save()
    }
    
    /// 更新名称
    func updateStep(_ step: TodoStep, name: String?) {
        guard step.name != name else {
            return
        }
        
        let change: TodoStepChange = .name(oldValue: step.name, newValue: name)
        step.name = name
        step.task?.modificationDate = .now
        updater.didUpdateTodoStep(step, with: change)
        todo.save()
    }
    
    /// 更新完成状态
    func updateStep(_ step: TodoStep, isCompleted: Bool) {
        guard step.isCompleted != isCompleted else {
            return
        }
        
        if isCompleted {
            step.completionDate = .now
        } else {
            step.completionDate = nil
        }
        
        step.isCompleted = isCompleted
        step.task?.modificationDate = .now
        
        updater.didUpdateTodoStep(step, with: .completed(newValue: isCompleted))
        if isCompleted {
            /// 将完成步骤移动到底部
            moveStepToBottom(step)
        }
        
        todo.save()
    }
    
    /// 删除步骤
    func deleteStep(_ step: TodoStep) {
        guard let task = step.task else {
            return
        }
        
        task.removeFromSteps(step)
        task.modificationDate = .now
        
        NSManagedObjectContext.defaultContext.delete(step)
        updater.didDeleteTodoStep(step, of: task)
        todo.save()
    }
    
    /// 将步骤移动到顶部
    func moveStepToTop(_ step: TodoStep, in steps: [TodoStep]) {
        guard let fromIndex = steps.indexOf(step), fromIndex > 0 else {
            return
        }
        
        reorderStep(in: steps, fromIndex: fromIndex, toIndex: 0)
    }
    
    /// 将步骤移动到底部
    private func moveStepToBottom(_ step: TodoStep){
        guard let task = step.task,
              let steps = task.steps as? Set<TodoStep>,
              steps.count > 1 else {
            return
        }
        
        let orderedSteps = steps.orderedElements()
        guard let fromIndex = orderedSteps.indexOf(step) else {
            return
        }
        
        let toIndex = steps.count - 1
        reorderStep(in: orderedSteps, fromIndex: fromIndex, toIndex: toIndex)
    }
    
    /// 任务排序
    func reorderStep(in steps: [TodoStep], fromIndex: Int, toIndex: Int) {
        if fromIndex == toIndex || fromIndex >= steps.count || toIndex >= steps.count {
            return
        }
        
        var steps = steps
        steps.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        steps.updateOrders()
        updater.didReorderTodoStep(in: steps, fromIndex: fromIndex, toIndex: toIndex)
        todo.save()
    }
}
