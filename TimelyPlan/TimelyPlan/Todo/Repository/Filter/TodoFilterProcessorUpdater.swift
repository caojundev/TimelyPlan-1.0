//
//  TodoFilterProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation

/// 过滤器处理通知协议
protocol TodoFilterProcessorDelegate: AnyObject{
    
    func didChangeRemoteTodoFilter(with results: EntityChangeResults<TodoFilter>?)
    
    func didCreateTodoFilter(_ filter: TodoFilter)

    func didDeleteTodoFilter(_ filter: TodoFilter)
    
    func didUpdateTodoFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter)

    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int)
}

extension TodoFilterProcessorDelegate {
    
    func didChangeRemoteTodoFilter(with results: EntityChangeResults<TodoFilter>?) {}
    
    func didCreateTodoFilter(_ filter: TodoFilter) {}

    func didDeleteTodoFilter(_ filter: TodoFilter) {}

    func didUpdateTodoFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {}
    
    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {}
}

class TodoFilterProcessorUpdater: NSObject, TodoFilterProcessorDelegate {
    
    func didChangeRemoteTodoFilter(with results: EntityChangeResults<TodoFilter>?) {
        notifyDelegates { (delegate: TodoFilterProcessorDelegate) in
            delegate.didChangeRemoteTodoFilter(with: results)
        }
    }
    
    func didCreateTodoFilter(_ filter: TodoFilter) {
        notifyDelegates { (delegate: TodoFilterProcessorDelegate) in
            delegate.didCreateTodoFilter(filter)
        }
    }
    
    func didDeleteTodoFilter(_ filter: TodoFilter) {
        notifyDelegates { (delegate: TodoFilterProcessorDelegate) in
            delegate.didDeleteTodoFilter(filter)
        }
    }
    
    func didUpdateTodoFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {
        notifyDelegates { (delegate: TodoFilterProcessorDelegate) in
            delegate.didUpdateTodoFilter(filter, with: editingFilter)
        }
    }
    
    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: TodoFilterProcessorDelegate) in
            delegate.didReorderTodoFilter(in: filters, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
}
