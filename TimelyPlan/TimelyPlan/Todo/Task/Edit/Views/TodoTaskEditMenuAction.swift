//
//  TodoTaskEditMenuAction.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/27.
//

import Foundation

enum TodoTaskEditType: String, TPMenuRepresentable {
    case myDay
    case date
    case reminder
    case repeatRule
    case tag
    case progress
    
    var title: String {
        switch self {
        case .myDay:
            return resGetString("My Day")
        case .repeatRule:
            return resGetString("Repeat")
        default:
            return defaultTitle
        }
    }
    
    var iconName: String? {
        switch self {
        case .myDay:
            return "todo_task_addToMyDay_24"
        case .date:
            return "todo_task_date_24"
        case .reminder:
            return "schedule_alarm_24"
        case .repeatRule:
            return "schedule_repeat_24"
        case .progress:
            return "todo_task_progress_24"
        case .tag:
            return "todo_task_tag_24"
        }
    }
}

class TodoTaskEditMenuAction: NSObject {

    var image: UIImage? {
        return editType.iconImage
    }
    
    var title: String {
        return editType.title
    }
    
    let editType: TodoTaskEditType
    
    init(editType: TodoTaskEditType) {
        self.editType = editType
        super.init()
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        return editType.identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? TodoTaskEditMenuAction else { return false }
        return other.editType == editType
    }
}
