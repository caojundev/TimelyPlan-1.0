//
//  CDFocusTimer+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/22.
//

import Foundation

extension CDFocusTimer: TPHexColorConvertible {
    
    // MARK: - TPHexColorConvertible
    static var defaultColor: UIColor  {
        return kFocusTimerDefaultColor
    }
    
    /// 根据编辑任务创建新任务
    static func newTimer(with editingTimer: FocusEditingTimer, onTop: Bool) -> CDFocusTimer {
        let timer = newTimer(with: editingTimer)
        timer.creationDate = .now
        if onTop {
            timer.order = minimumOrder - kOrderedStep
        } else {
            timer.order = maximumOrder + kOrderedStep
        }
        
        return timer
    }
    
    /// 根据编辑任务创建新任务
    static func newTimer(with editingTimer: FocusEditingTimer) -> CDFocusTimer {
        let timer = CDFocusTimer.createEntity(in: .defaultContext)
        timer.identifier = UUID().uuidString ///新创建任务设置标识
        timer.creationDate = .now
        timer.update(with: editingTimer)
        return timer
    }
    
    /// 最小排序因子
    static var minimumOrder: Int64 {
        let order = minimumValue(for: FocusTimerKey.order, in: .defaultContext) as? Int64
        return order ?? 0
    }
    
    /// 最大排序因子
    static var maximumOrder: Int64 {
        let order = maximumValue(for: FocusTimerKey.order, in: .defaultContext) as? Int64
        return order ?? 0
    }
    
    
    func update(with editingTimer: FocusEditingTimer) {
        self.name = editingTimer.name
        self.colorHex = editingTimer.color.hexString
        self.note = editingTimer.note
        self.configJSON = editingTimer.config?.jsonString()
        self.modificationDate = .now
    }

}

// MARK: - 排序
extension CDFocusTimer {

    static func syncOrders(for timers: [FocusTimer]) {
        timers.updateOrders()
        if let cdTimers = getTasks(with: timers.identifiers) {
            syncOrders(from: timers, to: cdTimers)
        }
    }
    
    private static func syncOrders(from timers: [FocusTimer],
                                   to cdTimers: [CDFocusTimer]) {
        let orderLookup = timers.reduce(into: [String: Int64]()) { result, timer in
            result[timer.identifier] = timer.order
        }
        
        cdTimers.forEach { timer in
            if let identifier = timer.identifier, let order = orderLookup[identifier] {
                timer.order = order
            }
        }
    }
}

/// 获取计时器
extension CDFocusTimer {
    
    // MARK: - Predicate
    static var activeTimersPredcateCondition: PredicateCondition {
        return (FocusTimerKey.isArchived, .isFalse)
    }
    
    static var archivedTimersPredcateCondition: PredicateCondition {
        return (FocusTimerKey.isArchived, .isTrue)
    }
    
    // MARK: - 异步获取
    static func fetchActiveTimers(completion: @escaping([CDFocusTimer]?) -> Void) {
        let predicate = NSPredicate.predicate(with: activeTimersPredcateCondition)
        CDFocusTimer.findAll(with: predicate,
                             sortedBy: ElementOrderKey,
                             ascending: true) { results in
            completion(results as? [CDFocusTimer])
        }
    }
    
    static func fetchArchivedTimers(completion: @escaping([CDFocusTimer]?) -> Void) {
        let predicate = NSPredicate.predicate(with: archivedTimersPredcateCondition)
        CDFocusTimer.findAll(with: predicate,
                             sortedBy: ElementOrderKey,
                             ascending: true) { results in
            completion(results as? [CDFocusTimer])
        }
    }
    
    // MARK: - 同步获取计时器
    /// 获取特定标识数组中的所有任务
    static func getTasks(with identifiers: [String]) -> [CDFocusTimer]? {
        let condition: PredicateCondition = (FocusTimerKey.identifier, .belongsTo(identifiers))
        let predicate = NSPredicate.predicate(with: condition)
        let results: [CDFocusTimer]? = CDFocusTimer.findAll(with: predicate, in: .defaultContext)
        return results
    }
    
    /// 获取特定标识的计时器
    static func getTimer(withIdentifier identifier: String) -> CDFocusTimer? {
        let condition: PredicateCondition = (FocusTimerKey.identifier, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        let timer = CDFocusTimer.findFirst(withPredicate: predicate, in: .defaultContext)
        return timer
    }
    
    /// 同步获取所有计时器
    static func getAllTimers() -> [CDFocusTimer]? {
        let timers: [CDFocusTimer]? = CDFocusTimer.findAll(sortedBy: ElementOrderKey,
                                                           ascending: true,
                                                           in: .defaultContext)
        return timers
    }
    
    /// 获取所有活动计时器
    static func getActiveTimers() -> [CDFocusTimer]? {
        return getTimers(withCondition: activeTimersPredcateCondition)
    }

    private static func getTimers(withCondition condition: PredicateCondition) -> [CDFocusTimer]? {
        let predicate = NSPredicate.predicate(with: condition)
        let timers: [CDFocusTimer]? = CDFocusTimer.findAll(with: predicate,
                                                      sortedBy: ElementOrderKey,
                                                      ascending: true,
                                                      in: .defaultContext)
        return timers
    }
    
    /// 获取所有已归档计时器
    static func getArchivedTimers() -> [CDFocusTimer]? {
        return getTimers(withCondition: archivedTimersPredcateCondition)
    }
    
    /// 获取归档计时器数目
    static func numberOfArchivedTimers() -> Int {
        let condition: PredicateCondition = (FocusTimerKey.isArchived, .isTrue)
        let predicate = NSPredicate.predicate(with: condition)
        let count = CDFocusTimer.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }

    // MARK: - 异步搜索
    /// 搜索计时器
    static func searchActiveTimers(containText text: String, completion:(@escaping([CDFocusTimer]?) -> Void)) {
        let conditions: [PredicateCondition] = [(FocusTimerKey.isArchived, .isFalse),
                                                (FocusTimerKey.name, .contains(text))]
        let predicate = conditions.andPredicate()
        CDFocusTimer.fetchAll(matching: predicate, sortBy: ElementOrderKey, ascending: true) { results in
            let timers = results as? [CDFocusTimer]
            completion(timers)
        }
    }
}

extension Array where Element == CDFocusTimer {
    
    /// 所有标识
    var identifiers: [String] {
        var results = [String]()
        for timer in self {
            if let identifier = timer.identifier {
                results.append(identifier)
            }
        }
        
        return results
    }
    
    var timers: [FocusTimer] {
        return self.map { FocusTimer(content: $0) }
    }
}
