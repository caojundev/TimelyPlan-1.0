//
//  WSTodoFilterRowsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation

// MARK: - 内容交互器

/// 待办过滤器行组件的内容交互器，各尺寸列表与网格共用。
///
/// 按配置读取过滤器，换算成行数据后下发；过滤器增删改或排序变化时重新取数。
class WSTodoFilterRowsContentInteractor: WSTodoFilterPluginContentInteractor {
    
    /// 最多展示的过滤器数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
        
        /// 任务数目变化后行内数值需要刷新
        TodoCountFetcher.shared.addUpdater(self)
    }
    
    // MARK: - 取数
    /// 用户配置的过滤器标识，按选择顺序排列
    private var selectedIdentifiers: [String] {
        return plugin.configuration(as: WSTodoFilterSelectedFiltersConfiguration.self)?.filterIdentifiers ?? []
    }
    
    /// 读取待展示的过滤器。未配置时不展示过滤器
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let identifiers = Array(selectedIdentifiers.prefix(maximumItemCount))
        guard !identifiers.isEmpty else {
            /// 用户未选择过滤器时交给空白内容视图
            completion(nil)
            return
        }
        
        /// 一次查询按配置顺序取回全部过滤器，已删除的过滤器会被忽略
        TodoRepository.fetchFilters(of: identifiers) { filters in
            guard let filters = filters, !filters.isEmpty else {
                completion(nil)
                return
            }
            
            let items = filters.map { WSTodoFilterDataItem(filter: $0) }
            completion(WSTodoFilterRowsDataItem(items: items))
        }
    }
    
    // MARK: - 交互
    /// 点击过滤器：打开过滤器详情
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let dataItem = dataItem as? WSTodoFilterDataItem,
              let filter = TodoRepository.getFilter(of: dataItem.filterIdentifier) else {
            return
        }
        
        WSTodoFilterDetailPresenter.showDetail(for: filter)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例过滤器，不受用户数据影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [WSTodoFilterPreview] = [
            WSTodoFilterPreview(title: resGetString("Study"), colorIndex: 0),
            WSTodoFilterPreview(title: resGetString("Reading"), colorIndex: 1),
            WSTodoFilterPreview(title: resGetString("Workout"), colorIndex: 2),
            WSTodoFilterPreview(title: resGetString("Annual Plan"), colorIndex: 3),
            WSTodoFilterPreview(title: resGetString("Family Trip"), colorIndex: 4),
            WSTodoFilterPreview(title: resGetString("Home"), colorIndex: 5),
            WSTodoFilterPreview(title: resGetString("Project Launch"), colorIndex: 6),
            WSTodoFilterPreview(title: resGetString("Trip Departure"), colorIndex: 7)
        ]
        
        let items = examples.prefix(maximumItemCount).map { example in
            return WSTodoFilterDataItem(previewIdentifier: "preview.\(example.title)",
                                        title: example.title,
                                        color: TodoFilter.colors[example.colorIndex])
        }
        
        return WSTodoFilterRowsDataItem(items: items)
    }
}

// MARK: - TodoCountFetcherDelegate

extension WSTodoFilterRowsContentInteractor: TodoCountFetcherDelegate {
    
    /// 数目变化后重新取数，行视图随之刷新任务数目
    func todoCountFetcher(_ fetcher: TodoCountFetcher, didChangeCountsFor identifiers: Set<String>?) {
        /// 范围未知，或涉及当前展示的过滤器时才刷新
        guard let identifiers = identifiers else {
            pluginDataDidChange()
            return
        }
        
        let items = (dataItem as? WSTodoFilterRowsDataItem)?.items ?? []
        let displayedIdentifiers = Set(items.map { $0.filterIdentifier })
        guard !displayedIdentifiers.isDisjoint(with: identifiers) else {
            return
        }
        
        pluginDataDidChange()
    }
}

// MARK: - 预览示例

/// 画廊预览使用的示例过滤器。
private struct WSTodoFilterPreview {
    
    /// 示例名称
    let title: String
    
    /// 示例颜色在 `TodoFilter.colors` 中的索引
    let colorIndex: Int
}
