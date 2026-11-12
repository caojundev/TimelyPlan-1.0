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
    
    /// 菜单标题
    var title: String {
        switch self {
        case .addPreviousPlugin:
            return resGetString("Add Previous Plugin")
        case .addNextPlugin:
            return resGetString("Add Next Plugin")
        case .configPlugin:
            return resGetString("Config Plugin")
        case .removePlugin:
            return resGetString("Remove Plugin")
        }
    }
    
    /// 菜单图标
    var iconImage: UIImage? {
        switch self {
        case .addPreviousPlugin:
            return UIImage(systemName: "arrow.up.square")
        case .addNextPlugin:
            return UIImage(systemName: "arrow.down.square")
        case .configPlugin:
            return UIImage(systemName: "slider.horizontal.3")
        case .removePlugin:
            return UIImage(systemName: "trash")
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
