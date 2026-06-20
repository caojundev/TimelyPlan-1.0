//
//  TodoUserListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation
import UIKit

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
        TodoRepository.updateList(list, layoutType: layoutType)
        updatePlaceholder()
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        self.updatePlaceholder()
        TodoRepository.addUpdater(self, for: [.list])
    }
    
    private func updatePlaceholder() {
        var image: UIImage?
        var title: String?
        if list.layoutType == .board {
            image = resGetImage("todo_board_80")
            title = resGetString("The current board has no tasks")
        } else {
            image = resGetImage("todo_list_80")
            title = resGetString("The current list has no tasks")
        }
        
        self.placeholderProvider.emptyImage = image
        self.placeholderProvider.emptyTitle = title
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
        TodoRepository.fetchUserListTasks(in: list,
                                showCompleted: listOptionState.showCompleted,
                                completion: completion)
    }

    override func importTasks(_ tasks: [TodoImportTask]) {
        TodoRepository.importTasks(tasks, to: list)
    }
    
    // MARK: - TodoListProcessorDelegate
    override func didChangeRemoteTodoList(with results: EntityChangeResults<TodoList>?) {
        /// 更新列表信息以及布局
        guard let newList = TodoRepository.getUserList(of: list.identifier) else {
            return
        }
    
        let oldList = list
        listConfiguration.updateList(list)
        /// 更新列表信息
        didChangeListInfo?()
        
        if oldList.layoutType != newList.layoutType {
            /// 布局改变
            updatePlaceholder()
            didChangeLayoutType?()
        }
    }
    
    override func didUpdateTodoList(_ list: TodoList, with editingList: TodoEditingList) {
        let oldList = self.list
        guard list.identifier == oldList.identifier else {
            return
        }
        
        let bLayoutTypeChanged = editingList.layoutType != oldList.layoutType
        list.update(with: editingList)
        listConfiguration.updateList(list)
        
        if bLayoutTypeChanged {
            updatePlaceholder() /// 更新占位信息
            didChangeLayoutType?()
        } else {
            didChangeListInfo?()
        }
    }
}
