//
//  AppInitializer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation

var todo: Todo! /// 待办
var focus: Focus! /// 专注

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
        todo = Todo()
        focus = Focus()
        TPImpactFeedback.feedback.enabled = true
    }
}
