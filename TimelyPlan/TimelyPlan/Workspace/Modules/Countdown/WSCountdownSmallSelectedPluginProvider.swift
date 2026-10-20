//
//  WSCountdownSmallSelectedPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

/// 倒数日·小·自选。展示用户自己选择的一个倒数日事件。
class WSCountdownSmallSelectedPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .countdownSmallSelected
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .small
    }
    
    /// 该组件注册的单元格类
    var cellClass: WSPluginCell.Type {
        return WSCountdownSmallSelectedPluginCell.self
    }
    
    func makeContentInteractor(plugin: WSPlugin) -> WSPluginContentInteractor {
        return WSCountdownContentInteractor(plugin: plugin)
    }
    
    func makeConfigViewController(plugin: WSPlugin) -> WSPluginConfigViewController? {
        return WSCountdownSmallSelectedConfigViewController(plugin: plugin)
    }
}

class WSCountdownContentInteractor: WSPluginContentInteractor {
    
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        /// TODO: 接入用户选中的倒数日事项，目前使用测试数据验证组件展示效果
        let event = CountdownEvent(type: .countdown,
                                   name: "出发去旅行",
                                   emoji: "✈️",
                                   colorHex: Color(0x09AFFF).hexString,
                                   date: CountdownDate(targetDate: Date().dateByAddingDays(26) ?? Date()),
                                   timeUnit: .days)
        completion(WSCountdownDataItem(event: event))
    }
}
