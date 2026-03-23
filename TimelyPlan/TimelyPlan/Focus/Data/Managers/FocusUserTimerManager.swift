//
//  FocusUserTimerManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/29.
//

import Foundation
import CoreData

class FocusUserTimerManager {
    
    /// 数据更新器
    let updater = FocusTimerProcessorUpdater()
    
    /// 默认上下文对象
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    // MARK: - 获取计时器
    /// 获取所有计时器
    func getAllTimers() -> [FocusTimer]? {
        return CDFocusTimer.getAllTimers()?.timers
    }
    
    /// 获取所有活动计时器
    func getActiveTimers() -> [FocusTimer]? {
        return CDFocusTimer.getActiveTimers()?.timers
    }

    /// 获取所有已归档计时器
    func getArchivedTimers() -> [FocusTimer]? {
        return CDFocusTimer.getArchivedTimers()?.timers
    }
    
    /// 获取归档计时器数目
    func numberOfArchivedTimers() -> Int {
        return CDFocusTimer.numberOfArchivedTimers()
    }
    
    /// 搜索计时器
    func searchActiveTimers(containText text: String, completion:(@escaping([FocusTimer]?) -> Void)) {
        CDFocusTimer.searchActiveTimers(containText: text) { results in
            completion(results?.timers)
        }
    }
    
    func getTimer(withFeature feature: TimerFeature) -> FocusTimerRepresentable? {
        if let content = CDFocusTimer.getTimer(withIdentifier: feature.identifier) {
            return FocusTimer(content: content)
        }
        
        return nil
    }
    
    // MARK: - 处理计时器
    func createTimer(with editingTimer: FocusEditingTimer) {
        let onTop = FocusSetting.shared.addTimerOnTop
        let content = CDFocusTimer.newTimer(with: editingTimer, onTop: onTop)
        let timer = FocusTimer(content: content)
        updater.didCreateFocusTimer(timer)
        HandyRecord.save()
    }
    
    func createTimer(with editingTimer: FocusEditingTimer, in timers: [FocusTimer]?) {
        let onTop = FocusSetting.shared.addTimerOnTop
        let content = CDFocusTimer.newTimer(with: editingTimer)
        if onTop {
            let minOrder = timers?.minOrder ?? 0
            content.order = minOrder - kOrderedStep
        } else {
            let maxOrder = timers?.maxOrder ?? 0
            content.order = maxOrder + kOrderedStep
        }
        
        let timer = FocusTimer(content: content)
        updater.didCreateFocusTimer(timer)
        HandyRecord.save()
    }
    
    func updateTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {
        if timer.isSameTimer(as: editingTimer) {
            return
        }
        
        if let content = CDFocusTimer.getTimer(withIdentifier: timer.identifier) {
            content.update(with: editingTimer)
            
            let updatedTimer = FocusTimer(content: content)
            updater.didUpdateFocusTimer(updatedTimer)
            HandyRecord.save()
        }
    }
    
    func deleteTimer(_ timer: FocusTimer) {
        if let content = CDFocusTimer.getTimer(withIdentifier: timer.identifier) {
            context.delete(content)
            updater.didDeleteFocusTimer(timer)
            HandyRecord.save()
        }
    }
    
    func setArchived(_ isArchived: Bool, for timer: FocusTimer) {
        guard timer.isArchived != isArchived else {
            return
        }
        
        if let content = CDFocusTimer.getTimer(withIdentifier: timer.identifier) {
            content.isArchived = isArchived
            
            let updatedTimer = FocusTimer(content: content)
            updater.didChangeArchivedState(isArchived, for: updatedTimer)
            HandyRecord.save()
        }
    }
    
    func reorderTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
        var timers = timers
        timers.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        CDFocusTimer.syncOrders(for: timers)
        HandyRecord.save()
    }
    
    func moveTimer(_ timer: FocusTimer, in timers: [FocusTimer], toTop: Bool = true) {
        var timers = timers
        guard timers.count > 1, let _ = timers.remove(timer) else {
            return
        }

        if toTop {
            timers.insert(timer, at: 0)
        } else {
            timers.append(timer)
        }
        
        CDFocusTimer.syncOrders(for: timers)
        updater.didMoveFocusTimerToTop(timer)
        HandyRecord.save()
    }
    
}
