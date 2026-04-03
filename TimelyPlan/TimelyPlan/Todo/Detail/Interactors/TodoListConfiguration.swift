//
//  TodoListConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/20.
//

import Foundation
import UIKit

class TodoListConfiguration {
    
    static func configuration(for object: Any) -> TodoListConfiguration! {
        switch object {
        case let list as TodoList:
            return TodoUserListConfiguration(list: list)
        case let smartList as TodoSmartList:
            return TodoSmartListConfiguration(list: smartList)
        case let tag as TodoTag:
            return TodoTagListConfiguration(tag: tag)
        default:
            return nil
        }
    }
    
    func makeContent() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .random
        return vc
    }
}

class TodoUserListConfiguration: TodoListConfiguration {
    
    let list: TodoList
    
    init(list: TodoList) {
        self.list = list
    }
    
    override func makeContent() -> UIViewController {
        let interactor = TodoListInteractor.interactor(for: self)
        return TodoTaskListViewController(interactor: interactor)
    }
}

class TodoSmartListConfiguration: TodoListConfiguration {
    
    let list: TodoSmartList
    
    init(list: TodoSmartList) {
        self.list = list
    }
    
    override func makeContent() -> UIViewController {
        let interactor = TodoListInteractor.interactor(for: self)
        return TodoTaskListViewController(interactor: interactor)
    }
}

class TodoTagListConfiguration: TodoListConfiguration {
    
    let tag: TodoTag
    
    init(tag: TodoTag) {
        self.tag = tag
    }
    
    override func makeContent() -> UIViewController {
        let interactor = TodoListInteractor.interactor(for: self)
        return TodoTaskListViewController(interactor: interactor)
    }
}
