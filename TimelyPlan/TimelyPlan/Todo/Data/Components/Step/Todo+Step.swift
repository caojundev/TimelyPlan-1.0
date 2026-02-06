//
//  Todo+Step.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/31.
//

import Foundation

extension Todo {
    
    /// 创建步骤
    func addStep(named name: String?,
                 onTop: Bool = false,
                 for task: TodoTask,
                 completion:((TodoStep) -> Void)? = nil){
        stepManager.addStep(named: name, onTop: onTop, for: task, completion: completion)
    }
    
    /// 创建特定步骤的上一步
    func addPreviousStep(of step: TodoStep, completion:((TodoStep?) -> Void)? = nil) {
        stepManager.addPreviousStep(of: step, completion: completion)
    }
    
    /// 创建特定步骤的下一步
    func addNextStep(of step: TodoStep, completion:((TodoStep?) -> Void)? = nil) {
        stepManager.addNextStep(of: step, completion: completion)
    }
    
    /// 更新名称
    func updateStep(_ step: TodoStep, name: String?) {
        stepManager.updateStep(step, name: name)
    }
    
    /// 更新完成状态
    func updateStep(_ step: TodoStep, isCompleted: Bool) {
        stepManager.updateStep(step, isCompleted: isCompleted)
    }
    
    /// 删除步骤
    func deleteStep(_ step: TodoStep) {
        stepManager.deleteStep(step)
    }
    
    /// 将步骤移动到顶部
    func moveStepToTop(_ step: TodoStep, in steps: [TodoStep]) {
        stepManager.moveStepToTop(step, in: steps)
    }
    
    /// 任务排序
    func reorderStep(in steps: [TodoStep], fromIndex: Int, toIndex: Int) {
        stepManager.reorderStep(in: steps, fromIndex: fromIndex, toIndex: toIndex)
    }
}
