//
//  AppState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/17.
//

import Foundation

class AppState {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case sideMenuType        /// 侧边栏菜单
        case sideMenuTypeOrder   /// 侧边栏菜单顺序
        case hiddenSideMenuTypes /// 隐藏的侧边栏菜单
        
        static func keyPrefix() -> String? {
            return "AppState"
        }
    }
    
    @LocalStored(key: SettingKey.sideMenuType.name, defaultValue: SideMenuType.myDay)
    var sideMenuType: SideMenuType
    
    /// 侧边栏菜单自定义顺序
    @LocalStored(key: SettingKey.sideMenuTypeOrder.name, defaultValue: [])
    var sideMenuTypeOrder: [SideMenuType]
    
    /// 隐藏的侧边栏菜单
    @LocalStored(key: SettingKey.hiddenSideMenuTypes.name, defaultValue: [])
    var hiddenSideMenuTypes: [SideMenuType]
    
    static let shared = AppState()
    private init() {}
    
    // MARK: - 侧边栏菜单
    /// 排序后的侧边栏菜单（包含固定显示的菜单，固定菜单始终显示在末尾）
    var orderedSideMenuTypes: [SideMenuType] {
        let customizableTypes = SideMenuType.customizableSideMenuTypes
        var types = [SideMenuType]()
        for type in sideMenuTypeOrder where customizableTypes.contains(type) {
            if !types.contains(type) {
                types.append(type)
            }
        }
        
        /// 补充未包含的菜单类型
        for type in customizableTypes where !types.contains(type) {
            types.append(type)
        }
        
        /// 固定显示的菜单始终显示在末尾
        types.append(contentsOf: SideMenuType.defaultSideMenuOrder.filter { $0.isFixedOnSideMenu })
        return types
    }
    
    /// 可自定义显示与顺序的侧边栏菜单
    var customizableSideMenuOrder: [SideMenuType] {
        return orderedSideMenuTypes.filter { !$0.isFixedOnSideMenu }
    }
    
    /// 侧边栏显示的菜单
    var displayedSideMenuTypes: [SideMenuType] {
        let hiddenTypes = Set(hiddenSideMenuTypes)
        return orderedSideMenuTypes.filter { $0.isFixedOnSideMenu || !hiddenTypes.contains($0) }
    }
    
    /// 校验后的侧边栏选中菜单（已隐藏的菜单回退到第一个显示的菜单）
    var validatedSideMenuType: SideMenuType {
        let types = displayedSideMenuTypes
        if types.contains(sideMenuType) {
            return sideMenuType
        }
        
        return types.first ?? .myDay
    }
    
    /// 保存侧边栏菜单配置
    func saveSideMenuConfiguration(order: [SideMenuType], hiddenTypes: [SideMenuType]) {
        if sideMenuTypeOrder != order {
            sideMenuTypeOrder = order
        }
        
        if Set(hiddenSideMenuTypes) != Set(hiddenTypes) {
            hiddenSideMenuTypes = hiddenTypes
        }
    }
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: SettingKey) {
        SettingAgent.shared.addObserver(observer, forKey: key.name)
    }
}
