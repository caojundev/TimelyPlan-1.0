//
//  TodoTaskStepMenuActionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/1.
//

import Foundation

/// 待办列表操作菜单
enum TodoTaskStepMenuActionType: String, TPMenuRepresentable {
    
    case addPreviousStep /// 添加上一步
    case addNextStep     /// 添加下一步
    case moveToTop       /// 移动到顶部
    case copyStep        /// 拷贝步骤文本
    case delete          /// 删除
    
    var title: String {
        switch self {
        case .addPreviousStep:
            return resGetString("Add Previous Step")
        case .addNextStep:
            return resGetString("Add Next Step")
        case .moveToTop:
            return resGetString("Move To Top")
        case .copyStep:
            return resGetString("Copy Step")
        default:
            return resGetString(rawValue.capitalized)
        }
    }
    
    var iconName: String? {
        switch self {
        case .addPreviousStep:
            return "todo_task_step_addPrevious_24"
        case .addNextStep:
            return "todo_task_step_addNext_24"
        case .moveToTop:
            return "moveToTop_24"
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
        types = [[.addPreviousStep,
                    .addNextStep],
                 [.moveToTop],
                 [.copyStep],
                 [.delete]]
        return types
    }
    
    override func menuActionTypes() -> [TodoTaskStepMenuActionType] {
        var types: [TodoTaskStepMenuActionType] = [.addPreviousStep,
                                                   .addNextStep,
                                                   .copyStep,
                                                   .delete]
        if showMoveToTop {
            types.append(.moveToTop)
        }
        
        return types
    }
}
