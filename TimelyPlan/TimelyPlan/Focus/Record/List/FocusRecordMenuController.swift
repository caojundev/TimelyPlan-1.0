//
//  FocusRecordMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/9.
//

import Foundation

enum FocusRecordMenuType: String, TPMenuRepresentable {
    case edit
    case delete

    var title: String {
        switch self {
        case .edit:
            return resGetString("Edit")
        case .delete:
            return resGetString("Delete")
        }
    }
    
    var iconName: String? {
        switch self {
        case .edit:
            return "edit_24"
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

class FocusRecordMenuController: TPBaseMenuController<FocusRecordMenuType> {
    
    override func orderedMenuActionTypeLists() -> [Array<FocusRecordMenuType>] {
        var lists: [Array<FocusRecordMenuType>]
        lists = [[.edit, .delete]]
        return lists
    }
}


