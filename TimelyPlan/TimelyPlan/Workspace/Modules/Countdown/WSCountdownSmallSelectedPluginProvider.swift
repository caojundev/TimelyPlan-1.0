//
//  WSCountdownSmallSelectedPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

// MARK: - 配置

/// 倒数日·小·自选的配置
struct WSCountdownSelectedConfiguration: Codable {
    
    /// 用户选择的倒数日事项标识
    var eventIdentifier: String?
}

// MARK: - 组件提供者

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
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCountdownContentInteractor(plugin: plugin, context: context)
    }
    
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSCountdownSmallSelectedConfigViewController(plugin: plugin)
    }
}

// MARK: - 内容交互器

class WSCountdownContentInteractor: WSPluginContentInteractor {
    
    /// 当前展示的倒数日事项
    private var selectedEvent: CountdownEvent?
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard let configuration = plugin.configuration(as: WSCountdownSelectedConfiguration.self),
              let eventIdentifier = configuration.eventIdentifier,
              let event = CountdownRepository.getEvent(withIdentifier: eventIdentifier) else {
            selectedEvent = nil
            completion(nil)
            return
        }
        
        selectedEvent = event
        completion(WSCountdownDataItem(event: event))
    }
    
    // MARK: - 主操作
    override func performPrimaryAction() {
        guard let selectedEvent = selectedEvent,
              let event = CountdownRepository.getEvent(withIdentifier: selectedEvent.identifier) else {
            return
        }
        
        CountdownPresenter.showDetail(for: event)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一个示例事项，不受用户配置影响
    override func previewDataItem() -> WSPluginDataItem? {
        let event = CountdownEvent(type: .countdown,
                                   name: "出发去旅行",
                                   emoji: "✈️",
                                   colorHex: Color(0x09AFFF).hexString,
                                   date: CountdownDate(targetDate: Date().dateByAddingDays(26) ?? Date()),
                                   timeUnit: .days)
        return WSCountdownDataItem(event: event)
    }
}
