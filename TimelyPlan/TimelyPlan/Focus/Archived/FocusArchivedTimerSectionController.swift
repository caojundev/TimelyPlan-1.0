//
//  FocusArchivedTimerSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

class FocusArchivedTimerSectionController: FocusUserTimerListSectionController {
    
    override init() {
        super.init()
        self.layout.preferredItemWidth = .greatestFiniteMagnitude
    }
    
    override var items: [ListDiffable]? {
        return focus.getArchivedTimers()
    }

    override func classForCell(at index: Int) -> AnyClass? {
        return FocusUserTimerListCell.self
    }
    
    override func didSelectItem(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        let timer = timer(at: index)
        FocusPresenter.showStatistics(for: timer)
    }
    
}
