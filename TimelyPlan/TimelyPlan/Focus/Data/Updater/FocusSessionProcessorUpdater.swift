//
//  FocusSessionProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/19.
//

import Foundation

protocol FocusSessionProcessorDelegate {
    
    /// 添加专注会话
    func didAddFocusSessions(_ sessions: [FocusSession])
    
    /// 更新专注会话
    func didUpdateFocusSession(_ session: FocusSession)
    
    /// 删除专注会话
    func didDeleteFocusSession(_ session: FocusSession)
}

class FocusSessionProcessorUpdater: NSObject,
                                    FocusSessionProcessorDelegate {

    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        notifyDelegates { (delegate: FocusSessionProcessorDelegate) in
            delegate.didAddFocusSessions(sessions)
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
