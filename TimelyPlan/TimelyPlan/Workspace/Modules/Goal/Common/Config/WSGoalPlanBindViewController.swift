//
//  WSGoalPlanBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 选择代理

protocol WSGoalPlanBindViewControllerDelegate: AnyObject {
    
    /// 选中目标计划
    func goalPlanBindViewController(_ viewController: WSGoalPlanBindViewController, didSelect goalPlan: GoalPlan)
}

// MARK: - 选择列表

/// 目标计划选择列表。用于组件配置选择要展示的目标计划
class WSGoalPlanBindViewController: TPViewController,
                                    TPGroupTableViewDelegate {
    
    weak var delegate: WSGoalPlanBindViewControllerDelegate?
    
    /// 当前选中的目标计划标识
    private(set) var selectedIdentifier: String?
    
    /// 分组标识
    private let groupIdentifier = "WSGoalPlanBindGroup"
    
    /// 单元格样式
    private lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()
    
    /// 目标计划列表视图
    private lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: view.bounds, style: .insetGrouped)
        view.delegate = self
        return view
    }()
    
    /// 数据源
    private let viewModel = GoalPlanViewModel()
    
    init(selectedIdentifier: String?) {
        self.selectedIdentifier = selectedIdentifier
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        listView.placeholderProvider = viewModel.placeholderProvider
        
        viewModel.goalPlansDidChange = { [weak self] _ in
            self?.reloadGoalPlans()
        }
        
        viewModel.loadGoalPlans()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 列表
    private func reloadGoalPlans() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let group = GoalPlanGroup(identifier: self.groupIdentifier)
            group.goalPlans = self.viewModel.goalPlans
            self.listView.groups = [group]
            self.listView.reloadData()
        }
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return GoalPlanSelectCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? GoalPlanSelectCell else {
            return
        }
        
        cell.style = cellStyle
        cell.goalPlan = tableView.item(at: indexPath) as? GoalPlan
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let goalPlan = tableView.item(at: indexPath) as? GoalPlan else {
            return false
        }
        
        return goalPlan.identifier == selectedIdentifier
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let goalPlan = tableView.item(at: indexPath) as? GoalPlan else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        selectedIdentifier = goalPlan.identifier
        delegate?.goalPlanBindViewController(self, didSelect: goalPlan)
        tableView.updateCheckmarks()
    }
}
