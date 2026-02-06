//
//  Focus.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/23.
//

import Foundation
import CoreData

class Focus {
    
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    var setting: FocusSetting {
        get {
            return settingManager.getSetting()
        }
        
        set {
            settingManager.setSetting(newValue)
        }
    }
    
    /// 系统计时器管理器
    let systemTimerManager = FocusSystemTimerManager()
    
    /// 设置管理器
    let settingManager = FocusSettingManager()
    
    /// 数据变化会通知到更新器
    let updater = FocusUpdater()
    
    func save() {
        HandyRecord.save()
    }
    
    /// 添加更新器代理对象
    func addUpdaterDelegate(_ delegate: AnyObject) {
        self.updater.addDelegate(delegate)
    }
    
    /// 移除更新器代理对象
    func removeUpdaterDelegate(_ delegate: AnyObject) {
        self.updater.removeDelegate(delegate)
    }
    
    // MARK: - 默认计时器
    /// 当前默认计时器
    func defaultTimer() -> FocusSystemTimer {
        return systemTimerManager.defaultTimer
    }
    
    /// 所有默认计时器
    func allDefaultTimers() -> [FocusSystemTimer] {
        return systemTimerManager.allTimers
    }
    
    // MARK: - User Timer Provider
    /// 同步获取所有计时器
    func getAllTimers() -> [FocusTimer]? {
        let timers: [FocusTimer]? = FocusTimer.findAll(sortedBy: ElementOrderKey,
                                                       ascending: true,
                                                       in: .defaultContext)
        return timers
    }
    
    /// 获取所有活动计时器
    func getActiveTimers() -> [FocusTimer]? {
        let condition: PredicateCondition = (FocusTimerKey.isArchived, .isFalse)
        return getTimers(withCondition: condition)
    }

    private func getTimers(withCondition condition: PredicateCondition) -> [FocusTimer]? {
        let predicate = NSPredicate.predicate(with: condition)
        let timers: [FocusTimer]? = FocusTimer.findAll(with: predicate,
                                                      sortedBy: ElementOrderKey,
                                                      ascending: true,
                                                      in: .defaultContext)
        return timers
    }
    
    /// 获取所有已归档计时器
    func getArchivedTimers() -> [FocusTimer]? {
        let condition: PredicateCondition = (FocusTimerKey.isArchived, .isTrue)
        return getTimers(withCondition: condition)
    }
    
    /// 获取归档计时器数目
    static func numberOfArchivedTimers() -> Int {
        let condition: PredicateCondition = (FocusTimerKey.isArchived, .isTrue)
        let predicate = NSPredicate.predicate(with: condition)
        let count = FocusTimer.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }
    
    /// 搜索计时器
    func searchActiveTimers(containText text: String, completion:(@escaping([FocusTimer]?) -> Void)) {
        let conditions: [PredicateCondition] = [(FocusTimerKey.isArchived, .isFalse),
                                                (FocusTimerKey.name, .contains(text))]
        let predicate = conditions.andPredicate()
        FocusTimer.fetchAll(withPredicate: predicate, sortedBy: ElementOrderKey, ascending: true) { results in
            let timers = results as? [FocusTimer]
            completion(timers)
        }
    }
    
    /// 获取特定标识的计时器
    private static func getTimer(withIdentifier identifier: String) -> FocusTimer? {
        let condition: PredicateCondition = (FocusTimerKey.identifier, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        let timer = FocusTimer.findFirst(withPredicate: predicate, in: .defaultContext)
        return timer
    }
    
    func getTimer(withFeature feature: TimerFeature) -> FocusTimerRepresentable? {
        if feature.isNone {
            return nil
        }
        
        if feature.isDefaultTimer {
            /// 默认计时器
            return systemTimerManager.timer(of: feature)
        }
        
        return Focus.getTimer(withIdentifier: feature.identifier)
    }
    
    // MARK: - User Timer Processor
    func createTimer(with editingTimer: FocusEditingTimer, in timers: [FocusTimer]?) {
        let onTop: Bool = focus.setting.getAddTimerOnTop()
        let timer = FocusTimer.newTimer(with: editingTimer)
        timer.order = timers?.insertOrder(onTop: onTop) ?? 0
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
    
    func setArchived(_ isArchived: Bool, for timer: FocusTimer) {
        guard timer.isArchived != isArchived else {
            return
        }
        
        timer.isArchived = isArchived
        updater.didChangeArchivedState(isArchived, for: timer)
        save()
    }
        
    func deleteTimer(_ timer: FocusTimer) {
        context.delete(timer)
        updater.didDeleteFocusTimer(timer)
        save()
    }
    
    func reorderTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
        var timers = timers
        timers.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        timers.updateOrders()
        save()
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
        
        timers.updateOrders()
        updater.didMoveFocusTimerToTop(timer)
        save()
    }
}
