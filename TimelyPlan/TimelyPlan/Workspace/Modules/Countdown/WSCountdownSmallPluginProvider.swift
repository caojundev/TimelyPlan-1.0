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
    
    /// 该组件注册的单元格类
    var cellClass: WSPluginCell.Type {
        return WSCountdownSmallPluginCell.self
    }
    
    func makeContentInteractor(plugin: WSPlugin) -> WSPluginContentInteractor {
        return WSCountdownContentInteractor(plugin: plugin)
    }
    
    func makeConfigViewController(plugin: WSPlugin) -> WSPluginConfigViewController? {
        return WSCountdownSmalConfigViewController(plugin: plugin)
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
    
    /// 该组件注册的单元格类
    var cellClass: WSPluginCell.Type {
        return WSCountdownMediumPluginCell.self
    }

    func makeContentInteractor(plugin: WSPlugin) -> WSPluginContentInteractor {
        return WSCountdownContentInteractor(plugin: plugin)
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

    /// 该组件注册的单元格类
    var cellClass: WSPluginCell.Type {
        return WSCountdownLargePluginCell.self
    }

    func makeContentInteractor(plugin: WSPlugin) -> WSPluginContentInteractor {
        return WSCountdownContentInteractor(plugin: plugin)
    }
}

class WSCountdownContentInteractor: WSPluginContentInteractor {
    
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let dataItem = WSCountdownDataItem(title: self.plugin.type.displayName)
        completion(dataItem)
    }
}
