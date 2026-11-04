//
//  WSTodoListRowsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation

// MARK: - 内容交互器

/// 待办清单行组件的内容交互器，各尺寸列表共用。
///
/// 按待办首页的清单顺序读取顶层清单，换算成行数据后下发；
/// 清单增删改或排序变化时重新取数。
class WSTodoListRowsContentInteractor: WSTodoListPluginContentInteractor {
    
    /// 最多展示的清单数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
        
        /// 任务数目变化后行内数值需要刷新
        TodoCountFetcher.shared.addUpdater(self)
    }
    
    // MARK: - 取数
    /// 用户配置的清单标识，按选择顺序排列
    private var selectedIdentifiers: [String] {
        return plugin.configuration(as: WSTodoListSelectedListsConfiguration.self)?.listIdentifiers ?? []
    }
    
    /// 读取待展示的清单。未配置时不展示清单
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let identifiers = Array(selectedIdentifiers.prefix(maximumItemCount))
        guard !identifiers.isEmpty else {
            /// 用户未选择清单时交给空白内容视图
            completion(nil)
            return
        }
        
        /// 一次查询按配置顺序取回全部清单，已删除的清单会被忽略
        TodoRepository.fetchUserLists(of: identifiers) { lists in
            guard let lists = lists, !lists.isEmpty else {
                completion(nil)
                return
            }
            
            let items = lists.map { WSTodoListDataItem(list: $0) }
            completion(WSTodoListRowsDataItem(items: items))
        }
    }
    
    // MARK: - 交互
    /// 点击清单：打开清单详情
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let dataItem = dataItem as? WSTodoListDataItem,
              let list = TodoRepository.getUserList(of: dataItem.listIdentifier) else {
            return
        }
        
        WSTodoListDetailPresenter.showDetail(for: list)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例清单，不受用户数据影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [WSTodoListPreview] = [
            WSTodoListPreview(title: resGetString("Study"),
                            icon: TPIcon(name: "todo_list_24"),
                            colorHex: 0x09AFFF),
            WSTodoListPreview(title: resGetString("Reading"),
                            icon: TPIcon(text: "📚"),
                            colorHex: 0x26B450),
            WSTodoListPreview(title: resGetString("Workout"),
                            icon: TPIcon(name: "todo_board_24"),
                            colorHex: 0xFCB100),
            WSTodoListPreview(title: resGetString("Annual Plan"),
                            icon: TPIcon(name: "todo_list_24"),
                            colorHex: 0x8C36FF),
            WSTodoListPreview(title: resGetString("Family Trip"),
                            icon: TPIcon(text: "✈️"),
                            colorHex: 0xFD2504),
            WSTodoListPreview(title: resGetString("Home"),
                            icon: TPIcon(name: "todo_list_24"),
                            colorHex: 0x26B450)
        ]
        
        let items = examples.prefix(maximumItemCount).map { example in
            return WSTodoListDataItem(previewIdentifier: "preview.\(example.title)",
                                      title: example.title,
                                      icon: example.icon,
                                      color: Color(example.colorHex))
        }
        
        return WSTodoListRowsDataItem(items: items)
    }
}

// MARK: - TodoCountFetcherDelegate

extension WSTodoListRowsContentInteractor: TodoCountFetcherDelegate {
    
    /// 数目变化后重新取数，行视图随之刷新任务数目
    func todoCountFetcher(_ fetcher: TodoCountFetcher, didChangeCountsFor identifiers: Set<String>?) {
        /// 范围未知，或涉及当前展示的清单时才刷新
        guard let identifiers = identifiers else {
            pluginDataDidChange()
            return
        }
        
        let items = (dataItem as? WSTodoListRowsDataItem)?.items ?? []
        let displayedIdentifiers = Set(items.map { $0.listIdentifier })
        guard !displayedIdentifiers.isDisjoint(with: identifiers) else {
            return
        }
        
        pluginDataDidChange()
    }
}

// MARK: - 预览示例

/// 画廊预览使用的示例清单。
private struct WSTodoListPreview {
    
    /// 示例名称
    let title: String
    
    /// 示例图标
    let icon: TPIcon
    
    /// 示例颜色
    let colorHex: UInt64
}
