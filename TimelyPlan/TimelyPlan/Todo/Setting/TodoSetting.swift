//
//  TodoSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/13.
//

import Foundation

class TodoSetting {
    
    enum Key: String, SettingKeyRepresentable {
        case autoCompleteSubtasks
        case autoCompleteParentTask
        case quickAddContinuously /// 快速连续添加
        
        static func keyPrefix() -> String? {
            return "TodoSetting"
        }
    }

    @CloudStored(key: Key.autoCompleteSubtasks.name, defaultValue: true)
    var autoCompleteSubtasks: Bool
    
    @CloudStored(key: Key.autoCompleteParentTask.name, defaultValue: true)
    var autoCompleteParentTask: Bool
    
    @CloudStored(key: Key.quickAddContinuously.name, defaultValue: true)
    var quickAddContinuously: Bool
    
    static let shared = TodoSetting()
    
    private init() {}
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
}
