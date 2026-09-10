//
//  GoalTaskMoveViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/10.
//

import Foundation
import UIKit

/// 移动目标任务：选择目标计划
class GoalTaskMoveViewController: TPTableSectionsViewController,
                                  TPTableSectionControllerDelegate {
    
    /// 选中目标计划回调
    var didSelectGoalPlan: ((GoalPlan) -> Void)?
    
    /// 当前选中的目标计划特征
    let goalPlan: GoalPlanFeature?
    
    /// 选中的目标计划
    var selectedGoalPlan: GoalPlan? {
        get {
            return planSectionController.selectedGoalPlan
        }
        
        set {
            planSectionController.selectedGoalPlan = newValue
        }
    }
    
    /// 目标计划区块控制器
    private(set) lazy var planSectionController: GoalPlanSelectSectionController = {
        let sectionController = GoalPlanSelectSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    init(goalPlan: GoalPlanFeature?) {
        self.goalPlan = goalPlan
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Move To")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        setupSectionControllers()
        adapter.reloadData()
    }
    
    func setupSectionControllers() {
        sectionControllers = [planSectionController]
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        guard let goalPlan = sectionController.item(at: index) as? GoalPlan else {
            return
        }
        
        selectedGoalPlan = goalPlan
        adapter.updateCheckmarks()
        selectGoalPlan(goalPlan)
    }
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        guard let goalPlan = sectionController.item(at: index) as? GoalPlan else {
            return false
        }
        
        return goalPlan.identifier == self.goalPlan?.identifier
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

/// 目标计划选择区块控制器
class GoalPlanSelectSectionController: TPTableBaseSectionController {
    
    /// 选中的目标计划
    var selectedGoalPlan: GoalPlan?
    
    /// 目标计划数组（仅活动目标计划）
    private(set) lazy var goalPlans: [GoalPlan] = {
        return GoalRepository.getActiveGoalPlans()
    }()
    
    override var items: [ListDiffable]? {
        return goalPlans
    }
    
    override func heightForHeader() -> CGFloat {
        return 0.0
    }
    
    override func heightForFooter() -> CGFloat {
        return 0.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 55.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return GoalPlanSelectCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? GoalPlanSelectCell else {
            return
        }
        
        cell.goalPlan = item(at: index) as? GoalPlan
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
