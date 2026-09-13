//
//  GoalTaskBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/12.
//

import Foundation
import UIKit

class GoalTaskBindSearchResultSectionController: TPTableSearchResultSectionController,
                                                 GoalPlanProcessorDelegate,
                                                 GoalTaskProcessorDelegate {
    
    override init() {
        super.init()
        GoalRepository.addUpdater(self, for: [.plan, .task])
    }
    
    deinit {
        GoalRepository.removeUpdater(self)
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
        return GoalTaskBindCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? GoalTaskBindCell else {
            return
        }
        
        cell.goalTask = item(at: index) as? GoalTask
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        GoalRepository.searchGoalTasks(containText: text,
                                       showCompleted: false,
                                       completion: completion)
    }
    
    // MARK: - GoalPlanProcessorDelegate
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {
        refreshSearchResults()
    }
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {
        refreshSearchResults()
    }
    
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {
        refreshSearchResults()
    }
    
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {
        refreshSearchResults()
    }
    
    // MARK: - GoalTaskProcessorDelegate
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        refreshSearchResults()
    }
}
