//
//  FocusUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/25.
//

import Foundation

class FocusUpdater: NSObject,
                        FocusTimerProcessorDelegate,
                        FocusSessionProcessorDelegate {
    
    // MARK: - FocusTimerProcessorDelegate
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
    
    func didUpdateFocusTimer(_ timer: FocusTimer) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
            delegate.didUpdateFocusTimer(timer)
        }
    }
    
    func didReorderFocusTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
            delegate.didReorderFocusTimer(in: timers, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
    
    func didMoveFocusTimerToTop(_ timer: FocusTimer) {
        notifyDelegates { (delegate: FocusTimerProcessorDelegate) in
            delegate.didMoveFocusTimerToTop(timer)
        }
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSession(_ session: FocusSession, with record: FocusRecord) {
        notifyDelegates { (delegate: FocusSessionProcessorDelegate) in
            delegate.didAddFocusSession(session, with: record)
        }
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        notifyDelegates { (delegate: FocusSessionProcessorDelegate) in
            delegate.didDeleteFocusSession(session)
        }
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        notifyDelegates { (delegate: FocusSessionProcessorDelegate) in
            delegate.didUpdateFocusSession(session)
        }
    }
}
