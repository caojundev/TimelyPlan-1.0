//
//  MyDayGoalBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/12.
//

import Foundation
import UIKit

class MyDayGoalBindSearchResultSectionController: TPTableSearchResultSectionController,
                                                   GoalTaskProcessorDelegate {
    
    override init() {
        super.init()
        GoalRepository.addUpdater(self, for: [.task])
    }
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        super.didDequeHeader(headerView)
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView else {
            return
        }
        
        headerView.title = resGetString("Goal")
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 76.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return MyDayGoalTaskBindCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? MyDayGoalTaskBindCell else {
            return
        }
        
        cell.goalTask = item(at: index) as? GoalTask
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        GoalRepository.searchGoalTasks(containText: text,
                                       showCompleted: false,
                                       completion: completion)
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        guard let task = item(at: index) as? GoalTask else {
            return false
        }
        
        return task.isAddedToMyDay
    }
    
    override func didSelectRow(at index: Int) {
        guard let task = item(at: index) as? GoalTask else {
            return
        }
        
        let isAddedToMyDay = !task.isAddedToMyDay
        GoalRepository.updateGoalTask(task, isAddedToMyDay: isAddedToMyDay)
    }
    
    // MARK: - GoalTaskProcessorDelegate
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        refreshSearchResults()
    }
}
