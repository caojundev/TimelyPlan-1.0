//
//  TodoUserListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoUserListInteractor: TodoListInteractor {
    
    var listConfiguration: TodoUserListConfiguration {
       return configuration as! TodoUserListConfiguration
    }

    var list: TodoList {
        return listConfiguration.list
    }
    
    override func layoutType() -> TodoListLayoutType {
        return self.list.layoutType
    }
    
    override func setLayoutType(_ layoutType: TodoListLayoutType) {
        todo.updateList(list, layoutType: layoutType)
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        self.placeholderProvider.emptyImage = resGetImage("todo_list_80")
        self.placeholderProvider.emptyTitle = resGetString("The current list has no tasks")
        todo.addUpdater(self, for: [.list])
    }
    
    override func title() -> TextRepresentable? {
        let list = self.list
        let listName = list.name ?? resGetString("Untitled")
        if let emoji = list.emoji {
            return emoji + " " + listName
        }
        
        if let image = resGetImage(list.layoutType.miniIconName) {
            let color = list.color ?? resGetColor(.title)
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: color,
                            trailingText: listName,
                            separator: " ")
            return title
        }
        
        return listName
    }
    
    override func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        
        todo.fetchUserListTasks(in: self.list,
                                showCompleted: self.listOptionState.showCompleted,
                                completion: completion)
    }

    // MARK: - TodoListProcessorDelegate
    override func didUpdateTodoList(_ list: TodoList, with editingList: TodoEditingList) {
        let oldList = self.list
        guard list.identifier == oldList.identifier else {
            return
        }
        
        let bLayoutTypeChanged = editingList.layoutType != oldList.layoutType
        list.update(with: editingList)
        self.listConfiguration.updateList(list)
        if bLayoutTypeChanged {
            self.didChangeLayoutType?()
        } else {
            self.didChangeListInfo?()
        }
    }
}
