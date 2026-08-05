//
//  MyDayHabitBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation
import UIKit

class MyDayHabitBindSearchResultSectionController: TPTableSearchResultSectionController,
                                                   HabitTaskProcessorDelegate {
    
    override init() {
        super.init()
        HabitRepository.addUpdater(self, for: [.task])
    }
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        super.didDequeHeader(headerView)
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView else {
            return
        }
        
        headerView.title = resGetString("Habit")
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 68.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return MyDayHabitTaskBindCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? MyDayHabitTaskBindCell,
              let task = item(at: index) as? HabitTask else {
            return
        }
        
        cell.habitTask = task
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        HabitRepository.searchActiveTasks(containText: text, completion: completion)
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        guard let task = item(at: index) as? HabitTask else {
            return false
        }
        
        return task.isAddedToMyDay
    }
    
    override func didSelectRow(at index: Int) {
        guard let task = item(at: index) as? HabitTask else {
            return
        }
        
        let isAddedToMyDay = !task.isAddedToMyDay
        HabitRepository.updateTask(task, isAddedToMyDay: isAddedToMyDay)
    }
    
    func didUpdateHabitTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        refreshSearchResults()
    }
}
