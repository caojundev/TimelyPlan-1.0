//
//  TodoFilterProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation

/// 过滤器处理通知协议
protocol TodoFilterProcessorDelegate: AnyObject{
    
    func didCreateTodoFilter(_ filter: TodoFilter)

    func didDeleteTodoFilter(_ filter: TodoFilter)
    
    func didUpdateTodoFilter(_ filter: TodoFilter)

    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int)
}

class TodoFilterProcessorUpdater: NSObject, TodoFilterProcessorDelegate {
    
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
    
    func didUpdateTodoFilter(_ filter: TodoFilter) {
        notifyDelegates { (delegate: TodoFilterProcessorDelegate) in
            delegate.didUpdateTodoFilter(filter)
        }
    }
    
    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: TodoFilterProcessorDelegate) in
            delegate.didReorderTodoFilter(in: filters, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
}
