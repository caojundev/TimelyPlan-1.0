//
//  WSCountdownEventsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 内容交互器

/// 倒数日「事项」的内容交互器。
///
/// 展示内容由插件配置决定：默认取距离当前日期最近的若干个事项，
/// 也可展示用户在配置中选择的事项。取数条数由初始化时传入，供各尺寸组件复用。
class WSCountdownEventsContentInteractor: WSPluginContentInteractor, CountdownEventProcessorDelegate {
    
    /// 最多展示的事项数目，与内容视图的行数保持一致
    private let maximumItemCount: Int
    
    /// 初始化交互器
    /// - Parameter maximumItemCount: 最多展示的事项数目
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
        CountdownRepository.addUpdater(self)
    }
    
    deinit {
        CountdownRepository.removeUpdater(self)
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let events = displayedEvents()
        guard !events.isEmpty else {
            completion(nil)
            return
        }
        
        completion(WSCountdownEventsDataItem(events: events))
    }
    
    // MARK: - 条目操作
    /// 点击某一行时，打开该行对应的事项详情。
    ///
    /// 组件内以行内点击为准，不额外处理整格点击，避免与行点击重复响应。
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let dataItem = dataItem as? WSCountdownDataItem,
              let event = CountdownRepository.getEvent(withIdentifier: dataItem.eventIdentifier) else {
            return
        }
        
        CountdownPresenter.showDetail(for: event)
    }
    
    /// 点击空白行
    override func performEmptyRowAction() {
        /// 创建新事项
        CountdownPresenter.createNewEvent()
    }
    
    // MARK: - CountdownEventProcessorDelegate
    /// 任意事项的变更都可能改变展示内容，统一重新取数
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        guard results?.hasChanges == true else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didCreateCountdownEvent(_ event: CountdownEvent) {
        pluginDataDidChange()
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent, with change: CountdownEventChange) {
        pluginDataDidChange()
    }
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {
        pluginDataDidChange()
    }
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {
        pluginDataDidChange()
    }
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {
        pluginDataDidChange()
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示示例事项，不受用户数据与配置影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [(name: String, emoji: String, colorHex: UInt64, days: Int)] = [
            (resGetString("Trip Departure"), "✈️", 0x09AFFF, 3),
            (resGetString("Project Launch"), "🚀", 0xFF9F0A, 12),
            (resGetString("Mom's Birthday"), "🎂", 0xFF375F, 26),
            (resGetString("Anniversary"), "💍", 0xAF52DE, 42),
            (resGetString("Driving Test"), "🚗", 0x30D158, 68),
            (resGetString("Family Trip"), "🏖️", 0xFF6482, 95),
            (resGetString("New Semester"), "📚", 0x64D2FF, 120),
            (resGetString("Graduation"), "🎓", 0xBF5AF2, 180)
        ]
        
        let events = examples.prefix(maximumItemCount).compactMap { example -> CountdownEvent? in
            guard let date = Date().dateByAddingDays(example.days) else {
                return nil
            }
            
            return CountdownEvent(type: .countdown,
                                  name: example.name,
                                  emoji: example.emoji,
                                  colorHex: Color(example.colorHex).hexString,
                                  date: CountdownDate(targetDate: date),
                                  timeUnit: .days)
        }
        
        return WSCountdownEventsDataItem(events: events)
    }
    
    // MARK: - 展示事项
    /// 按配置决定展示内容。未写入配置时默认展示最近事项
    private func displayedEvents() -> [CountdownEvent] {
        let configuration = plugin.configuration(as: WSCountdownEventsConfiguration.self)
        
        switch configuration?.source ?? .recent {
        case .recent:
            return recentEvents(eventType: configuration?.eventType)
        case .selected:
            return selectedEvents(identifiers: configuration?.eventIdentifiers ?? [])
        }
    }
    
    /// 最近的倒数日事项：按与当前日期的天数差升序，最多取 `maximumItemCount` 条
    /// - Parameter eventType: 事项类型。为 nil 时不限类型
    private func recentEvents(eventType: CountdownEventType?) -> [CountdownEvent] {
        let events = CountdownRepository.getActiveEvents()
        let filteredEvents = events.filter { event in
            guard let eventType = eventType else {
                return true
            }
            
            return event.type == eventType
        }
        
        let sortedEvents = filteredEvents.sorted { lhs, rhs in
            return lhs.remainingDays < rhs.remainingDays
        }
        
        return Array(sortedEvents.prefix(maximumItemCount))
    }
    
    /// 用户自选的事项：按用户选择的顺序展示，最多取 `maximumItemCount` 条
    private func selectedEvents(identifiers: [String]) -> [CountdownEvent] {
        let events = CountdownRepository.getEvents(withIdentifiers: identifiers)
        return Array(events.prefix(maximumItemCount))
    }
}
