//
//  HabitTimePlanEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/4.
//

import Foundation
import UIKit

class HabitTimePlanEditViewController: TPTableSectionsViewController {

    /// 结束编辑回调
    var didEndEditing: ((HabitTimePlan) -> Void)?
    
    /// 时间计划
    private(set) var timePlan: HabitTimePlan {
        get {
            return HabitTimePlan(type: planType, regularRule: regularRule, randomRule: randomRule)
        }
        
        set {
            self.planType = newValue.type
            self.regularRule = newValue.regularRule ?? HabitTimePlanRegularRule()
            self.randomRule = newValue.randomRule ?? HabitTimePlanRandomRule()
        }
    }
    
    var planType: HabitTimePlanType = .regularly
    
    var regularRule: HabitTimePlanRegularRule {
        get {
            return self.regularSectionController.rule
        }
        
        set {
            self.regularSectionController.rule = newValue
        }
    }
    
    var randomRule: HabitTimePlanRandomRule {
        get {
            return self.randomSectionController.rule
        }
        
        set {
            self.randomSectionController.rule = newValue
        }
    }
    
    /// 类型
    lazy var typeSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 10.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [typeCellItem]
        return sectionController
    }()
    
    lazy var typeCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = HabitTimePlanType.segmentedMenuItems()
        cellItem.updater = {
            guard let self = self else {
                return
            }
            
            self.typeCellItem.selectedMenuTag = self.planType.rawValue
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            let type: HabitTimePlanType? = menuItem.actionType()
            if let type = type {
                self?.didSelectType(type)
            }
        }

        return cellItem
    }()
    
    /// 描述区块
    lazy var infoSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 10.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [infoCellItem]
        return sectionController
    }()
    
    lazy var infoCellItem: TPDescriptionTableCellItem = {
        let cellItem = TPDescriptionTableCellItem()
        cellItem.contentPadding = UIEdgeInsets(horizontal: 10.0, vertical: 10.0)
        cellItem.selectionStyle = .none
        cellItem.updater = { [weak self] in
            self?.updateInfoCellItem()
        }
        
        return cellItem
    }()
    
    /// 定期区块
    lazy var regularSectionController: HabitTimePlanRegularSectionController = { [weak self] in
        let sectionController = HabitTimePlanRegularSectionController()
        sectionController.headerItem.height = 10.0
        sectionController.ruleDidChange = { [weak self] rule in
            self?.regularRuleDidChange(rule)
        }
        
        return sectionController
    }()
    
    /// 随机区块
    lazy var randomSectionController: HabitTimePlanRandomSectionController = {
        let sectionController = HabitTimePlanRandomSectionController()
        sectionController.headerItem.height = 10.0
        sectionController.ruleDidChange = { [weak self] rule in
            self?.randomRuleDidChange(rule)
        }
        
        return sectionController
    }()
    
    init(timePlan: HabitTimePlan?) {
        super.init(style: .insetGrouped)
        self.timePlan = timePlan ?? HabitTimePlan()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Frequency")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        setupActionsBar(actions: [doneAction])
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        updateSectionControllers()
        adapter.reloadData()
    }
    
    override var popoverContentSize: CGSize {
        return CGSize(width: kPopoverPreferredContentWidth, height: 580.0)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let insetBottom = actionsBarHeight
        tableView.contentInset = UIEdgeInsets(bottom: insetBottom)
        updatePopoverContentSize()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        dismiss(animated: true, completion: nil)
        didEndEditing?(timePlan)
    }
    
    // MARK: - Updater
    func updateSectionControllers() {
        var sectionControllers = [infoSectionController, typeSectionController]
        if planType == .regularly {
            sectionControllers.append(regularSectionController)
        } else {
            sectionControllers.append(randomSectionController)
        }
        
        self.sectionControllers = sectionControllers
    }
    
    /// 更新计划描述信息
    func updateInfoCellItem() {
        var info: ASAttributedString?
        if planType == .regularly {
            info = regularRule.localizedAttributedDescription()
        } else {
            info = randomRule.localizedAttributedDescription()
        }
        
        infoCellItem.attributedText = info
    }
    
    /// 更新计划描述信息
    func updatePlanInfo() {
        updateInfoCellItem()
        if let cell = adapter.cellForItem(infoCellItem) as? TPDescriptionTableCell {
            cell.updateDescription()
        }
    }
   
    /// 选中计划类型
    private func didSelectType(_ type: HabitTimePlanType) {
        self.planType = type
        updateSectionControllers()
        updatePlanInfo() /// 更新计划描述信息
        adapter.performUpdate(with: .fade, completion: nil)
    }
    
    private func regularRuleDidChange(_ regularRule: HabitTimePlanRegularRule) {
        updatePlanInfo()
        adapter.performNilUpdate()
    }
    
    private func randomRuleDidChange(_ randomRule: HabitTimePlanRandomRule) {
        updatePlanInfo()
        adapter.performNilUpdate()
    }
}
