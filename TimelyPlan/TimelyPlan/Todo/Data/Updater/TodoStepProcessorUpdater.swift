//
//  TodoStepProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/26.
//

import Foundation

/// 待办步骤处理通知协议
protocol TodoStepProcessorDelegate: AnyObject{
    
    /// 添加新待办步骤
    func didAddTodoStep(_ step: TodoStep)

    /// 更新步骤
    func didUpdateTodoStep(_ step: TodoStep, with change: TodoStepChange)

    /// 删除步骤
    func didDeleteTodoStep(_ step: TodoStep, of task: TodoTask)
    
    /// 重新排序步骤
    func didReorderTodoStep(in steps: [TodoStep], fromIndex: Int, toIndex: Int)
}

extension TodoStepProcessorDelegate {
    
    func didAddTodoStep(_ step: TodoStep){}

    func didUpdateTodoStep(_ step: TodoStep, with change: TodoStepChange){}

    func didDeleteTodoStep(_ step: TodoStep, of task: TodoTask){}
    
    func didReorderTodoStep(in steps: [TodoStep], fromIndex: Int, toIndex: Int) {}
}

class TodoStepProcessorUpdater: NSObject, TodoStepProcessorDelegate {
    
    func didAddTodoStep(_ step: TodoStep) {
        notifyDelegates { (delegate: TodoStepProcessorDelegate) in
            delegate.didAddTodoStep(step)
        }
    }

    func didUpdateTodoStep(_ step: TodoStep, with change: TodoStepChange) {
        notifyDelegates { (delegate: TodoStepProcessorDelegate) in
            delegate.didUpdateTodoStep(step, with: change)
        }
    }

    func didDeleteTodoStep(_ step: TodoStep, of task: TodoTask)  {
        notifyDelegates { (delegate: TodoStepProcessorDelegate) in
            delegate.didDeleteTodoStep(step, of: task)
        }
    }
    
    /// 重新排序步骤
    func didReorderTodoStep(in steps: [TodoStep], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: TodoStepProcessorDelegate) in
            delegate.didReorderTodoStep(in: steps, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
}
