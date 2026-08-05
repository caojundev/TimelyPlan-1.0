//
//  MyDayFocusBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/4.
//

import Foundation
import UIKit

class MyDayFocusBindSearchResultSectionController: TPTableSearchResultSectionController,
                                                   FocusTimerProcessorDelegate {

    override init() {
        super.init()
        FocusRepository.addUpdater(self, for: [.timer])
    }
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        super.didDequeHeader(headerView)
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView else {
            return
        }
        
        headerView.title = resGetString("Focus")
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 60.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return MyDayFocusTimerBindCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? MyDayFocusTimerBindCell else {
            return
        }
        
        cell.timer = item(at: index) as? FocusTimer
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        FocusRepository.searchActiveTimers(containText: text, completion: completion)
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        guard let timer = item(at: index) as? FocusTimer else {
            return false
        }
        
        return timer.isAddedToMyDay
    }
    
    override func didSelectRow(at index: Int) {
        guard let timer = item(at: index) as? FocusTimer else {
            return
        }
        
        let isAddedToMyDay = !timer.isAddedToMyDay
        FocusRepository.updateTimer(timer, isAddedToMyDay: isAddedToMyDay)
    }
    
    // MARK: - FocusTimerProcessorDelegate
    func didUpdateFocusTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {
        refreshSearchResults()
    }
}
