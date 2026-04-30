//
//  FocusUserTimerListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/23.
//

import Foundation
import UIKit

protocol FocusUserTimerListViewDelegate: TPGroupCollectionViewDelegate {
        
    /// 通知外部数据源移动数据条目
    func focusUserTimerListView(_ listView: FocusUserTimerListView,
                                moveItemAt sourceIndexPath: IndexPath,
                                to targetIndexPath: IndexPath)
    
    /// 处理下拉刷新
    func focusUserTimerListViewHandleRefresh(_ listView: FocusUserTimerListView)
}

extension FocusUserTimerListViewDelegate {
    
    func focusUserTimerListView(_ listView: FocusUserTimerListView,
                                moveItemAt sourceIndexPath: IndexPath,
                                to targetIndexPath: IndexPath) {
    }
}

class FocusUserTimerListView: TPGroupCollectionView,
                              FocusUserTimerListCellDelegate,
                              TPCollectionDragInsertReorderDelegate {
    
    /// 当前列表所有的用户计时器
    var userTimers: [FocusTimer] {
        return adapter.allItems() as? [FocusTimer] ?? []
    }
    
    var isDisplaying: Bool = true {
        didSet {
            updateFocusingIndicator()
        }
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
    
    private let cellStyle = FocusUserTimerCellStyle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.preferredItemWidth = kFocusTimerListContentMaxWidth
        self.preferredItemHeight = 70.0
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
        guard let delegate = self.delegate as? FocusUserTimerListViewDelegate else {
            return
        }
        
        delegate.focusUserTimerListViewHandleRefresh(self)
    }
    
    func updateFocusingIndicator() {
        guard let visibleCells = adapter.visibleCells as? [FocusHomeUserTimerCell] else {
            return
        }
        
        guard isDisplaying,
                let focusingTimerId = FocusTracker.shared.eventTimerFeature?.identifier,
                !FocusSystemTimerIdentifier.contains(focusingTimerId),
                FocusTracker.shared.state != .waiting else {
            visibleCells.forEach { cell in
                cell.isFocusing = false
            }
            
            return
        }

        /// 检查计时器
        for cell in visibleCells {
            var isFocusing = false
            if let timerId = cell.timer?.identifier, timerId == focusingTimerId {
                isFocusing = true
            }
            
            cell.isFocusing = isFocusing
        }
    }
    
    private func isFocusing(of timer: FocusTimer) -> Bool {
        guard isDisplaying,
                let focusingTimerId = FocusTracker.shared.eventTimerFeature?.identifier,
                FocusTracker.shared.state != .waiting else {
            return false
        }
        
        var isFocusing = false
        if timer.identifier == focusingTimerId {
            isFocusing = true
        }
        
        return isFocusing
    }

    // MARK: - AdapterDelegate
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return FocusHomeUserTimerCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? FocusHomeUserTimerCell else {
            return
        }
        
        let timer = adapter.item(at: indexPath) as? FocusTimer
        cell.delegate = self
        cell.cellStyle = cellStyle
        cell.timer = timer
        
        if let timer = timer {
            cell.isFocusing = isFocusing(of: timer)
        } else {
            cell.isFocusing = false
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
        guard let delegate = self.delegate as? FocusUserTimerListViewDelegate else {
            return sourceIndexPath
        }
        
        delegate.focusUserTimerListView(self, moveItemAt: sourceIndexPath, to: targetIndexPath)
        adapter.moveItem(at: sourceIndexPath, to: targetIndexPath)
        return targetIndexPath
    }
    
    // MARK: - FocusUserTimerListCellDelegate
    func focusUserTimerListCellDidClickMore(_ cell: FocusUserTimerListCell) {
        guard let timer = cell.timer,
              let indexPath = self.adapter.indexPath(of: timer) else {
            return
        }
        
        let index = indexPath.item
        let menuController = FocusUserTimerMenuController(timer: timer)
        if !timer.isArchived {
            menuController.showMoveToTop = index > 0
            menuController.showMoveToBottom = index < (userTimers.count - 1)
        }
 
        menuController.didSelectMenuActionType = { type in
            self.performMenuAction(type, for: timer)
        }
        
        menuController.showMenu(from: cell.moreButton)
    }
    
    func performMenuAction(_ type: FocusUserTimerMenuType, for timer: FocusTimer) {
        let timerController = FocusUserTimerController()
        switch type {
        case .statistics:
            timerController.showStatistics(forTimer: timer)
        case .viewRecord:
            timerController.showRecords(forTimer: timer)
        case .addRecord:
            timerController.addRecordManually(forTimer: timer)
        case .moveToTop:
            timerController.moveTimerToTop(timer, in: userTimers)
        case .moveToBottom:
            timerController.moveTimerToBottom(timer, in: userTimers)
        case .edit:
            timerController.editTimer(timer)
        case .archive:
            timerController.archiveTimer(timer)
        case .unarchive:
            timerController.unarchiveTimer(timer)
        case .delete:
            timerController.deleteTimer(timer)
        }
    }
}
