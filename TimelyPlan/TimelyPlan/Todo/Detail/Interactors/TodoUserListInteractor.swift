//
//  TodoUserListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation
import CoreGraphics

class TodoUserListInteractor: TodoListInteractor {
    
    var listConfiguration: TodoUserListConfiguration {
       return configuration as! TodoUserListConfiguration
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
    
}
