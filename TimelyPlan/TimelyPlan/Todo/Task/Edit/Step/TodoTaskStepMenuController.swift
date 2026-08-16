//
//  TodoTaskStepMenuActionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/1.
//

import Foundation

/// 待办列表操作菜单
enum TodoTaskStepMenuActionType: String, TPMenuRepresentable {
    case convertToTask   /// 转为任务
    case addSubStep
    case addPreviousStep /// 添加上一步
    case addNextStep     /// 添加下一步
    case copyStep        /// 拷贝步骤文本
    case delete          /// 删除
    
    var title: String {
        switch self {
        case .convertToTask:
            return resGetString("Convert to Task")
        case .addSubStep:
            return resGetString("Add Substep")
        case .addPreviousStep:
            return resGetString("Add Previous Step")
        case .addNextStep:
            return resGetString("Add Next Step")
        case .copyStep:
            return resGetString("Copy Step")
        default:
            return resGetString(rawValue.capitalized)
        }
    }
    
    var iconName: String? {
        switch self {
        case .convertToTask:
            return "todo_task_step_convertToTask_24"
        case .addSubStep:
            return "todo_task_step_addSubstep_24"
        case .addPreviousStep:
            return "todo_task_step_addPrevious_24"
        case .addNextStep:
            return "todo_task_step_addNext_24"
        case .copyStep:
            return "copy_24"
        case .delete:
            return "trash_24"
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        if self == .delete {
            return .destructive
        }
        
        return .normal
    }
}


class TodoTaskStepMenuController: TPBaseMenuController<TodoTaskStepMenuActionType> {
    
    /// 是否显示移动到顶部
    var showMoveToTop = false
    
    /// 菜单作用的列表
    let step: TodoStep

    init(step: TodoStep) {
        self.step = step
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<TodoTaskStepMenuActionType>] {
        var types: [Array<TodoTaskStepMenuActionType>]
        types = [[.convertToTask],
                 [.addSubStep],
                 [.addPreviousStep,
                    .addNextStep],
                 [.copyStep],
                 [.delete]]
        return types
    }
    
    override func menuActionTypes() -> [TodoTaskStepMenuActionType] {
        var types: [TodoTaskStepMenuActionType] = [.convertToTask,
                                                   .addPreviousStep,
                                                   .addNextStep,
                                                   .copyStep,
                                                   .delete]
        if step.depth < TodoConstant.stepMaxDepth {
            types.append(.addSubStep)
        }
        
        return types
    }
}

