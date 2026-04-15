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
                                showCompleted: self.state.showCompleted,
                                completion: completion)
    }

    // MARK: - TodoListProcessorDelegate
    func didUpdateTodoList(_ list: TodoList) {
        let oldList = self.list
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
