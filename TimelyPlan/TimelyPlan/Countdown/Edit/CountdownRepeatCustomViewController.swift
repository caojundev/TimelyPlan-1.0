//
//  CountdownRepeatCustomViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation
import UIKit

class CountdownRepeatCustomViewController: TPTableSectionsViewController {
    
    /// 结束编辑规则回调
    var didEndEditing: ((TaskTimePlanRegularRule) -> Void)?
    
    /// 描述信息区块
    lazy var infoSectionController: TPTableItemSectionController = {
        let sectionItem = TPTableItemSectionController()
        sectionItem.headerItem.height = 10.0
        sectionItem.footerItem.height = 0.0
        sectionItem.cellItems = [infoCellItem]
        return sectionItem
    }()
    
    /// 描述信息单元格
    lazy var infoCellItem: TPDescriptionTableCellItem = {
        let cellItem = TPDescriptionTableCellItem()
        cellItem.updater = { [weak self] in
            self?.updateInfoCellItem()
        }
        
        cellItem.selectionStyle = .none
        cellItem.height = 45.0
        return cellItem
    }()
    
    lazy var frequencySectionController: RepeatFrequencySectionController = { [weak self] in
        let sectionItem = RepeatFrequencySectionController()
        sectionItem.frequencyDidChange = { _ in
            self?.ruleEditingChanged()
        }
        
        sectionItem.intervalDidChange = { _ in
            self?.ruleEditingChanged()
        }
        
        return sectionItem
    }()
    
    init(rule: TaskTimePlanRegularRule?) {
        super.init(style: .insetGrouped)
        guard let rule = rule else {
            return
        }
        
        self.frequencySectionController.frequency = rule.frequency
        self.frequencySectionController.interval = rule.interval
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Custom Repeat")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.preferredContentSize = .Popover.extraLarge
        self.tableView.showsVerticalScrollIndicator = false
        setupActionsBar(actions: [doneAction])
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        sectionControllers = [infoSectionController, frequencySectionController]
        adapter.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        wrapperView.height = layoutFrame.maxY - actionsBarHeight
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override func clickDone() {
        self.didEndEditing?(recurrenceRule)
        dismiss(animated: true, completion: nil)
    }
    
    /// 更新计划描述信息
    func updateInfoCellItem() {
        infoCellItem.attributedText = recurrenceRule.localizedAttributedDescription()
    }
    
    // MARK: - Edit
    var recurrenceRule: TaskTimePlanRegularRule {
        let frequency = frequencySectionController.frequency
        let interval = frequencySectionController.interval
        return TaskTimePlanRegularRule(frequency: frequency, interval: interval)
    }
    
    func ruleEditingChanged() {
        updateInfoCellItem()
        if let cell = adapter.cellForItem(infoCellItem) as? TPDescriptionTableCell {
            cell.updateDescription()
        }
        
        adapter.performNilUpdate()
    }

}

