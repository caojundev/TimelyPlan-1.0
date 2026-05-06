//
//  QuadrantCustomRuleViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/22.
//

import Foundation
import UIKit

class QuadrantCustomRuleViewController: TPTableSectionsViewController {

    var didEndEditing: (([Quadrant: TodoFilterRule]) -> Void)?
    
    // 紧急且重要象限的单元格项
    private lazy var urgentImportantCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = newCellItem(with: .urgentImportant)
        return cellItem
    }()
    
    // 不紧急但重要象限的单元格项
    private lazy var notUrgentImportantCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = newCellItem(with: .notUrgentImportant)
        return cellItem
    }()
    
    // 紧急但不重要象限的单元格项
    private lazy var urgentNotImportantCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = newCellItem(with: .urgentNotImportant)
        return cellItem
    }()
    
    // 不紧急且不重要象限的单元格项
    private lazy var notUrgentNotImportantItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = newCellItem(with: .notUrgentNotImportant)
        return cellItem
    }()
    
    private lazy var sectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 10.0
        sectionController.cellItems = [urgentImportantCellItem,
                                       notUrgentImportantCellItem,
                                       urgentNotImportantCellItem,
                                       notUrgentNotImportantItem]
        return sectionController
    }()
    
    private(set) var filterRules: [Quadrant: TodoFilterRule]
    
    init(filterRules: [Quadrant: TodoFilterRule]) {
        self.filterRules = filterRules
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Custom Rule")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        setupActionsBar(actions: [doneAction])
        sectionControllers = [sectionController]
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        super.clickDone()
        didEndEditing?(filterRules)
    }

    private func editFilterRule(for quadrant: Quadrant) {
        let rule = filterRule(for: quadrant)
        let vc = QuadrantFilterRuleEditViewController(quadrant: quadrant, rule: rule)
        vc.didEndEditing = { rule in
            self.changeEditingRule(rule, for: quadrant)
        }
        
        vc.showAsNavigationRoot()
    }
    
    private func changeEditingRule(_ rule: TodoFilterRule, for quadrant: Quadrant) {
        guard filterRules[quadrant] != rule else {
            return
        }
        
        if rule.isValid {
            filterRules[quadrant] = rule
        } else {
            filterRules[quadrant] = .defaultFilterRule(for: quadrant)
        }
        
        let cellItem = cellItem(for: quadrant)
        adapter.reloadCell(forItem: cellItem, with: .none)
    }
    
    private func updateCellItem(for quadrant: Quadrant) {
        let rule = filterRule(for: quadrant)
        let cellItem = cellItem(for: quadrant)
        cellItem.subtitle = rule.attributedDescription
    }
    
    private func filterRule(for quadrant: Quadrant) -> TodoFilterRule {
        if let rule = filterRules[quadrant], rule.isValid {
            return rule
        }
        
        return .defaultFilterRule(for: quadrant)
    }
    
    // MARK: - Helpers
    private func cellItem(for quadrant: Quadrant) -> TPImageInfoTextValueTableCellItem {
        switch quadrant {
        case .urgentImportant:
            return urgentImportantCellItem
        case .notUrgentImportant:
            return notUrgentImportantCellItem
        case .urgentNotImportant:
            return urgentNotImportantCellItem
        case .notUrgentNotImportant:
            return notUrgentNotImportantItem
        }
    }
    
    private func newCellItem(with quadrant: Quadrant) -> TPImageInfoTextValueTableCellItem {
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = true
        cellItem.minimumHeight = 55.0
        cellItem.identifier = quadrant.rawValue
        cellItem.imageName = quadrant.iconName
        cellItem.imageColor = quadrant.color
        cellItem.title = quadrant.title
        cellItem.subtitleConfig.numberOfLines = 2
        cellItem.subtitleConfig.font = UIFont.boldSystemFont(ofSize: 10.0)
        cellItem.updater = { [weak self] in
            self?.updateCellItem(for: quadrant)
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editFilterRule(for:quadrant)
        }
        
        return cellItem
    }
}
