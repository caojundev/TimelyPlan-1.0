//
//  TodoTagProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/3.
//

import Foundation

/// 标签处理通知协议
protocol TodoTagProcessorDelegate: AnyObject{
    
    /// 添加新标签
    func didCreateTodoTag(_ tag: TodoTag)

    /// 删除标签
    func didDeleteTodoTag(_ tag: TodoTag)
    
    /// 更新标签
    func didUpdateTodoTag(_ tag: TodoTag)

    /// 重新排序标签
    func didReorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int)
}

class TodoTagProcessorUpdater: NSObject, TodoTagProcessorDelegate {
    
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
    
    func didUpdateTodoTag(_ tag: TodoTag) {
        notifyDelegates { (delegate: TodoTagProcessorDelegate) in
            delegate.didUpdateTodoTag(tag)
        }
    }
    
    func didReorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: TodoTagProcessorDelegate) in
            delegate.didReorderTodoTag(in: tags, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
}
