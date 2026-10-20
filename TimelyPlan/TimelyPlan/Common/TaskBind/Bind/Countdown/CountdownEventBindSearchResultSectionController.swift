//
//  CountdownEventBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/20.
//

import Foundation
import UIKit

class CountdownEventBindSearchResultSectionController: TPTableSearchResultSectionController,
                                                        CountdownEventProcessorDelegate {
    
    override init() {
        super.init()
        CountdownRepository.addUpdater(self, for: [.event])
    }
    
    deinit {
        CountdownRepository.removeUpdater(self)
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
        return CountdownEventBindCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? CountdownEventBindCell else {
            return
        }
        
        cell.event = item(at: index) as? CountdownEvent
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        CountdownRepository.searchActiveEvents(containText: text, completion: completion)
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
