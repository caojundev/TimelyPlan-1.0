//
//  HabitTaskBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation
import UIKit

class HabitTaskBindSearchResultSectionController: TPTableSearchResultSectionController {
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        super.didDequeHeader(headerView)
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView else {
            return
        }
        
        headerView.title = resGetString("Habit")
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 60.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitTaskBindSearchResultCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? HabitTaskBindSearchResultCell,
              let task = item(at: index) as? HabitTask else {
            return
        }
        
        cell.habitTask = task
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        HabitRepository.searchActiveTasks(containText: text, completion: completion)
    }
    
}
