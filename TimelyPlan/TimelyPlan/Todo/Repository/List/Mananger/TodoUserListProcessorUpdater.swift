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
    func didUpdateTodoList(_ list: TodoList, with editingList: TodoEditingList)
    
    /// 删除列表时通知
    func didDeleteTodoLists(_ lists: [TodoList])
    
    /// 解散清单
    func didUngroupList(_ list: TodoList)
    
    /// 列表移动通知， parent为nil时表示移动到根目录
    func didMoveTodoList(_ list: TodoList, to parent: TodoList?)
    
    /// 重新列表排序
    func didReorderTodoList(_ list: TodoList)
}

extension TodoListProcessorDelegate {
    
    func didUpdateTodoList(_ list: TodoList, with editingList: TodoEditingList) {}
    
    func didCreateTodoList(_ list: TodoList) {}
    
    func didUngroupList(_ list: TodoList) {}
    
    func didMoveTodoList(_ list: TodoList, to parent: TodoList?) {}
    
    func didDeleteTodoLists(_ lists: [TodoList]) {}

    func didReorderTodoList(_ list: TodoList) {}
}

class TodoListProcessorUpdater: NSObject,
                                TodoListProcessorDelegate {

    func didCreateTodoList(_ list: TodoList) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didCreateTodoList(list)
        }
    }
    
    func didUpdateTodoList(_ list: TodoList, with editingList: TodoEditingList) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didUpdateTodoList(list, with: editingList)
        }
    }
    
    func didMoveTodoList(_ list: TodoList, to parent: TodoList?) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didMoveTodoList(list, to: parent)
        }
    }

    /// 解散清单
    func didUngroupList(_ list: TodoList) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didUngroupList(list)
        }
    }
    
    func didDeleteTodoLists(_ lists: [TodoList]) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didDeleteTodoLists(lists)
        }
    }

    func didReorderTodoList(_ list: TodoList) {
        notifyDelegates { (delegate: TodoListProcessorDelegate) in
            delegate.didReorderTodoList(list)
        }
    }
}
