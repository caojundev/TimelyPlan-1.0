//
//  TodoTagProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/3.
//

import Foundation

/// 标签处理通知协议
protocol TodoTagProcessorDelegate: AnyObject{
    
    func didChangeRemoteTodoTag(with results: EntityChangeResults<TodoTag>?)
        
    /// 添加新标签
    func didCreateTodoTag(_ tag: TodoTag)

    /// 删除标签
    func didDeleteTodoTag(_ tag: TodoTag)
    
    /// 更新标签
    func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag)

    /// 重新排序标签
    func didRecorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int)
}

extension TodoTagProcessorDelegate {
    
    func didChangeRemoteTodoTag(with results: EntityChangeResults<TodoTag>?) {}
    
    func didCreateTodoTag(_ tag: TodoTag) {}

    func didDeleteTodoTag(_ tag: TodoTag) {}
    
    func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {}

    func didRecorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {}
}

class TodoTagProcessorUpdater: NSObject, TodoTagProcessorDelegate {
    
    func didChangeRemoteTodoTag(with results: EntityChangeResults<TodoTag>?) {
        notifyDelegates { (delegate: TodoTagProcessorDelegate) in
            delegate.didChangeRemoteTodoTag(with: results)
        }
    }
    
    func didCreateTodoTag(_ tag: TodoTag) {
        notifyDelegates { (delegate: TodoTagProcessorDelegate) in
            delegate.didCreateTodoTag(tag)
        }
    }
    
    func didDeleteTodoTag(_ tag: TodoTag) {
        notifyDelegates { (delegate: TodoTagProcessorDelegate) in
            delegate.didDeleteTodoTag(tag)
        }
    }
    
    func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        notifyDelegates { (delegate: TodoTagProcessorDelegate) in
            delegate.didUpdateTodoTag(tag, with: editingTag)
        }
    }
    
    func didRecorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: TodoTagProcessorDelegate) in
            delegate.didRecorderTodoTag(in: tags, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
}
