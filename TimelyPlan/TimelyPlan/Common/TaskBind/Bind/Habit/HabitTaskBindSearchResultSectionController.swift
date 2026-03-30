//
//  HabitTaskBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation
import UIKit

class HabitTaskBindSearchResultSectionController: TPCollectionSearchResultSectionController {
    
    override init() {
        super.init()
        self.layout.preferredItemWidth = .greatestFiniteMagnitude
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitTaskBindCell.self
    }

    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        let cell = cell as! HabitTaskBindCell
        cell.habitTask = item(at: index) as? HabitTask
        
        /// 需要显示高亮数据
        super.didDequeCell(cell, forItemAt: index)
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        habit.searchActiveTasks(containText: text) { tasks in
            completion(tasks)
        }
    }
}
