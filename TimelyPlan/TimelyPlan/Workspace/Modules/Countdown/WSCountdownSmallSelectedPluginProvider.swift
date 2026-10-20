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
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCountdownContentInteractor(plugin: plugin, context: context)
    }
    
    func makeConfigViewController(plugin: WSPlugin) -> WSPluginConfigViewController? {
        return WSCountdownSmallSelectedConfigViewController(plugin: plugin)
    }
}

class WSCountdownContentInteractor: WSPluginContentInteractor {
    
    /// 当前展示的倒数日事项
    private var selectedEvent: CountdownEvent?
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard let event = makeSelectedEvent() else {
            selectedEvent = nil
            completion(nil)
            return
        }
        
        selectedEvent = event
        completion(WSCountdownDataItem(event: event))
    }
    
    // MARK: - 主操作
    override func performPrimaryAction() {
        guard let selectedEvent = selectedEvent else {
            return
        }
        
//        /// TODO: 接入配置后应只使用仓库中的事项（事项已删除时不响应）；
//        /// 当前测试数据尚未落库，取不到时回退到本地事项以便验证点击效果
//        let event = CountdownRepository.getEvent(withIdentifier: selectedEvent.identifier) ?? selectedEvent
//        CountdownPresenter.showDetail(for: event)
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
    
    // MARK: - 事项
    /// 用户选中的倒数日事项
    ///
    /// TODO: 从 `plugin.configJSON` 解析用户选择的事项标识，目前使用测试数据验证展示与点击
    private func makeSelectedEvent() -> CountdownEvent? {
        return nil
        
//        
//        CountdownEvent(type: .countdown,
//                              name: "出发去旅行",
//                              emoji: "✈️",
//                              colorHex: Color(0x09AFFF).hexString,
//                              date: CountdownDate(targetDate: Date().dateByAddingDays(26) ?? Date()),
//                              timeUnit: .days)
    }
}
