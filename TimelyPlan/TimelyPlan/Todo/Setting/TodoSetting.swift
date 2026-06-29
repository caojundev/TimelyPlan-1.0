//
//  TodoSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/13.
//

import Foundation

struct TodoSmartListDisplay: Codable, Equatable {
    
    var autoHideEmpty: Bool?
    
    var hiddenListTypes: Set<TodoSmartListType>?
}

class TodoSetting {
    
    enum Key: String, SettingKeyRepresentable {
        case startSound /// 开始提示音
        case dueSound /// 截止提示音
        
        case homeSectionTypes
        case smartListDisplay   /// 智能清单显示
        
        case autoCompleteSubtasks
        case autoCompleteParentTask
        
        case quickAddContinuously /// 快速连续添加
        case quickAddKeepContentWhenHidden /// 隐藏时保留输入内容
        
        case addListOnTop /// 添加列表到顶部
        case addTaskOnTop /// 添加任务到顶部
        case addTagOnTop /// 添加标签到顶部
        case addFilterOnTop /// 添加过滤器到顶部
        
        case listLayoutTypes /// 列表布局
        
        static func keyPrefix() -> String? {
            return "TodoSetting"
        }
    }
    
    @CloudStored(key: Key.startSound.name, defaultValue: nil)
    var startSound: NotificationSound?
    
    @CloudStored(key: Key.dueSound.name, defaultValue: nil)
    var dueSound: NotificationSound?
    
    @CloudStored(key: Key.smartListDisplay.name, defaultValue: nil)
    var smartListDisplay: TodoSmartListDisplay?
    
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

    @CloudStored(key: Key.listLayoutTypes.name, defaultValue: nil)
    private var listLayoutTypes: [String: TodoListLayoutType]?
    
    static let shared = TodoSetting()
    
    private init() {}
    
    var orderedHomeSectionTypes: [TodoHomeSectionType] {
        if let sectionTypes = self.homeSectionTypes, Set(sectionTypes) == Set(TodoHomeSectionType.allCases) {
            return sectionTypes
        }
        
        return TodoHomeSectionType.allCases
    }
    
    
    // MARK: - 列表布局
    
    func setListLayoutType(_ layoutType: TodoListLayoutType?, for key: String) {
        var layoutTypes = self.listLayoutTypes ?? [:]
        layoutTypes[key] = layoutType
        self.listLayoutTypes = layoutTypes
    }
    
    func listLayoutType(for key: String) -> TodoListLayoutType? {
        guard let layoutTypes = self.listLayoutTypes else {
            return nil
        }
        
        return layoutTypes[key]
    }
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
}
