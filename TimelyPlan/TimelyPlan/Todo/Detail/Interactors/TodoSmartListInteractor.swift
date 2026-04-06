//
//  TodoSmartListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoSmartListInteractor: TodoListInteractor {
    
    var listConfiguration: TodoSmartListConfiguration {
       return configuration as! TodoSmartListConfiguration
    }
    
    override func title() -> TextRepresentable? {
        let listName = listConfiguration.list.title
        if let image = listConfiguration.list.icon {
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: nil,
                            trailingText: listName,
                            separator: " ")
            return title
        }
        
        return listName
    }
    
    override func taskActionTypes(for selectedTasks: Set<TodoTask>) -> [TodoTaskActionType] {
        let listType = listConfiguration.list.listType
        if listType == .trash {
            return [.restore, .shred]
        }
        
        return super.taskActionTypes(for: selectedTasks)
    }
}
