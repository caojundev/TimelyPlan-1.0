//
//  WSCountdownMediumRecentPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/21.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·中·最近。展示距离当前日期最近的三个倒数日事项。
class WSCountdownMediumRecentPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .countdownMediumRecent
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .medium
    }
    
    /// 该组件注册的单元格类
    var cellClass: WSPluginCell.Type {
        return WSCountdownMediumRecentPluginCell.self
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCountdownRecentContentInteractor(plugin: plugin, context: context)
    }
}

// MARK: - 内容交互器

/// 倒数日·中·最近的内容交互器。
///
/// 从活动事项中按与当前日期的远近取前若干个，交给内容视图按行渲染。
class WSCountdownRecentContentInteractor: WSPluginContentInteractor, CountdownEventProcessorDelegate {
    
    /// 最多展示的事项数目，与内容视图的行数保持一致
    static let maximumItemCount = 3
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        CountdownRepository.addUpdater(self)
    }
    
    deinit {
        CountdownRepository.removeUpdater(self)
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let events = Self.recentEvents()
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
    /// 任意事项的变更都可能改变「最近三项」的组成与内容，统一重新取数
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
    /// 画廊预览数据：固定展示三个示例事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [(name: String, emoji: String, colorHex: UInt64, days: Int)] = [
            ("出发去旅行", "✈️", 0x09AFFF, 3),
            ("项目上线", "🚀", 0xFF9F0A, 12),
            ("妈妈生日", "🎂", 0xFF375F, 26)
        ]
        
        let events = examples.compactMap { example -> CountdownEvent? in
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
    private static func recentEvents() -> [CountdownEvent] {
        let events = CountdownRepository.getActiveEvents()
        let sortedEvents = events.sorted { lhs, rhs in
            return lhs.remainingDays < rhs.remainingDays
        }
        
        return Array(sortedEvents.prefix(maximumItemCount))
    }
}
