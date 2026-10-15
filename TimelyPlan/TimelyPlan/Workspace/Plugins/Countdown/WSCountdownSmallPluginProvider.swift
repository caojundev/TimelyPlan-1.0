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
    
    /// 显示名称
    var displayName: String = "倒数日（小尺寸）"
}


class WSCountdownMediumPluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .countdownMedium
    }
    
    /// 显示名称
    var displayName: String = "倒数日（中尺寸）"

}

class WSCountdownLargePluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .countdownLarge
    }
    
    /// 显示名称
    var displayName: String = "倒数日（大尺寸）"

}
