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
        
        GoalRepository.addUpdater(self, for: [.plan, .task])
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
                self.listView.groups = self.goalTaskGroups(with: self.tasks)
                self.listView.reloadData()
            }
        }
    }
    
    /// 按目标任务所属的目标计划分组（收件箱置顶）
    private func goalTaskGroups(with tasks: [GoalTask]) -> [GoalTaskGroup] {
        var orderedPlans = [GoalPlanFeature]()
        var tasksByPlan = [String: [GoalTask]]()
        
        for task in tasks {
            let plan = task.planFeature
            if tasksByPlan[plan.identifier] == nil {
                orderedPlans.append(plan)
                tasksByPlan[plan.identifier] = []
            }
            tasksByPlan[plan.identifier]?.append(task)
        }
        
        /// 收件箱置顶，其余目标计划保持任务原有的出现顺序
        let plans = orderedPlans.filter { $0.isInbox } + orderedPlans.filter { !$0.isInbox }
        
        return plans.compactMap { plan in
            guard let tasks = tasksByPlan[plan.identifier], tasks.count > 0 else {
                return nil
            }
            
            let group = GoalTaskGroup(identifier: plan.identifier)
            group.title = plan.displayName
            group.goalTasks = tasks
            return group
        }
    }
    
    /// 获取指定区块对应的分组
    private func group(at section: Int) -> GoalTaskGroup? {
        return listView.sectionObject(at: section) as? GoalTaskGroup
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForHeaderInSection section: Int) -> AnyClass? {
        return TPDefaultInfoTableHeaderFooterView.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return group(at: section) == nil ? 0.0 : 50.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView,
              let group = group(at: section) else {
            return
        }
        
        headerView.contentPadding = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 0.0, right: 0.0)
        headerView.title = group.title
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

// MARK: - GoalPlanProcessorDelegate
extension MyDayGoalTaskBindViewController: GoalPlanProcessorDelegate {
    
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {
        loadTasks()
    }
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {
        loadTasks()
    }
    
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {
        loadTasks()
    }
    
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {
        loadTasks()
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
