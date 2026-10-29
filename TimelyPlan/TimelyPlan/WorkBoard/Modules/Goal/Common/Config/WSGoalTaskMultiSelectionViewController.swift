//
//  WSGoalTaskMultiSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 多选列表

/// 目标任务多选列表。
///
/// 按所属目标计划分组展示全部进行中的任务，点击切换选中状态，超出上限的选择会被忽略；
/// 底部标签展示已选数量与上限，选择顺序即组件内的展示顺序。
class WSGoalTaskMultiSelectionViewController: TPViewController,
                                             TPGroupTableViewDelegate {
    
    /// 选择变化回调，按选择顺序返回目标任务标识
    var didChangeSelection: (([String]) -> Void)?
    
    /// 已选目标任务标识，保持选择顺序
    private(set) var selectedIdentifiers: [String]
    
    /// 最多可选择的目标任务数量
    private let maximumSelectionCount: Int
    
    /// 分组标识前缀
    private let groupIdentifierPrefix = "WSGoalTaskMultiSelectionGroup"
    
    /// 选中数量标签高度
    private let selectionCountLabelHeight: CGFloat = 36.0
    
    /// 当前展示的目标任务
    private var tasks: [GoalTask] = []
    
    /// 请求管理，避免过期请求覆盖数据
    private let requestManager = TPRequestManager()
    
    /// 单元格样式
    private lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()
    
    /// 目标任务列表视图
    private lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: .zero, style: .insetGrouped)
        view.delegate = self
        return view
    }()
    
    /// 选中数量标签
    private lazy var selectionCountLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 11.0)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = themeBackgroundColor
        label.edgeInsets = UIEdgeInsets(horizontal: 16.0, top: 4.0)
        return label
    }()
    
    init(selectedIdentifiers: [String], maximumSelectionCount: Int) {
        self.selectedIdentifiers = selectedIdentifiers
        self.maximumSelectionCount = max(maximumSelectionCount, 1)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        GoalRepository.removeUpdater(self)
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        view.addSubview(selectionCountLabel)
        selectionCountLabel.addSeparator(position: .top)
        
        let placeholderProvider = TPDefaultPlaceholderProvider()
        placeholderProvider.emptyImage = resGetImage("goal_placeholder_80")
        placeholderProvider.emptyTitle = resGetString("No Task")
        listView.placeholderProvider = placeholderProvider
        
        updateSelectionCount()
        
        /// 任务与所属计划变化都会影响列表
        GoalRepository.addUpdater(self, for: [.plan, .task])
        loadTasks()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /// 选中数量标签位于底部，列表相应缩短
        var listFrame = view.bounds
        listFrame.size.height = max(listFrame.height - selectionCountLabelHeight, 0.0)
        listView.frame = listFrame
        selectionCountLabel.frame = CGRect(x: 0.0,
                                           y: listFrame.maxY,
                                           width: view.width,
                                           height: selectionCountLabelHeight)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 数据
    /// 读取全部进行中的目标任务
    private func loadTasks() {
        let requestID = requestManager.executeRequest()
        GoalRepository.fetchActiveGoalTasks { [weak self] tasks in
            guard let self = self,
                  self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            DispatchQueue.main.async {
                self.tasks = tasks ?? []
                self.filterSelection()
                self.updateSelectionCount()
                self.reloadList()
            }
        }
    }
    
    /// 已删除或归档的任务不再保留在选择列表中
    private func filterSelection() {
        let validIdentifiers = Set(tasks.map { $0.identifier })
        let filteredIdentifiers = selectedIdentifiers.filter { validIdentifiers.contains($0) }
        guard filteredIdentifiers != selectedIdentifiers else {
            return
        }
        
        selectedIdentifiers = filteredIdentifiers
        didChangeSelection?(filteredIdentifiers)
    }
    
    /// 刷新列表
    private func reloadList() {
        listView.groups = goalTaskGroups(with: tasks)
        listView.reloadData()
    }
    
    /// 按任务所属的目标计划分组，收件箱置顶
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
        
        let plans = orderedPlans.filter { $0.isInbox } + orderedPlans.filter { !$0.isInbox }
        return plans.compactMap { plan in
            guard let planTasks = tasksByPlan[plan.identifier], !planTasks.isEmpty else {
                return nil
            }
            
            let group = GoalTaskGroup(identifier: "\(groupIdentifierPrefix).\(plan.identifier)")
            group.title = plan.displayName
            group.goalTasks = planTasks
            return group
        }
    }
    
    // MARK: - 选中数量
    /// 更新已选数量与上限提示
    private func updateSelectionCount() {
        let countText = String(format: resGetString("%ld selected"), selectedIdentifiers.count)
        let maximumText = String(format: resGetString("Up to %ld"), maximumSelectionCount)
        selectionCountLabel.text = "\(countText) · \(maximumText)"
    }
    
    // MARK: - TPGroupTableViewDelegate
    /// 获取指定区块对应的分组
    private func group(at section: Int) -> GoalTaskGroup? {
        return listView.sectionObject(at: section) as? GoalTaskGroup
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForHeaderInSection section: Int) -> AnyClass? {
        return TPDefaultInfoTableHeaderFooterView.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return group(at: section) == nil ? 0.0 : 40.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView,
              let group = group(at: section) else {
            return
        }
        
        /// 区块标题展示任务所属的计划名称
        headerView.contentPadding = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 0.0, right: 0.0)
        headerView.title = group.title
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return GoalTaskBindCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? GoalTaskBindCell else {
            return
        }
        
        cell.style = cellStyle
        cell.goalTask = tableView.item(at: indexPath) as? GoalTask
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let goalTask = tableView.item(at: indexPath) as? GoalTask else {
            return false
        }
        
        return selectedIdentifiers.contains(goalTask.identifier)
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let goalTask = tableView.item(at: indexPath) as? GoalTask else {
            return
        }
        
        if let index = selectedIdentifiers.firstIndex(of: goalTask.identifier) {
            selectedIdentifiers.remove(at: index)
            TPImpactFeedback.impactWithSoftStyle()
        } else {
            /// 超出上限时不再加入，给出重一点的反馈
            guard selectedIdentifiers.count < maximumSelectionCount else {
                TPImpactFeedback.impactWithRigidStyle()
                return
            }
            
            selectedIdentifiers.append(goalTask.identifier)
            TPImpactFeedback.impactWithSoftStyle()
        }
        
        tableView.updateCheckmarks()
        updateSelectionCount()
        didChangeSelection?(selectedIdentifiers)
    }
}

// MARK: - GoalPlanProcessorDelegate
extension WSGoalTaskMultiSelectionViewController: GoalPlanProcessorDelegate {
    
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {
        loadTasks()
    }
    
    func didUpdateGoalPlan(_ goalPlan: GoalPlan) {
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
extension WSGoalTaskMultiSelectionViewController: GoalTaskProcessorDelegate {
    
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
