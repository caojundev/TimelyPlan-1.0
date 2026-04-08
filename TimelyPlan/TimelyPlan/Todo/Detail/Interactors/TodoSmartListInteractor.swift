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
    
    /// 获取任务方法
    override func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        if listConfiguration.list.listType == .trash {
            /// 废纸篓任务
            todo.fetchTrashTasks { results in
                completion(results)
            }
        } else {
            super.fetchTasks(completion: completion)
        }
    }
    
    override func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        guard listConfiguration.list.listType == .trash else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    override func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        guard listConfiguration.list.listType == .trash else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    override func didEmptyTrash() {
        guard listConfiguration.list.listType == .trash else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
}
