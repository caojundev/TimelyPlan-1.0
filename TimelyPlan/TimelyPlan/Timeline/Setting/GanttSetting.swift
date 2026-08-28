//
//  GanttSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/28.
//

import Foundation

class GanttSetting {

    enum Key: String, SettingKeyRepresentable {
        case firstWeekday
        case showTodo
        case showGoal
        
        static func keyPrefix() -> String? {
            return "GanttSetting"
        }
    }

    @CloudStored(key: Key.firstWeekday.name, defaultValue: .sunday)
    var firstWeekday: Weekday
    
    @CloudStored(key: Key.showTodo.name, defaultValue: true)
    var showTodo: Bool

    @CloudStored(key: Key.showGoal.name, defaultValue: true)
    var showGoal: Bool
    
    static let shared = GanttSetting()
    
    private init() {}
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKeys keys: [Key]? = nil) {
        let keys = keys ?? Key.allCases
        let keyNames = keys.map { $0.name }
        KeyValueStorage.shared.addObserver(observer, forKeys: keyNames)
    }
}
