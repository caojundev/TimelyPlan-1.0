//
//  GoalTaskMoveViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/10.
//

import Foundation
import UIKit

/// 移动目标任务：选择目标计划
class GoalTaskMoveViewController: TPViewController,
                                  TPGroupTableViewDelegate {
    
    /// 选中目标计划回调
    var didSelectGoalPlan: ((GoalPlan) -> Void)?
    
    /// 视图模型
    let viewModel: GoalTaskMoveViewModel
    
    /// 目标计划列表视图
    lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: view.bounds, style: .insetGrouped)
        view.delegate = self
        view.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        return view
    }()
    
    init(goalPlan: GoalPlanFeature?) {
        self.viewModel = GoalTaskMoveViewModel(goalPlan: goalPlan)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Move To")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.addSubview(listView)
        listView.placeholderProvider = viewModel.placeholderProvider
        setupViewModel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
    
    /// 绑定视图模型
    private func setupViewModel() {
        viewModel.goalPlansDidChange = { [weak self] change in
            self?.goalPlansChanged(change)
        }
        
        viewModel.loadGoalPlans()
    }
    
    /// 目标计划数据改变，刷新列表
    private func goalPlansChanged(_ change: GoalPlanChange?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let group = GoalPlanGroup(identifier: "GoalPlanSelectGroup")
            group.goalPlans = self.viewModel.goalPlans
            self.listView.groups = [group]
            self.listView.reloadData()
        }
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TPGroupTableViewDelegate
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
        
        cell.goalPlan = tableView.item(at: indexPath) as? GoalPlan
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let goalPlan = tableView.item(at: indexPath) as? GoalPlan else {
            return false
        }
        
        return viewModel.isSelectedGoalPlan(goalPlan)
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let goalPlan = tableView.item(at: indexPath) as? GoalPlan else {
            return
        }
        
        selectGoalPlan(goalPlan)
    }
    
    /// 选中目标计划并关闭
    private func selectGoalPlan(_ goalPlan: GoalPlan) {
        TPImpactFeedback.impactWithSoftStyle()
        didSelectGoalPlan?(goalPlan)
        if let presentingVC = self.presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

/// 移动目标任务视图模型
class GoalTaskMoveViewModel: GoalPlanViewModel {
    
    /// 当前选中的目标计划特征（任务所属目标计划）
    let goalPlan: GoalPlanFeature?
    
    init(goalPlan: GoalPlanFeature?) {
        self.goalPlan = goalPlan
        super.init()
    }
    
    /// 是否为当前选中的目标计划
    func isSelectedGoalPlan(_ goalPlan: GoalPlan) -> Bool {
        return goalPlan.identifier == self.goalPlan?.identifier
    }
}

/// 目标计划选择单元格
class GoalPlanSelectCell: TPDefaultInfoTableCell {
    
    /// 目标计划
    var goalPlan: GoalPlan? {
        didSet {
            self.updateGoalPlanInfo()
        }
    }
    
    /// 颜色视图
    private lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    /// 对勾图标
    private lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("checkmark_24")
        return view
    }()
    
    let colorSize = CGSize.size(3)
    
    override func setupInfoView() {
        super.setupInfoView()
        colorView.layer.cornerRadius = colorSize.halfWidth
        infoView.leftAccessoryView = colorView
        infoView.leftAccessorySize = colorSize
        infoView.leftAccessoryMargins = UIEdgeInsets(left: 10.0, right: 12.0)
        infoView.rightAccessoryView = checkmarkView
        infoView.rightAccessorySize = .mini
        infoView.rightAccessoryMargins = UIEdgeInsets(left: 10.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkmarkView.updateImage(withColor: tintColor)
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkView.isHidden = !checked
    }
    
    /// 更新目标计划信息
    private func updateGoalPlanInfo() {
        guard let goalPlan = goalPlan else {
            return
        }
        
        title = goalPlan.displayName
        colorView.layer.backgroundColor = goalPlan.color?.cgColor
        setNeedsLayout()
    }
}
