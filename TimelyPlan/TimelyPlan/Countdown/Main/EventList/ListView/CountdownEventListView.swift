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
    
    /// 处理下拉刷新
    func countdownEventListViewHandleRefresh(_ listView: CountdownEventListView)
    
}

extension CountdownEventListViewDelegate {
    
    func countdownEventListView(_ listView: CountdownEventListView,
                                moveItemAt sourceIndexPath: IndexPath,
                                to targetIndexPath: IndexPath) -> Bool {
        return false
    }
}

class CountdownEventListView: TPGroupCollectionView,
                              CountdownEventListCellDelegate {
    
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
    
    /// 更新区块布局配置
    private func updateSectionLayout() {
        sectionLayout.minimumItemsCountPerRow = 1
        sectionLayout.maximumItemsCountPerRow = 1
        sectionLayout.preferredItemWidth = CountdownConfig.eventListContentMaxWidth
        sectionLayout.preferredItemHeight = CountdownEventListCell.cellHeight
        
        sectionLayout.setNeedsLayout()
        collectionViewLayout.invalidateLayout()
        reloadData()
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        self.reorder?.clear()
        self.reorder = nil
        
        let insertReorder = TPCollectionDragInsertReorder(collectionView: collectionView)
        insertReorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        insertReorder.isEnabled = isReorderEnabled
        insertReorder.delegate = self
        self.reorder = insertReorder
    }
    
    override func handleRefresh() {
        guard let delegate = self.delegate as? CountdownEventListViewDelegate else {
            return
        }
        
        delegate.countdownEventListViewHandleRefresh(self)
    }
    
    // MARK: - AdapterDelegate
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CountdownEventListCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let event = adapter.item(at: indexPath) as? CountdownEvent
        
        if let cell = cell as? CountdownEventListCell {
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
    
    /// 弹出事项操作菜单
    private func showEventMenu(for event: CountdownEvent, from view: UIView) {
        let menuController = CountdownEventMenuController(event: event)
        
        menuController.didSelectMenuActionType = { [weak self] type in
            self?.menuProcessor.performMenuAction(type, for: event)
        }
        
        menuController.showMenu(from: view)
    }
}

extension CountdownEventListView: TPCollectionDragInsertReorderDelegate {
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isReorderEnabled
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
