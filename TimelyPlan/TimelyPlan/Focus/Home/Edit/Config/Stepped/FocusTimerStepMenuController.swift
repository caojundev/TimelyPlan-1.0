//
//  FocusTimerStepMenuActionController.swift
//  TimelyPlan
//  
//  Created by caojun on 2023/11/24.
//

import Foundation

enum FocusTimerStepMenuType: String, TPMenuRepresentable {
    case addPreviousStep
    case addNextStep
    case edit
    case delete

    var title: String {
        switch self {
        case .addPreviousStep:
            return resGetString("Add Previous Step")
        case .addNextStep:
            return resGetString("Add Next Step")
        case .edit:
            return resGetString("Edit")
        case .delete:
            return resGetString("Delete")
        }
    }
    
    /// 图标名称
    var iconName: String? {
        switch self {
        case .addPreviousStep:
            return "focus_timer_step_addPrevious_24"
        case .addNextStep:
            return "focus_timer_step_addNext_24"
        case .edit:
            return "edit_24"
        case .delete:
            return "shred_24"
        }
    }
    
    /// 动作样式
    var actionStyle: TPMenuActionStyle {
        if self == .delete {
            return .destructive
        }
        
        return .normal
    }
}

class FocusTimerStepMenuController: TPBaseMenuController<FocusTimerStepMenuType> {
    
    override func orderedMenuActionTypeLists() -> [Array<FocusTimerStepMenuType>] {
        var lists: [Array<FocusTimerStepMenuType>]
        lists = [[.addPreviousStep,
                  .addNextStep],
                 [.edit],
                 [.delete]]
        return lists
    }
}


