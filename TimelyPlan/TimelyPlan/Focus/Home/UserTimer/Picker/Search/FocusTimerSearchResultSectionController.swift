//
//  FocusTimerSearchResultBaseSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/5.
//

import Foundation
import UIKit

class FocusTimerSearchResultSectionController: TPCollectionSearchResultSectionController {
    
    override init() {
        super.init()
        self.layout.preferredItemWidth = .greatestFiniteMagnitude
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return FocusUserTimerSelectCell.self
    }

    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        if let cell = cell as? FocusUserTimerInfoCell {
            cell.timer = item(at: index) as? FocusTimer
        }
        
        super.didDequeCell(cell, forItemAt: index)
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        FocusRepository.searchActiveTimers(containText: text) { timers in
            completion(timers)
        }
    }
}

