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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.preferredItemWidth = CountdownConfig.eventListContentMaxWidth
        self.preferredItemHeight = CountdownEventListCell.cellHeight
        self.setupReorder()
        self.addRefreshControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        return CountdownEventListCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CountdownEventListCell else {
            return
        }
        
        let event = adapter.item(at: indexPath) as? CountdownEvent
        cell.delegate = self
        cell.cellStyle = cellStyle
        cell.event = event
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
        
        let menuController = CountdownEventMenuController(event: event)
        
        menuController.didSelectMenuActionType = { [weak self] type in
            self?.menuProcessor.performMenuAction(type, for: event)
        }
        
        menuController.showMenu(from: cell.moreButton)
    }
}
