//
//  MyDayGoalTaskBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/12.
//

import Foundation
import UIKit

class MyDayGoalTaskBindViewController: TPViewController,
                                       TPGroupTableViewDelegate {

    lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: view.bounds, style: .insetGrouped)
        view.delegate = self
        return view
    }()

    lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()

    /// 当前展示的目标任务
    private(set) var tasks: [GoalTask] = []
    
    private let requestManager = TPRequestManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        let placeholderProvider = TPDefaultPlaceholderProvider()
        placeholderProvider.emptyImage = resGetImage("goal_placeholder_80")
        placeholderProvider.emptyTitle = resGetString("No Goal")
        listView.placeholderProvider = placeholderProvider
        
        GoalRepository.addUpdater(self, for: [.task])
        loadTasks()
    }
    
    deinit {
        GoalRepository.removeUpdater(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.listView.frame = self.view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func loadTasks() {
        let requestID = requestManager.executeRequest()
        GoalRepository.fetchActiveGoalTasks { [weak self] tasks in
            guard let self = self,
                  self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            DispatchQueue.main.async {
                self.tasks = tasks ?? []
                let group = GoalTaskGroup(identifier: "Tasks")
                group.goalTasks = self.tasks
                self.listView.groups = [group]
                self.listView.reloadData()
            }
        }
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return MyDayGoalTaskBindCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! MyDayGoalTaskBindCell
        cell.style = cellStyle
        cell.goalTask = tableView.item(at: indexPath) as? GoalTask
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let task = tableView.item(at: indexPath) as? GoalTask else {
            return false
        }
        
        return task.isAddedToMyDay
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let task = tableView.item(at: indexPath) as? GoalTask else {
            return
        }
    
        TPImpactFeedback.impactWithSoftStyle()
        let isAddedToMyDay = !task.isAddedToMyDay
        GoalRepository.updateGoalTask(task, isAddedToMyDay: isAddedToMyDay)
    }
}

// MARK: - GoalTaskProcessorDelegate
extension MyDayGoalTaskBindViewController: GoalTaskProcessorDelegate {
    
    func didChangeRemoteGoalTask(with results: EntityChangeResults<GoalTask>?) {
        loadTasks()
    }
    
    func didCreateGoalTask(_ goalTask: GoalTask) {
        loadTasks()
    }
    
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        loadTasks()
    }
    
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {
        loadTasks()
    }
    
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {
        loadTasks()
    }
}
