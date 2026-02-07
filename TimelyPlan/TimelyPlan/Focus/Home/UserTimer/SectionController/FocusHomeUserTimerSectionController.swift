//
//  FocusHomeUserTimerSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/20.
//

import Foundation

class FocusHomeUserTimerSectionController: FocusUserTimerListSectionController {
    
    override func classForCell(at index: Int) -> AnyClass? {
        return FocusHomeUserTimerCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        let timer = timer(at: index)
        if let cell = cell as? FocusHomeUserTimerCell {
            cell.isFocusing = isFocusing(of: timer)
        }
    }
    
    
    // MARK: - Focusing Indicator
    var isDisplaying: Bool = true {
        didSet {
            updateFocusingIndicator()
        }
    }
    
    func updateFocusingIndicator() {
        guard let visibleCells = adapter?.visibleCells as? [FocusHomeUserTimerCell] else {
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
        if let timerId = timer.identifier, timerId == focusingTimerId {
            isFocusing = true
        }
        
        return isFocusing
    }
    
}
