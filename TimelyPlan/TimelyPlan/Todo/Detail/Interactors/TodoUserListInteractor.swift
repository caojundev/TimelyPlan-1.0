//
//  TodoUserListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoUserListInteractor: TodoListInteractor {
    
    let configuration: TodoUserListConfiguration
    
    init(configuration: TodoUserListConfiguration) {
        self.configuration = configuration
    }
    
    override func title() -> TextRepresentable? {
        let list = configuration.list
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
}
