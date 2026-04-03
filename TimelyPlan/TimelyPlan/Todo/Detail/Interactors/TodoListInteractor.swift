//
//  TodoListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoListInteractor {
    
    static func interactor(for configuration: TodoListConfiguration) -> TodoListInteractor {
        switch configuration {
        case let userListConfig as TodoUserListConfiguration:
            return TodoUserListInteractor(configuration: userListConfig)
        case let smartListConfig as TodoSmartListConfiguration:
            return TodoSmartListInteractor(configuration: smartListConfig)
        case let tagListConfig as TodoTagListConfiguration:
            return TodoTagListInteractor(configuration: tagListConfig)
        default:
            return TodoListInteractor()
        }
    }
    
    func title() -> TextRepresentable? {
        return nil
    }
}
