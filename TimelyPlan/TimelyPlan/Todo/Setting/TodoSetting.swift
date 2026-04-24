//
//  TodoSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/13.
//

import Foundation

class TodoSetting {
    
    enum Key: String, SettingKeyRepresentable {
        case homeSectionTypes
        case autoCompleteSubtasks
        case autoCompleteParentTask
        
        case quickAddContinuously /// 快速连续添加
        case quickAddKeepContentWhenHidden /// 隐藏时保留输入内容
        
        case addListOnTop /// 添加列表到顶部
        case addTaskOnTop /// 添加任务到顶部
        case addTagOnTop /// 添加标签到顶部
        case addFilterOnTop /// 添加过滤器到顶部
        
        static func keyPrefix() -> String? {
            return "TodoSetting"
        }
    }
    
    @CloudStored(key: Key.homeSectionTypes.name, defaultValue: nil)
    var homeSectionTypes: [TodoHomeSectionType]?
    
    @CloudStored(key: Key.autoCompleteSubtasks.name, defaultValue: true)
    var autoCompleteSubtasks: Bool
    
    @CloudStored(key: Key.autoCompleteParentTask.name, defaultValue: true)
    var autoCompleteParentTask: Bool
    
    @CloudStored(key: Key.quickAddContinuously.name, defaultValue: true)
    var quickAddContinuously: Bool
    
    @CloudStored(key: Key.quickAddKeepContentWhenHidden.name, defaultValue: true)
    var quickAddKeepContentWhenHidden: Bool
    
    @CloudStored(key: Key.addListOnTop.name, defaultValue: false)
    var addListOnTop:Bool
    
    @CloudStored(key: Key.addTaskOnTop.name, defaultValue: false)
    var addTaskOnTop:Bool
    
    @CloudStored(key: Key.addTagOnTop.name, defaultValue: false)
    var addTagOnTop:Bool
    
    @CloudStored(key: Key.addFilterOnTop.name, defaultValue: false)
    var addFilterOnTop:Bool

    static let shared = TodoSetting()
    
    private init() {}
    
    var orderedHomeSectionTypes: [TodoHomeSectionType] {
        if let sectionTypes = self.homeSectionTypes, Set(sectionTypes) == Set(TodoHomeSectionType.allCases) {
            return sectionTypes
        }
        
        return TodoHomeSectionType.allCases
    }
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
    
}
