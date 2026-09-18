//
//  CountdownEventListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

protocol CountdownEventListViewDelegate: TPGroupCollectionViewDelegate {
    
    /// 通知外部数据源移动数据条目
    func countdownEventListView(_ listView: CountdownEventListView,
                                moveItemAt sourceIndexPath: IndexPath,
                                to targetIndexPath: IndexPath) -> Bool
    
    func countdownEventListViewDidEndReordering(_ listView: CountdownEventListView)
    
    /// 处理下拉刷新
    func countdownEventListViewHandleRefresh(_ listView: CountdownEventListView)
    
}

extension CountdownEventListViewDelegate {
    
    func countdownEventListView(_ listView: CountdownEventListView,
                                moveItemAt sourceIndexPath: IndexPath,
                                to targetIndexPath: IndexPath) -> Bool {
        return false
    }
    
    func countdownEventListViewDidEndReordering(_ listView: CountdownEventListView) {}
}

class CountdownEventListView: TPGroupCollectionView,
                              CountdownEventListCellDelegate,
                              CountdownEventGridCellDelegate {
    
    /// 当前列表所有的倒数日事项
    var events: [CountdownEvent] {
        return adapter.allItems() as? [CountdownEvent] ?? []
    }
    
    var isReorderEnabled: Bool = true {
        didSet {
            reorder?.isEnabled = isReorderEnabled
        }
    }
    
    private var reorder: TPCollectionDragReorder?
    
    private let cellStyle = CountdownEventCellStyle()
    
    private let menuProcessor = CountdownEventMenuProcessor()
    
    /// 布局类型（默认为列表）
    var layoutType: CountdownLayoutType = .list {
        didSet {
            if layoutType != oldValue {
                setupReorder()
                updateSectionLayout()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        if shouldAddRefreshControl() {
            self.addRefreshControl()
        }
        
        self.setupReorder()
        self.updateSectionLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func performUpdate(with completion: ((Bool) -> Void)? = nil) {
        reorder?.stopReordering()
        super.performUpdate(with: completion)
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
            sectionLayout.maximumItemsCountPerRow = 4
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
        self.reorder?.clear()
        self.reorder = nil

        let reorder: TPCollectionDragReorder
        if layoutType == .list {
            let insertReorder = TPCollectionDragInsertReorder(collectionView: collectionView)
            insertReorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
            reorder = insertReorder
        } else {
            let exchangeReorder = TPCollectionDragExchangeReorder(collectionView: collectionView)
            reorder = exchangeReorder
        }
        
        reorder.isEnabled = isReorderEnabled
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

extension CountdownEventListView: TPCollectionDragInsertReorderDelegate,
                                  TPCollectionDragExchangeReorderDelegate {
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isReorderEnabled
    }
    
    func collectionDragReorderDidEnd(_ reorder: TPCollectionDragReorder) {
        if let delegate = self.delegate as? CountdownEventListViewDelegate {
            delegate.countdownEventListViewDidEndReordering(self)
        }
    }
    
    // MARK: - TPCollectionDragExchangeReorderDelegate
    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder, canMoveItemFrom fromIndexPath: IndexPath, to toIndexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder, moveItemFrom fromIndexPath: IndexPath, to toIndexPath: IndexPath) -> Bool {
        guard let delegate = self.delegate as? CountdownEventListViewDelegate else {
            return false
        }
        
        let bMoved = delegate.countdownEventListView(self, moveItemAt: fromIndexPath, to: toIndexPath)
        if bMoved {
            adapter.moveItem(at: fromIndexPath, to: toIndexPath)
            return true
        }
    
        return false
    }
    
    // MARK: - TPCollectionDragInsertReorderDelegate
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
        
        let bMoved = delegate.countdownEventListView(self, moveItemAt: sourceIndexPath, to: targetIndexPath)
        if bMoved {
            adapter.moveItem(at: sourceIndexPath, to: targetIndexPath)
            return targetIndexPath
        }
        
        return sourceIndexPath
    }
}
