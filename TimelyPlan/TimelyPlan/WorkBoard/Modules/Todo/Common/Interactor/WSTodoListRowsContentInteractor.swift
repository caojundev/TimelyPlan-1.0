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
    }
    
    // MARK: - 取数
    /// 读取顶层清单，取前若干个
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let lists = Array((TodoRepository.getTopLists() ?? []).prefix(maximumItemCount))
        guard !lists.isEmpty else {
            /// 没有可展示的清单时交给空白内容视图
            completion(nil)
            return
        }
        
        let items = lists.map { WSTodoListDataItem(list: $0) }
        completion(WSTodoListRowsDataItem(items: items))
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
            return WSTodoListDataItem(listIdentifier: "preview.\(example.title)",
                                    title: example.title,
                                    icon: example.icon,
                                    color: Color(example.colorHex))
        }
        
        return WSTodoListRowsDataItem(items: items)
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
