//
//  TodoUserListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation
import CoreGraphics

class TodoUserListInteractor: TodoListInteractor,
                                TodoListProcessorDelegate {
    
    override var layoutType: TodoListLayoutType {
        return listConfiguration.list.layoutType
    }
    
    var listConfiguration: TodoUserListConfiguration {
       return configuration as! TodoUserListConfiguration
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
