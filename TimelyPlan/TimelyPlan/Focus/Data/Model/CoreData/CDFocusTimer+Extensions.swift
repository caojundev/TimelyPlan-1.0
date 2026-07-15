//
//  CDFocusTimer+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/22.
//

import Foundation

extension CDFocusTimer: TPHexColorConvertible, SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    // MARK: - TPHexColorConvertible
    static var defaultColor: UIColor  {
        return FocusConstant.timerDefaultColor
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
    
    func update(with editingTimer: FocusEditingTimer) {
        self.name = editingTimer.name
        self.colorHex = editingTimer.color.hexString
        self.note = editingTimer.note
        self.modificationDate = .now
        
        self.isAddedToMyDay = editingTimer.isAddedToMyDay
        self.startDate = editingTimer.startDate
        self.endDate = editingTimer.endDate
        self.startTime = editingTimer.startTime
        self.configJSON = editingTimer.config?.jsonString()
        self.timePlanRuleJSON = editingTimer.timePlan?.regularRule?.jsonString()
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
        CDFocusTimer.fetchAll(matching: predicate,
                              sortBy: ElementOrderKey,
                              ascending: true) { results in
            completion(results as? [CDFocusTimer])
        }
    }
    
    static func fetchArchivedTimers(completion: @escaping([CDFocusTimer]?) -> Void) {
        let predicate = NSPredicate.predicate(with: archivedTimersPredcateCondition)
        CDFocusTimer.fetchAll(matching: predicate,
                              sortBy: ElementOrderKey,
                              ascending: true) { results in
            completion(results as? [CDFocusTimer])
        }
    }
    
    // MARK: - 同步获取计时器
    /// 获取特定标识数组中的所有任务
    static func getTimers(with identifiers: [String]) -> [CDFocusTimer]? {
        let condition: PredicateCondition = (FocusTimerKey.identifier, .belongsTo(identifiers))
        let predicate = NSPredicate.predicate(with: condition)
        let results: [CDFocusTimer]? = CDFocusTimer.getAll(matching: predicate, in: .defaultContext)
        return results
    }
    
    /// 获取特定标识的计时器
    static func getTimer(withIdentifier identifier: String) -> CDFocusTimer? {
        let condition: PredicateCondition = (FocusTimerKey.identifier, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        let timer = CDFocusTimer.getFirst(matching: predicate, in: .defaultContext)
        return timer
    }
    
    /// 同步获取所有计时器
    static func getAllTimers() -> [CDFocusTimer]? {
        let timers: [CDFocusTimer]? = CDFocusTimer.getAll(sortBy: ElementOrderKey,
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
        let timers: [CDFocusTimer]? = CDFocusTimer.getAll(matching: predicate,
                                                      sortBy: ElementOrderKey,
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
