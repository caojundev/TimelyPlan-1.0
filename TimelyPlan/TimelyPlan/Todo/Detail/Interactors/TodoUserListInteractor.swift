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
        return configuration.list.name ?? resGetString("Untitled")
    }
}
