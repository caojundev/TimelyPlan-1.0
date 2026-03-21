//
//  HabitRecordMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/21.
//

import Foundation

enum HabitRecordMenuType: String, TPMenuRepresentable {
    case editLog
    case delete

    var title: String {
        switch self {
        case .editLog:
            return resGetString("Edit Log")
        case .delete:
            return resGetString("Delete")
        }
    }
    
    var iconName: String? {
        switch self {
        case .editLog:
            return "habit_menu_editLog_24"
        case .delete:
            return "shred_24"
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        if self == .delete {
            return .destructive
        }
        
        return .normal
    }
}

class HabitRecordMenuController: TPBaseMenuController<HabitRecordMenuType> {
    
    override func orderedMenuActionTypeLists() -> [Array<HabitRecordMenuType>] {
        var lists: [Array<HabitRecordMenuType>]
        lists = [[.editLog], [.delete]]
        return lists
    }
}


