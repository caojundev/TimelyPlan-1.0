//
//  MyDayCountdownBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/25.
//

import Foundation
import UIKit

class MyDayCountdownBindSearchResultSectionController: TPTableSearchResultSectionController,
                                                       CountdownEventProcessorDelegate {
    
    override init() {
        super.init()
        CountdownRepository.addUpdater(self, for: [.event])
    }
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        super.didDequeHeader(headerView)
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView else {
            return
        }
        
        headerView.title = resGetString("Countdown")
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 76.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return MyDayCountdownEventBindCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? MyDayCountdownEventBindCell else {
            return
        }
        
        cell.event = item(at: index) as? CountdownEvent
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        CountdownRepository.searchActiveEvents(containText: text, completion: completion)
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        guard let event = item(at: index) as? CountdownEvent else {
            return false
        }
        
        return MyDayCountdownBindHandler.isAddedToMyDay(event)
    }
    
    override func didSelectRow(at index: Int) {
        guard let event = item(at: index) as? CountdownEvent else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        let sourceView = cellForRow(at: index)
        MyDayCountdownBindHandler.handleSelection(of: event, from: sourceView)
    }
    
    // MARK: - CountdownEventProcessorDelegate
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        refreshSearchResults()
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent, with change: CountdownEventChange) {
        refreshSearchResults()
    }
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {
        refreshSearchResults()
    }
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {
        refreshSearchResults()
    }
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {
        refreshSearchResults()
    }
}
