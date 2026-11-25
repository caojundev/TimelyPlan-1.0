//
//  WSPluginMenuActionType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import UIKit

/// 工作台组件菜单动作
enum WSPluginMenuActionType: Int, CaseIterable, TPMenuRepresentable {
    case addPreviousPlugin /// 添加上一个插件
    case addNextPlugin     /// 添加下一个插件
    case configPlugin      /// 配置插件
    case removePlugin      /// 移除插件
    
    /// 菜单标题。工具栏按钮宽度有限，文案需保持简短
    var title: String {
        switch self {
        case .addPreviousPlugin:
            return resGetString("Add Above")
        case .addNextPlugin:
            return resGetString("Add Below")
        case .configPlugin:
            return resGetString("Config Plugin")
        case .removePlugin:
            return resGetString("Remove Plugin")
        }
    }
    
    /// 菜单图标名称
    var iconName: String? {
        switch self {
        case .addPreviousPlugin:
            return "plugin_action_addPrevious_24"
        case .addNextPlugin:
            return "plugin_action_addNext_24"
        case .configPlugin:
            return "plugin_action_config_24"
        case .removePlugin:
            return "plugin_action_trash_24"
        }
    }
    
    /// 菜单动作样式
    var actionStyle: TPMenuActionStyle {
        switch self {
        case .removePlugin:
            return .destructive
        default:
            return .normal
        }
    }
}
