//
//  FocusTimerProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/22.
//

import Foundation

protocol FocusTimerProcessorDelegate: AnyObject {
    
    func didChangeRemoteFocusTimer(with results: EntityChangeResults<FocusTimer>?)
        
    /// 创建新计时器
    func didCreateFocusTimer(_ timer: FocusTimer)

    /// 计时器归档状态改变
    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer)
    
    /// 删除计时器
    func didDeleteFocusTimer(_ timer: FocusTimer)

    /// 更新计时器
    func didUpdateFocusTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer)
    
    /// 移动计时器到顶部
    func didMoveFocusTimer(_ timer: FocusTimer)
    
    /// 通知任务的顺序发生改变
    func didReorderFocusTimer(in timers: [FocusTimer],
                              fromIndex: Int,
                              toIndex: Int)
}

extension FocusTimerProcessorDelegate {
    
    func didChangeRemoteFocusTimer(with results: EntityChangeResults<FocusTimer>?) {}
        
    func didCreateFocusTimer(_ timer: FocusTimer) {}

    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {}
    
    func didDeleteFocusTimer(_ timer: FocusTimer) {}

    func didUpdateFocusTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {}

    func didMoveFocusTimer(_ timer: FocusTimer) {}

    func didReorderFocusTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {}
}

class FocusTimerProcessorUpdater: NSObject,
                                  FocusTimerProcessorDelegate {
             
    func didChangeRemoteFocusTimer(with results: EntityChangeResults<FocusTimer>?) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
            delegate.didChangeRemoteFocusTimer(with: results)
        }
    }
    
    func didCreateFocusTimer(_ timer: FocusTimer) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
            delegate.didCreateFocusTimer(timer)
        }
    }

    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
            delegate.didChangeArchivedState(isArchived, for: timer)
        }
    }

    func didDeleteFocusTimer(_ timer: FocusTimer) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
            delegate.didDeleteFocusTimer(timer)
        }
    }

    func didUpdateFocusTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
             delegate.didUpdateFocusTimer(timer, with: editingTimer)
        }
    }

    func didReorderFocusTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
            delegate.didReorderFocusTimer(in: timers, fromIndex: fromIndex, toIndex: toIndex)
        }
    }

    func didMoveFocusTimer(_ timer: FocusTimer) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
            delegate.didMoveFocusTimer(timer)
        }
    }
}
