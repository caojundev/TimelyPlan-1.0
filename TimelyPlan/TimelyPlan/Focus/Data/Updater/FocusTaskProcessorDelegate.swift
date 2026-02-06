//
//  FocusTimerProcessorDelegate.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/16.
//

import Foundation

protocol FocusTimerProcessorDelegate: AnyObject {
    
    /// 创建新计时器
    func didCreateFocusTimer(_ timer: FocusTimer)

    /// 计时器归档状态改变
    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer)
    
    /// 删除计时器
    func didDeleteFocusTimer(_ timer: FocusTimer)

    /// 更新计时器
    func didUpdateFocusTimer(_ timer: FocusTimer)
    
    /// 移动计时器到顶部
    func didMoveFocusTimerToTop(_ timer: FocusTimer)
    
    /// 通知任务的顺序发生改变
    func didReorderFocusTimer(in timers: [FocusTimer],
                              fromIndex: Int,
                              toIndex: Int)
}

extension FocusTimerProcessorDelegate {

    func didCreateFocusTimer(_ timer: FocusTimer) {
        
    }

    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {
        
    }
    
    func didDeleteFocusTimer(_ timer: FocusTimer) {
        
    }

    func didUpdateFocusTimer(_ timer: FocusTimer) {
        
    }

    func didMoveFocusTimerToTop(_ timer: FocusTimer) {
        
    }

    func didReorderFocusTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
        
    }
}
