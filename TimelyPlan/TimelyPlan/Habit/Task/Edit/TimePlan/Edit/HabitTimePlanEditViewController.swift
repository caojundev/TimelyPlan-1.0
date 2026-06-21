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
            return HabitTimePlan(regularRule: regularRule)
        }
        
        set {
            self.regularRule = newValue.regularRule ?? HabitTimePlanRegularRule()
        }
    }
    
    var regularRule: HabitTimePlanRegularRule {
        get {
            return self.regularSectionController.rule
        }
        
        set {
            self.regularSectionController.rule = newValue
        }
    }
    
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
        cellItem.minimumHeight = 40.0
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
        self.setupActionsBar(actions: [doneAction])
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [infoSectionController, regularSectionController]
        self.adapter.reloadData()
    }
    
    override var popoverContentSize: CGSize {
        return CGSize(width: AppLayout.Popover.preferredContentWidth, height: 580.0)
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
    
    /// 更新计划描述信息
    func updateInfoCellItem() {
        let info = regularRule.localizedAttributedDescription()
        infoCellItem.attributedText = info
    }
    
    /// 更新计划描述信息
    func updatePlanInfo() {
        updateInfoCellItem()
        if let cell = adapter.cellForItem(infoCellItem) as? TPDescriptionTableCell {
            cell.updateDescription()
        }
    }
    
    private func regularRuleDidChange(_ regularRule: HabitTimePlanRegularRule) {
        updatePlanInfo()
        adapter.performNilUpdate()
    }
}
