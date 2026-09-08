//
//  GoalTaskMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/5.
//

import Foundation

enum GoalTaskMenuType: String, TPMenuRepresentable {
    case completeAll
    case addRecord
    case resetToday
    
    case addToMyDay /// 添加到我的一天
    case removeFromMyDay /// 从我的一天移除
    case startFocus
    case edit       /// 编辑
    case delete     /// 删除
    
    var title: String {
        switch self {
        case .completeAll:
            return resGetString("Complete All")
        case .addRecord:
            return resGetString("Add Record")
        case .resetToday:
            return resGetString("Reset Today")
        case .addToMyDay:
            return resGetString("Add to My Day")
        case .removeFromMyDay:
            return resGetString("Remove from My Day")
        case .startFocus:
            return resGetString("Start Focus")
        default:
            return resGetString(rawValue.capitalized)
        }
    }

    var iconName: String? {
        switch self {
        case .completeAll:
            return "habit_menu_completeAll_24"
        case .resetToday:
            return "habit_menu_reset_24"
        case .addRecord:
            return "plus_24"
        case .addToMyDay:
            return "myDay_add_24"
        case .removeFromMyDay:
            return "myDay_remove_24"
        case .startFocus:
            return "focus_24"
        case .delete:
            return "shred_24"
        default:
            return rawValue + "_24"
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        if self == .delete {
            return .destructive
        }
        
        return .normal
    }
}

class GoalTaskMenuController: TPBaseMenuController<GoalTaskMenuType> {
    
    let task: GoalTask

    init(task: GoalTask) {
        self.task = task
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<GoalTaskMenuType>] {
        var lists: [Array<GoalTaskMenuType>]
        lists = [[.completeAll, .addRecord, .resetToday],
                 [.addToMyDay, .removeFromMyDay],
                 [.startFocus],
                 [.edit],
                 [.delete]]
        return lists
    }
    
    override func menuActionTypes() -> [GoalTaskMenuType] {
        var types: [GoalTaskMenuType] = [.completeAll,
                                         .addRecord,
                                         .resetToday,
                                         .startFocus,
                                         .edit,
                                         .delete]
        if task.isAddedToMyDay {
            types.append(.removeFromMyDay)
        } else {
            types.append(.addToMyDay)
        }
        
        return types
    }

}

