//
//  TodoUserListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoUserListInteractor: TodoListInteractor,
                                TodoListProcessorDelegate {
    
    var listConfiguration: TodoUserListConfiguration {
       return configuration as! TodoUserListConfiguration
    }
    
    override var layoutType: TodoListLayoutType {
        get {
            return listConfiguration.list.layoutType
        }
        
        set {
            todo.updateList(listConfiguration.list, layoutType: newValue)
        }
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        todo.addUpdater(self, for: [.list])
    }
    
    override func title() -> TextRepresentable? {
        let list = listConfiguration.list
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
        let list = self.listConfiguration.list
        todo.fetchUserListTasks(in: list,
                                showCompleted: self.showCompleted,
                                completion: completion)
    }

    // MARK: - TodoListProcessorDelegate
    func didUpdateTodoList(_ list: TodoList) {
        let oldList = listConfiguration.list
        guard list.identifier == oldList.identifier else {
            return
        }
        
        /// 获取更新后的列表
        guard let newList = todo.getUserList(of: list.identifier) else {
            return
        }

        /// 更新列表
        self.listConfiguration.updateList(newList)
        if newList.layoutType != oldList.layoutType {
            self.didChangeLayoutType?()
        } else {
            self.didChangeListInfo?()
        }
    }
}
