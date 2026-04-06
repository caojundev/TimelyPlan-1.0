//
//  TodoTagListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoTagListInteractor: TodoListInteractor {
    
    var listConfiguration: TodoTagListConfiguration {
       return configuration as! TodoTagListConfiguration
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
}
