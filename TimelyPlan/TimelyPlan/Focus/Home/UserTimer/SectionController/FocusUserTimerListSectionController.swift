//
//  FocusUserTimerListSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/27.
//

import Foundation
import UIKit

class FocusTimerListSectionLayout: TPCollectionSectionLayout {

    override init() {
        super.init()
        self.edgeMargins = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        self.minimumItemsCountPerRow = 1
        self.maximumItemsCountPerRow = 1
        self.lineSpacing = 10.0
        self.interitemSpacing = 10.0
        self.preferredItemHeight = 70.0
        self.preferredItemWidth = kFocusHomeContentMaxWidth
    }
}

class FocusUserTimerListSectionController: TPCollectionBaseSectionController,
                                            FocusUserTimerListCellDelegate {
    
    let cellStyle = FocusUserTimerCellStyle()
    
    let layout = FocusTimerListSectionLayout()
    
    override var items: [ListDiffable]? {
        /// 返回活动计时器
        return focus.getActiveTimers()
    }
    
    override func interitemSpacing() -> CGFloat {
        return layout.interitemSpacing
    }
    
    override func lineSpacing() -> CGFloat {
        return layout.lineSpacing
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return layout.sectionInset
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        layout.collectionViewSize = adapter?.collectionViewSize()
        return layout.constraintCellSize ?? .zero
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return FocusUserTimerListCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        let timer = timer(at: index)
        if let cell = cell as? FocusUserTimerInfoCell {
            cell.timer = timer
        }
    }
    
    override func didSelectItem(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        let timer = timer(at: index)
        FocusPresenter.startFocus(with: timer)
    }
    
    override func styleForItem(at index: Int) -> TPCollectionCellStyle? {
        return cellStyle
    }
    
    // MARK: - FocusUserTimerListCellDelegate
    func focusUserTimerListCellDidClickMore(_ cell: FocusUserTimerListCell) {
        guard let timer = cell.timer,  let index = index(of: timer) else {
            return
        }
        
        let menuController = FocusUserTimerMenuController(timer: timer)
        if !timer.isArchived {
            menuController.showMoveToTop = index > 0
            menuController.showMoveToBottom = index < (timers.count - 1)
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
            timerController.moveTimerToTop(timer, in: timers)
        case .moveToBottom:
            timerController.moveTimerToBottom(timer, in: timers)
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
    
    // MARK: - Helpers
    /// 当前用户列表
    var timers: [FocusTimer] {
        if let timers = adapter?.items(for: self) as? [FocusTimer] {
            return timers
        }

        return []
    }
    
    func timer(at index: Int) -> FocusTimer {
        let timer = item(at: index) as! FocusTimer
        return timer
    }
    
    func index(of timer: FocusTimer) -> Int? {
        guard let timers = adapter?.items(for: self) as? [FocusTimer] else {
            return nil
        }
        
        return timers.indexOf(timer)
    }
}
