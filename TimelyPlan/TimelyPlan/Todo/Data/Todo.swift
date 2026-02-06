//
//  Todo.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/29.
//

import Foundation
import CoreData

class Todo {

    /// 目录管理器
    let folderManager = TodoFolderManager()
    
    /// 列表管理器
    let listManager = TodoListManager()
    
    /// 任务管理器
    let taskManager = TodoTaskManager()
    
    /// 任务步骤管理器
    let stepManager = TodoStepManager()
    
    /// 标签管理器
    let tagManager = TodoTagManager()
    
    /// 过滤器管理器
    let filterManager = TodoFilterManager()
    
    private(set) var userInfo: TodoUserInfo
    
    init() {
        self.userInfo = Self.getUserInfo()
    }
    
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    func save() {
        HandyRecord.save()
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    /// 添加处理更新器
    func addUpdater(_ updater: AnyObject, for option: TodoUpdaterOption = .all) {
        if option.contains(.folder) {
            folderManager.updater.addDelegate(updater)
        }
        
        if option.contains(.list) {
            listManager.updater.addDelegate(updater)
        }
        
        if option.contains(.task) {
            taskManager.updater.addDelegate(updater)
        }
        
        if option.contains(.step) {
            stepManager.updater.addDelegate(updater)
        }
        
        if option.contains(.tag) {
            tagManager.updater.addDelegate(updater)
        }
        
        if option.contains(.filter) {
            filterManager.updater.addDelegate(updater)
        }
        
    }
    
}
