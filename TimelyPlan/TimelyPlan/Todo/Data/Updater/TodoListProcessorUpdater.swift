//
//  TodoListProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/30.
//

import Foundation

/// 用户列表处理通知协议
protocol TodoListProcessorDelegate: AnyObject{
    
    /// 添加新组时通知
    func didCreateTodoList(_ list: TodoList)
    
    /// 更新列表信息通知
    func didUpdateTodoList(_ list: TodoList)
    
    /// 删除列表时通知
    func didDeleteTodoList(_ list: TodoList, from folder: TodoFolder?)
    
    /// 列表移动通知， folder为nil时表示移动到根目录
    func didMoveTodoList(_ list: TodoList, from folder: TodoFolder?)
    
    /// 重新排序列表
    func didReorderTodoList(_ list: TodoList)
}

extension TodoListProcessorDelegate {

    func didUpdateTodoList(_ list: TodoList) {}

    func didCreateTodoList(_ list: TodoList) {}

    func didMoveTodoList(_ list: TodoList, from folder: TodoFolder?) {}

    func didDeleteTodoList(_ list: TodoList, from folder: TodoFolder?) {}

    func didReorderTodoList(_ list: TodoList) {}
}

class TodoListProcessorUpdater: NSObject,
                                TodoListProcessorDelegate {

    func didCreateTodoList(_ list: TodoList) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didCreateTodoList(list)
        }
    }
    
    func didUpdateTodoList(_ list: TodoList) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didUpdateTodoList(list)
        }
    }
    
    func didMoveTodoList(_ list: TodoList, from folder: TodoFolder?) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didMoveTodoList(list, from: folder)
        }
    }
    
    func didDeleteTodoList(_ list: TodoList, from folder: TodoFolder?) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didDeleteTodoList(list, from: folder)
        }
    }
    
    func didReorderTodoList(_ list: TodoList) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didReorderTodoList(list)
        }
    }
    
}
