//
//  WSGoalPlanMultiSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 多选列表

/// 目标计划多选列表。
///
/// 列表展示全部进行中的目标计划，点击切换选中状态，超出上限的选择会被忽略；
/// 底部标签展示已选数量与上限，选择顺序即组件内的展示顺序。
class WSGoalPlanMultiSelectionViewController: TPViewController,
                                             TPGroupTableViewDelegate {
    
    /// 选择变化回调，按选择顺序返回目标计划标识
    var didChangeSelection: (([String]) -> Void)?
    
    /// 已选目标计划标识，保持选择顺序
    private(set) var selectedIdentifiers: [String]
    
    /// 最多可选择的目标计划数量
    private let maximumSelectionCount: Int
    
    /// 分组标识
    private let groupIdentifier = "WSGoalPlanMultiSelectionGroup"
    
    /// 选中数量标签高度
    private let selectionCountLabelHeight: CGFloat = 36.0
    
    /// 单元格样式
    private lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()
    
    /// 目标计划列表视图
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
    
    /// 数据源
    private let viewModel = GoalPlanViewModel()
    
    init(selectedIdentifiers: [String], maximumSelectionCount: Int) {
        self.selectedIdentifiers = selectedIdentifiers
        self.maximumSelectionCount = max(maximumSelectionCount, 1)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        view.addSubview(selectionCountLabel)
        selectionCountLabel.addSeparator(position: .top)
        
        listView.placeholderProvider = viewModel.placeholderProvider
        
        viewModel.goalPlansDidChange = { [weak self] _ in
            self?.goalPlansDidChange()
        }
        
        updateSelectionCount()
        viewModel.loadGoalPlans()
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
    /// 目标计划变化
    private func goalPlansDidChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            /// 已删除或归档的计划不再保留在选择列表中
            let validIdentifiers = Set((self.viewModel.goalPlans ?? []).map { $0.identifier })
            let filteredIdentifiers = self.selectedIdentifiers.filter { validIdentifiers.contains($0) }
            if filteredIdentifiers != self.selectedIdentifiers {
                self.selectedIdentifiers = filteredIdentifiers
                self.didChangeSelection?(filteredIdentifiers)
            }
            
            self.updateSelectionCount()
            self.reloadList()
        }
    }
    
    /// 刷新列表
    private func reloadList() {
        let group = GoalPlanGroup(identifier: groupIdentifier)
        group.goalPlans = viewModel.goalPlans
        listView.groups = [group]
        listView.reloadData()
    }
    
    // MARK: - 选中数量
    /// 更新已选数量与上限提示
    private func updateSelectionCount() {
        let countText = String(format: resGetString("%ld selected"), selectedIdentifiers.count)
        let maximumText = String(format: resGetString("Up to %ld"), maximumSelectionCount)
        selectionCountLabel.text = "\(countText) · \(maximumText)"
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
        
        return selectedIdentifiers.contains(goalPlan.identifier)
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let goalPlan = tableView.item(at: indexPath) as? GoalPlan else {
            return
        }
        
        if let index = selectedIdentifiers.firstIndex(of: goalPlan.identifier) {
            selectedIdentifiers.remove(at: index)
            TPImpactFeedback.impactWithSoftStyle()
        } else {
            /// 超出上限时不再加入，给出重一点的反馈
            guard selectedIdentifiers.count < maximumSelectionCount else {
                TPImpactFeedback.impactWithRigidStyle()
                return
            }
            
            selectedIdentifiers.append(goalPlan.identifier)
            TPImpactFeedback.impactWithSoftStyle()
        }
        
        tableView.updateCheckmarks()
        updateSelectionCount()
        didChangeSelection?(selectedIdentifiers)
    }
}
