//
//  TodoTagListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoTagListInteractor: TodoListInteractor {
    
    var tag: TodoTag {
        return listConfiguration.tag
    }
    
    var listConfiguration: TodoTagListConfiguration {
       return configuration as! TodoTagListConfiguration
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        self.placeholderProvider.emptyImage = resGetImage("todo_tag_80")
        self.placeholderProvider.emptyTitle = resGetString("The current tag has no tasks")
        todo.addUpdater(self, for: [.tag])
    }
    
    override func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        todo.fetchTasks(tag: self.tag,
                        showCompleted: self.listOptionState.showCompleted,
                        completion: completion)
    }

    override func title() -> TextRepresentable? {
        let tagName = self.tag.name ?? resGetString("Untitled")
        if let image = resGetImage("todo_home_tag_24") {
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: self.tag.color,
                            trailingText: tagName,
                            separator: " ")
            return title
        }
        
        return tagName
    }
    
    // MARK: - TodoTagProcessorDelegate
    override func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        let oldTag = listConfiguration.tag
        guard tag.identifier == oldTag.identifier else {
            return
        }
        
        /// 更新列表
        tag.update(with: editingTag)
        self.listConfiguration.updateTag(tag)
        self.didChangeListInfo?()
    }
    
}
