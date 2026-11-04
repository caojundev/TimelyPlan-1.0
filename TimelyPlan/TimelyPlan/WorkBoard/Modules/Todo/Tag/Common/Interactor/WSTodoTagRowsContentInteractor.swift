//
//  WSTodoTagRowsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation

// MARK: - 内容交互器

/// 待办标签行组件的内容交互器，各尺寸列表与网格共用。
///
/// 按配置读取标签，换算成行数据后下发；标签增删改或排序变化时重新取数。
class WSTodoTagRowsContentInteractor: WSTodoTagPluginContentInteractor {
    
    /// 最多展示的标签数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
        
        /// 任务数目变化后行内数值需要刷新
        TodoCountFetcher.shared.addUpdater(self)
    }
    
    // MARK: - 取数
    /// 用户配置的标签标识，按选择顺序排列
    private var selectedIdentifiers: [String] {
        return plugin.configuration(as: WSTodoTagSelectedTagsConfiguration.self)?.tagIdentifiers ?? []
    }
    
    /// 读取待展示的标签。未配置时不展示标签
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let identifiers = Array(selectedIdentifiers.prefix(maximumItemCount))
        guard !identifiers.isEmpty else {
            /// 用户未选择标签时交给空白内容视图
            completion(nil)
            return
        }
        
        /// 一次查询按配置顺序取回全部标签，已删除的标签会被忽略
        TodoRepository.fetchTags(of: identifiers) { tags in
            guard let tags = tags, !tags.isEmpty else {
                completion(nil)
                return
            }
            
            let items = tags.map { WSTodoTagDataItem(tag: $0) }
            completion(WSTodoTagRowsDataItem(items: items))
        }
    }
    
    // MARK: - 交互
    /// 点击标签：打开标签详情
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let dataItem = dataItem as? WSTodoTagDataItem,
              let tag = TodoRepository.getTag(with: dataItem.tagIdentifier) else {
            return
        }
        
        WSTodoTagDetailPresenter.showDetail(for: tag)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例标签，不受用户数据影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [WSTodoTagPreview] = [
            WSTodoTagPreview(title: resGetString("Study"), colorIndex: 0),
            WSTodoTagPreview(title: resGetString("Reading"), colorIndex: 1),
            WSTodoTagPreview(title: resGetString("Workout"), colorIndex: 2),
            WSTodoTagPreview(title: resGetString("Annual Plan"), colorIndex: 3),
            WSTodoTagPreview(title: resGetString("Family Trip"), colorIndex: 4),
            WSTodoTagPreview(title: resGetString("Home"), colorIndex: 5),
            WSTodoTagPreview(title: resGetString("Project Launch"), colorIndex: 6)
        ]
        
        let items = examples.prefix(maximumItemCount).map { example in
            return WSTodoTagDataItem(previewIdentifier: "preview.\(example.title)",
                                     title: example.title,
                                     color: TodoTag.colors[example.colorIndex])
        }
        
        return WSTodoTagRowsDataItem(items: items)
    }
}

// MARK: - TodoCountFetcherDelegate

extension WSTodoTagRowsContentInteractor: TodoCountFetcherDelegate {
    
    /// 数目变化后重新取数，行视图随之刷新任务数目
    func todoCountFetcher(_ fetcher: TodoCountFetcher, didChangeCountsFor identifiers: Set<String>?) {
        /// 范围未知，或涉及当前展示的标签时才刷新
        guard let identifiers = identifiers else {
            pluginDataDidChange()
            return
        }
        
        let items = (dataItem as? WSTodoTagRowsDataItem)?.items ?? []
        let displayedIdentifiers = Set(items.map { $0.tagIdentifier })
        guard !displayedIdentifiers.isDisjoint(with: identifiers) else {
            return
        }
        
        pluginDataDidChange()
    }
}

// MARK: - 预览示例

/// 画廊预览使用的示例标签。
private struct WSTodoTagPreview {
    
    /// 示例名称
    let title: String
    
    /// 示例颜色在 `TodoTag.colors` 中的索引
    let colorIndex: Int
}
