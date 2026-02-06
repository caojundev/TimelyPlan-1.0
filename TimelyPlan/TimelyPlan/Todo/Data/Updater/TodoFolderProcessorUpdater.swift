//
//  TodoFolderProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/28.
//

import Foundation

/// 用户目录处理通知协议
protocol TodoFolderProcessorDelegate: AnyObject{
    
    /// 添加新组时通知
    func didCreateTodoFolder(_ folder: TodoFolder)
    
    /// 更新目录信息通知
    func didUpdateTodoFolder(_ folder: TodoFolder)
    
    /// 删除目录时通知
    func didDeleteTodoFolder(_ folder: TodoFolder)
    
    /// 取消分组
    func didUngroupTodoFolder(_ folder: TodoFolder, with lists: [TodoList])
    
    /// 重新排序目录
    func didReorderTodoFolder(_ folder: TodoFolder)
}

extension TodoFolderProcessorDelegate {
    
    func didCreateTodoFolder(_ folder: TodoFolder) {}
    
    func didUpdateTodoFolder(_ folder: TodoFolder) {}
    
    func didDeleteTodoFolder(_ folder: TodoFolder) {}
    
    func didUngroupTodoFolder(_ folder: TodoFolder, with lists: [TodoList]) {}
    
    func didReorderTodoFolder(_ folder: TodoFolder) {}
}

class TodoFolderProcessorUpdater: NSObject,
                                  TodoFolderProcessorDelegate {

    func didCreateTodoFolder(_ folder: TodoFolder) {
        notifyDelegates { (delegate: TodoFolderProcessorDelegate) in
            delegate.didCreateTodoFolder(folder)
        }
    }
    
    func didUpdateTodoFolder(_ folder: TodoFolder) {
        notifyDelegates { (delegate: TodoFolderProcessorDelegate) in
            delegate.didUpdateTodoFolder(folder)
        }
    }
    
    func didDeleteTodoFolder(_ folder: TodoFolder) {
        notifyDelegates { (delegate: TodoFolderProcessorDelegate) in
            delegate.didDeleteTodoFolder(folder)
        }
    }
    
    func didUngroupTodoFolder(_ folder: TodoFolder, with lists: [TodoList]) {
        notifyDelegates { (delegate: TodoFolderProcessorDelegate) in
            delegate.didUngroupTodoFolder(folder, with: lists)
        }
    }
    
    func didReorderTodoFolder(_ folder: TodoFolder) {
        notifyDelegates { (delegate: TodoFolderProcessorDelegate) in
            delegate.didReorderTodoFolder(folder)
        }
    }
}
