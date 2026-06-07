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
    
    func didUpdateTodoSection(_ section: TodoSection)

    func didReorderTodoSection(in sections: [TodoSection],
                               of list: TodoList?,
                               from fromIndex: Int,
                               to toIndex: Int)
}

extension TodoSectionProcessorDelegate {

    func didCreateTodoSection(_ section: TodoSection, in list: TodoList?) {}

    func didDeleteTodoSection(_ section: TodoSection) {}

    func didUpdateTodoSection(_ section: TodoSection) {}

    func didReorderTodoSection(in sections: [TodoSection],
                               of list: TodoList?,
                               from fromIndex: Int,
                               to toIndex: Int) {}
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
    
    func didUpdateTodoSection(_ section: TodoSection) {
        notifyDelegates { (delegate: TodoSectionProcessorDelegate) in
            delegate.didUpdateTodoSection(section)
        }
    }
    
    func didReorderTodoSection(in sections: [TodoSection],
                               of list: TodoList?,
                               from fromIndex: Int,
                               to toIndex: Int) {
        notifyDelegates { (delegate: TodoSectionProcessorDelegate) in
            delegate.didReorderTodoSection(in: sections,
                                           of: list,
                                           from: fromIndex,
                                           to: toIndex)
        }
    }
}
