//
//  FocusTimerManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/29.
//

import Foundation
import CoreData

class FocusTimerManager {
    
    /// 数据更新器
    private let updater: FocusUpdater
    
    /// 默认上下文对象
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    private var _timers: [FocusTimer]?
    var timers: [FocusTimer] {
        if _timers == nil {
            _timers = getTimers() ?? []
        }
        
        return _timers!
    }
    
    
    init(updater: FocusUpdater) {
        self.updater = updater
    }
    
    func save() {
        HandyRecord.save()
    }
    
    
    // MARK: - Provider
    /// 同步获取所有计时器
    func getTimers() -> [FocusTimer]? {
        let timers: [FocusTimer]? = FocusTimer.findAll(sortedBy: ElementOrderKey,
                                                       ascending: true,
                                                       in: .defaultContext)
        return timers
    }
    
    // MARK: - Processor
    func createTimer(with editingTimer: FocusEditingTimer) {
        let timer = FocusTimer.newTimer(with: editingTimer)
        timer.order = timers.maxOrder + kOrderedStep
        updater.didCreateFocusTimer(timer)
        save()
    }
    
    func updateTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {
        if timer.isSameTimer(as: editingTimer) {
            return
        }

        timer.update(with: editingTimer)
        updater.didUpdateFocusTimer(timer)
        save()
    }
    
    func deleteTimer(_ timer: FocusTimer) {
        context.delete(timer)
        updater.didDeleteFocusTimer(timer)
        save()
    }
}
