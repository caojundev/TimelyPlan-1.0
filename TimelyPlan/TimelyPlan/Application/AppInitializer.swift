//
//  AppInitializer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation

class AppInitializer {
    
    static var isInitialized = false
    static func initialize(completion: @escaping(Bool) -> Void) {
        guard !isInitialized else {
            return
        }
        
        HandyRecord.setup { success in
            guard success else {
                completion(false)
                return
            }
            
            print("HandyRecord 初始化成功")
            isInitialized = true
            AppInitializer.setup()
            completion(true)
        }
    }
    
    /// 初始化管理器
    static func setup() {
        TPImpactFeedback.feedback.enabled = AppSetting.shared.isHapiticFeedbackOn
        
        /// 任务通知刷新
        TaskNotificationScheduler.shared.refreshTasks()
    }
}
