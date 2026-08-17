//
//  AppState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/17.
//

import Foundation

class AppState {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case sideMenuType /// 侧边栏菜单
        
        static func keyPrefix() -> String? {
            return "AppState"
        }
    }
    
    @LocalStored(key: SettingKey.sideMenuType.name, defaultValue: SideMenuType.myDay)
    var sideMenuType: SideMenuType
    
    static let shared = AppState()
    private init() {}
}

