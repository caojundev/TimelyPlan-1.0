//
//  CountdownEventListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

/// 倒数日事项布局类型
enum CountdownEventLayoutType: Int, CaseIterable {
    
    /// 列表
    case list = 0
    
    /// 网格
    case grid
    
    /// 切换后的布局类型
    var toggled: CountdownEventLayoutType {
        switch self {
        case .list:
            return .grid
        case .grid:
            return .list
        }
    }
    
    /// 图标（SF Symbol 名称）
    var iconName: String {
        switch self {
        case .list:
            return "list.bullet"
        case .grid:
            return "square.grid.2x2"
        }
    }
}

protocol CountdownEventListViewDelegate: TPGroupCollectionViewDelegate {
    
    /// 通知外部数据源移动数据条目
    func countdownEventListView(_ listView: CountdownEventListView,
                                moveItemAt sourceIndexPath: IndexPath,
                                to targetIndexPath: IndexPath)
    
    /// 处理下拉刷新
    func countdownEventListViewHandleRefresh(_ listView: CountdownEventListView)
}

extension CountdownEventListViewDelegate {
    
    func countdownEventListView(_ listView: CountdownEventListView,
                                moveItemAt sourceIndexPath: IndexPath,
                                to targetIndexPath: IndexPath) {
    }
}

class CountdownEventListView: TPGroupCollectionView,
                              CountdownEventListCellDelegate,
                              CountdownEventGridCellDelegate,
                              TPCollectionDragInsertReorderDelegate {
    
    /// 当前列表所有的倒数日事项
    var events: [CountdownEvent] {
        return adapter.allItems() as? [CountdownEvent] ?? []
    }
    
    var isReorderEnabled: Bool {
        get {
            return self.reorder?.isEnabled ?? false
        }
        
        set {
            self.reorder?.isEnabled = newValue
        }
    }
    
    private var reorder: TPCollectionDragInsertReorder?
    
    private let cellStyle = CountdownEventCellStyle()
    
    private let menuProcessor = CountdownEventMenuProcessor()
    
    /// 布局类型（默认为列表）
    var layoutType: CountdownEventLayoutType = .list {
        didSet {
            if layoutType != oldValue {
                updateSectionLayout()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.setupReorder()
        self.updateSectionLayout()
        if shouldAddRefreshControl() {
            self.addRefreshControl()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shouldAddRefreshControl() -> Bool {
        return true
    }
    
    /// 根据布局类型更新区块布局配置
    private func updateSectionLayout() {
        switch layoutType {
        case .list:
            sectionLayout.minimumItemsCountPerRow = 1
            sectionLayout.maximumItemsCountPerRow = 1
            sectionLayout.preferredItemWidth = CountdownConfig.eventListContentMaxWidth
            sectionLayout.preferredItemHeight = CountdownEventListCell.cellHeight
        case .grid:
            sectionLayout.minimumItemsCountPerRow = 2
            sectionLayout.maximumItemsCountPerRow = 2
            sectionLayout.preferredItemWidth = CountdownConfig.eventGridItemWidth
            sectionLayout.preferredItemHeight = CountdownEventGridCell.Config.cellHeight
        }
        
        sectionLayout.setNeedsLayout()
        collectionViewLayout.invalidateLayout()
        /// 布局类型变化时单元格类型也会变化，需要重新加载
        reloadData()
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        let reorder = TPCollectionDragInsertReorder(collectionView: self.collectionView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = false
        reorder.delegate = self
        self.reorder = reorder
    }
    
    override func handleRefresh() {
        guard let delegate = self.delegate as? CountdownEventListViewDelegate else {
            return
        }
        
        delegate.countdownEventListViewHandleRefresh(self)
    }
    
    // MARK: - AdapterDelegate
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        switch layoutType {
        case .list:
            return CountdownEventListCell.self
        case .grid:
            return CountdownEventGridCell.self
        }
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let event = adapter.item(at: indexPath) as? CountdownEvent
        
        if let cell = cell as? CountdownEventListCell {
            cell.delegate = self
            cell.cellStyle = cellStyle
            cell.event = event
        } else if let cell = cell as? CountdownEventGridCell {
            cell.delegate = self
            cell.cellStyle = cellStyle
            cell.event = event
        }
    }
    
    // MARK: - TPCollectionDragInsertReorderDelegate
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                     canInsertItemTo targetIndexPath: IndexPath,
                                     from sourceIndexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                     inserItemTo targetIndexPath: IndexPath,
                                     from sourceIndexPath: IndexPath,
                                     depth: Int) -> IndexPath? {
        guard let delegate = self.delegate as? CountdownEventListViewDelegate else {
            return sourceIndexPath
        }
        
        delegate.countdownEventListView(self, moveItemAt: sourceIndexPath, to: targetIndexPath)
        adapter.moveItem(at: sourceIndexPath, to: targetIndexPath)
        return targetIndexPath
    }
    
    // MARK: - CountdownEventListCellDelegate
    func countdownEventListCellDidClickMore(_ cell: CountdownEventListCell) {
        guard let event = cell.event else {
            return
        }
        
        showEventMenu(for: event, from: cell.moreButton)
    }
    
    // MARK: - CountdownEventGridCellDelegate
    func countdownEventGridCellDidClickMore(_ cell: CountdownEventGridCell) {
        guard let event = cell.event else {
            return
        }
        
        showEventMenu(for: event, from: cell.moreButton)
    }
    
    /// 弹出事项操作菜单
    private func showEventMenu(for event: CountdownEvent, from view: UIView) {
        let menuController = CountdownEventMenuController(event: event)
        
        menuController.didSelectMenuActionType = { [weak self] type in
            self?.menuProcessor.performMenuAction(type, for: event)
        }
        
        menuController.showMenu(from: view)
    }
}
