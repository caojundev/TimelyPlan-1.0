//
//  TPMenuListView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/25.
//

import Foundation
import UIKit

class TPMenuListView: TPTableWrapperView,
                        TPTableViewAdapterDataSource,
                        TPTableViewAdapterDelegate {
    
    /// 标题字体
    var titleFont: UIFont = BOLD_SYSTEM_FONT
    
    /// 选中菜单动作回调
    var didSelectMenuAction: ((TPMenuAction) -> Void)?
    
    /// 菜单内容宽度
    var menuContentWidth: CGFloat = 200.0

    /// 菜单内容最大高度
    var maxMenuContentHeight: CGFloat = 600.0

    /// 菜单条目数组
    var menuItems: [TPMenuItem]?

    init() {
        super.init(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        adapter.cellStyle.backgroundColor = .clear
        adapter.dataSource = self
        adapter.delegate = self
        adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - dataSource
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        return menuItems
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let menuItem = sectionObject as! TPMenuItem
        return menuItem.actions
    }
    
    // MARK: - Delegate
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TPMenuListActionCell.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! TPMenuListActionCell
        let menuAction = adapter.item(at: indexPath) as! TPMenuAction
        cell.menuAction = menuAction
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 1.0
        }
        
        return 0.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        if section > 0 {
            return TPSeparatorTableHeaderFooterView.self
        }
        
        return nil
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        if let headerView = headerView as? TPSeparatorTableHeaderFooterView {
            headerView.lineColor = Color(light: 0xDEDEDE, 1.0, dark: 0x232323, 0.6)
        }
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let action = adapter.item(at: indexPath) as! TPMenuAction
        didSelectMenuAction?(action)
    }
}
