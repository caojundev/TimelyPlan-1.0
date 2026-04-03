//
//  TodoSmartListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoSmartListInteractor: TodoListInteractor {
    
    let configuration: TodoSmartListConfiguration
    
    init(configuration: TodoSmartListConfiguration) {
        self.configuration = configuration
    }
    
    override func title() -> TextRepresentable? {
        let listName = configuration.list.title
        if let image = configuration.list.icon {
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: nil,
                            trailingText: listName,
                            separator: " ")
            return title
        }
        
        return listName
    }
}
