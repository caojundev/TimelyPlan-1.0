//
//  WorkspaceState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/21.
//

import Foundation

class WorkspaceState {
    
    enum Key: String, SettingKeyRepresentable {
        case currentDashboardID /// 当前面板 ID
        
        static func keyPrefix() -> String? {
            return "WorkspaceState"
        }
    }
    
    @LocalStored(key: Key.currentDashboardID.name, defaultValue: nil)
    var currentDashboardID: String?
    
    static let shared = WorkspaceState()
    
    private init() {}
}
