//
//  WSCountdownSmallPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation

class WSCountdownSmallPluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .countdownSmall
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .small
    }
    
    /// 显示名称
    var displayName: String = "倒数日（小尺寸）"
    
    /// 该组件注册的单元格类
    var cellClass: WorkspacePluginCell.Type {
        return WSCountdownPluginCell.self
    }
}


class WSCountdownMediumPluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .countdownMedium
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .medium
    }
    
    /// 显示名称
    var displayName: String = "倒数日（中尺寸）"
    
    /// 该组件注册的单元格类
    var cellClass: WorkspacePluginCell.Type {
        return WSCountdownPluginCell.self
    }

}

class WSCountdownLargePluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .countdownLarge
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .large
    }
    
    /// 显示名称
    var displayName: String = "倒数日（大尺寸）"
    
    /// 该组件注册的单元格类
    var cellClass: WorkspacePluginCell.Type {
        return WSCountdownPluginCell.self
    }

}
