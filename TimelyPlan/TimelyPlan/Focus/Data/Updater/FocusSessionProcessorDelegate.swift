//
//  Focus+Session.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/19.
//

import Foundation

protocol FocusSessionProcessorDelegate {
    
    /// 添加专注会话
    func didAddFocusSession(_ session: FocusSession, with record: FocusRecord)
    
    /// 更新专注会话
    func didUpdateFocusSession(_ session: FocusSession)
    
    /// 删除专注会话
    func didDeleteFocusSession(_ session: FocusSession)
}
