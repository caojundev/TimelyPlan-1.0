//
//  TodoTagListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoTagListInteractor: TodoListInteractor {
    
    let configuration: TodoTagListConfiguration
    
    init(configuration: TodoTagListConfiguration) {
        self.configuration = configuration
    }
    
    override func title() -> TextRepresentable? {
        let tagName = configuration.tag.name ?? resGetString("Untitled")
        if let image = resGetImage("todo_home_tag_24") {
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: configuration.tag.color,
                            trailingText: tagName,
                            separator: " ")
            return title
        }
        
        return tagName
    }
}
