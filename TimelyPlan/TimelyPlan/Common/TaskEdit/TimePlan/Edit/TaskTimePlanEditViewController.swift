//
//  TaskTimePlanEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/4.
//

import Foundation
import UIKit

class TaskTimePlanEditViewController: TPTableSectionsViewController {

    /// 结束编辑回调
    var didEndEditing: ((TaskTimePlanRegularRule) -> Void)?
    
    var regularRule: TaskTimePlanRegularRule {
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
    lazy var regularSectionController: TaskTimePlanRegularSectionController = { [weak self] in
        let sectionController = TaskTimePlanRegularSectionController()
        sectionController.headerItem.height = 10.0
        sectionController.ruleDidChange = { [weak self] rule in
            self?.regularRuleDidChange(rule)
        }
        
        return sectionController
    }()
    
    init(regularRule: TaskTimePlanRegularRule?) {
        super.init(style: .insetGrouped)
        self.regularRule = regularRule ?? TaskTimePlanRegularRule()
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
        didEndEditing?(regularRule)
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
    
    private func regularRuleDidChange(_ regularRule: TaskTimePlanRegularRule) {
        updatePlanInfo()
        adapter.performNilUpdate()
    }
}
