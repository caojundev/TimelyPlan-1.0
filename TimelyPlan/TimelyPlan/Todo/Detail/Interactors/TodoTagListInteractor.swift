//
//  TodoTagListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoTagListInteractor: TodoListInteractor,
                                TodoTagProcessorDelegate {
    
    var listConfiguration: TodoTagListConfiguration {
       return configuration as! TodoTagListConfiguration
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        todo.addUpdater(self, for: [.tag])
    }

    override func title() -> TextRepresentable? {
        let tagName = listConfiguration.tag.name ?? resGetString("Untitled")
        if let image = resGetImage("todo_home_tag_24") {
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: listConfiguration.tag.color,
                            trailingText: tagName,
                            separator: " ")
            return title
        }
        
        return tagName
    }
    
    // MARK: - TodoTagProcessorDelegate
    func didUpdateTodoTag(_ tag: TodoTag) {
        let oldTag = listConfiguration.tag
        guard tag.identifier == oldTag.identifier else {
            return
        }
        
        /// 获取更新后的标签
        guard let newTag = todo.getTag(of: tag.identifier), !newTag.isEqual(oldTag) else {
            return
        }
        
        /// 更新列表
        self.listConfiguration.updateTag(newTag)
        self.didChangeListInfo?()
    }
    
}
