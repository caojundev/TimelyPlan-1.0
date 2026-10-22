//
//  WSCountdownRecentContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 内容交互器

/// 倒数日「最近」的内容交互器。
///
/// 从活动事项中按与当前日期的远近取前若干个，交给内容视图按行渲染。
/// 取数条数由初始化时传入，供中号、大号组件按尺寸复用。
class WSCountdownRecentContentInteractor: WSPluginContentInteractor, CountdownEventProcessorDelegate {
    
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
        let events = recentEvents()
        guard !events.isEmpty else {
            completion(nil)
            return
        }
        
        completion(WSCountdownRecentDataItem(events: events))
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
    
    // MARK: - CountdownEventProcessorDelegate
    /// 任意事项的变更都可能改变「最近若干项」的组成与内容，统一重新取数
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
    /// 画廊预览数据：固定展示示例事项，不受用户数据影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [(name: String, emoji: String, colorHex: UInt64, days: Int)] = [
            (resGetString("Trip Departure"), "✈️", 0x09AFFF, 3),
            (resGetString("Project Launch"), "🚀", 0xFF9F0A, 12),
            (resGetString("Mom's Birthday"), "🎂", 0xFF375F, 26),
            (resGetString("Anniversary"), "💍", 0xAF52DE, 42),
            (resGetString("Driving Test"), "🚗", 0x30D158, 68)
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
        
        return WSCountdownRecentDataItem(events: events)
    }
    
    // MARK: - 最近事项
    /// 最近的倒数日事项：按与当前日期的天数差升序，最多取 `maximumItemCount` 条
    private func recentEvents() -> [CountdownEvent] {
        let events = CountdownRepository.getActiveEvents()
        let sortedEvents = events.sorted { lhs, rhs in
            return lhs.remainingDays < rhs.remainingDays
        }
        
        return Array(sortedEvents.prefix(maximumItemCount))
    }
}
