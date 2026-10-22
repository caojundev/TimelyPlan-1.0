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

class WSCountdownContentInteractor: WSPluginContentInteractor, CountdownEventProcessorDelegate {
    
    /// 当前展示的倒数日事项
    private var selectedEvent: CountdownEvent?
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        CountdownRepository.addUpdater(self)
    }
    
    deinit {
        CountdownRepository.removeUpdater(self)
    }
    
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
                                   name: resGetString("Trip Departure"),
                                   emoji: "✈️",
                                   colorHex: Color(0x09AFFF).hexString,
                                   date: CountdownDate(targetDate: Date().dateByAddingDays(26) ?? Date()),
                                   timeUnit: .days)
        return WSCountdownDataItem(event: event)
    }
    
    // MARK: - CountdownEventProcessorDelegate
    /// 远程变更：只关心当前展示的事项
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        guard let results = results, isSelectedEventAffected(by: results) else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent, with change: CountdownEventChange) {
        guard event.identifier == selectedEvent?.identifier else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {
        guard event.identifier == selectedEvent?.identifier else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {
        guard event.identifier == selectedEvent?.identifier else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {
        guard event.identifier == selectedEvent?.identifier else {
            return
        }
        
        pluginDataDidChange()
    }
    
    // MARK: - 变更判断
    /// 远程变更是否影响当前展示的事项
    private func isSelectedEventAffected(by results: EntityChangeResults<CountdownEvent>) -> Bool {
        guard let selectedIdentifier = selectedEvent?.identifier else {
            return false
        }
        
        let changedEvents = results.inserted + results.updated
        if changedEvents.contains(where: { $0.identifier == selectedIdentifier }) {
            return true
        }
        
        /// 删除结果只提供对象标识，无法比对事项标识，保守地重新取数
        return !results.deletedObjectIDs.isEmpty
    }
}
