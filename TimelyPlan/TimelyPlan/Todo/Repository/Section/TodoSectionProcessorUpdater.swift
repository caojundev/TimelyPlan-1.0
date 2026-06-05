//
//  TodoSectionProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/3.
//

import Foundation

protocol TodoSectionProcessorDelegate: AnyObject{
    
    func didCreateTodoSection(_ section: TodoSection, in list: TodoList?)

    func didDeleteTodoSection(_ section: TodoSection)
    
    func didUpdateTodoSection(_ section: TodoSection, with name: String)

    func didRecorderTodoSection(in sections: [TodoSection], fromIndex: Int, toIndex: Int)
}

extension TodoSectionProcessorDelegate {

    func didCreateTodoSection(_ section: TodoSection, in list: TodoList?) {}

    func didDeleteTodoSection(_ section: TodoSection) {}

    func didUpdateTodoSection(_ section: TodoSection, with name: String) {}

    func didRecorderTodoSection(in sections: [TodoSection], fromIndex: Int, toIndex: Int) {}
}

class TodoSectionProcessorUpdater: NSObject, TodoSectionProcessorDelegate {
    
    func didCreateTodoSection(_ section: TodoSection, in list: TodoList?) {
        notifyDelegates { (delegate: TodoSectionProcessorDelegate) in
            delegate.didCreateTodoSection(section, in: list)
        }
    }
    
    func didDeleteTodoSection(_ section: TodoSection) {
        notifyDelegates { (delegate: TodoSectionProcessorDelegate) in
            delegate.didDeleteTodoSection(section)
        }
    }
    
    func didUpdateTodoSection(_ section: TodoSection, with name: String) {
        notifyDelegates { (delegate: TodoSectionProcessorDelegate) in
            delegate.didUpdateTodoSection(section, with: name)
        }
    }
    
    func didRecorderTodoSection(in sections: [TodoSection], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: TodoSectionProcessorDelegate) in
            delegate.didRecorderTodoSection(in: sections, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
}
