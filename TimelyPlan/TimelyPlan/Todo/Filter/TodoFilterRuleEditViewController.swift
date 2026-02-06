//
//  TodoFilterRuleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/23.
//

import Foundation
import UIKit

class TodoFilterRuleEditViewController: TPTableSectionsViewController,
                                            TPTableSectionControllerDelegate,
                                            TodoFilterRuleEditSectionControllerDelegate {
    
    var didEndEditing: ((TodoFilterRule) -> Void)?
    
    lazy var dateSectionController: TodoFilterRuleDateEditSectionController = {
        let sectionController = TodoFilterRuleDateEditSectionController(rule: rule)
        sectionController.delegate = self
        return sectionController
    }()
    
    lazy var listSectionController: TodoFilterRuleListEditSectionController = {
        let sectionController = TodoFilterRuleListEditSectionController(rule: rule)
        sectionController.delegate = self
        return sectionController
    }()
    
    lazy var prioritySectionController: TodoFilterRulePriorityEditSectionController = {
        let sectionController = TodoFilterRulePriorityEditSectionController(rule: rule)
        sectionController.delegate = self
        return sectionController
    }()
    
    lazy var tagSectionController: TodoFilterRuleTagEditSectionController = {
        let sectionController = TodoFilterRuleTagEditSectionController(rule: rule)
        sectionController.delegate = self
        return sectionController
    }()
    
    lazy var myDaySectionController: TodoFilterRuleMyDayEditSectionController = {
        let sectionController = TodoFilterRuleMyDayEditSectionController(rule: rule)
        sectionController.delegate = self
        return sectionController
    }()

    lazy var progressSectionController: TodoFilterRuleProgressEditSectionController = {
        let sectionController = TodoFilterRuleProgressEditSectionController(rule: rule)
        sectionController.delegate = self
        return sectionController
    }()
    
    private(set) var rule: TodoFilterRule
    
    init(rule: TodoFilterRule?) {
        if let rule = rule {
            self.rule = rule.copy() as! TodoFilterRule
        } else {
            self.rule = TodoFilterRule()
        }
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        setupSectionControllers()
        reloadData()
    }

    func setupSectionControllers() {
        self.sectionControllers = [dateSectionController,
                                   listSectionController,
                                   prioritySectionController,
                                   tagSectionController,
                                   progressSectionController,
                                   myDaySectionController]
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func reloadData() {
        super.reloadData()
    }
    
    override func clickDone() {
        super.clickDone()
        didEndEditing?(rule)
    }
    
    // MARK: - TodoFilterRuleEditSectionControllerDelegate
    func sectionController(_ sectionController: TodoFilterRuleEditBaseSectionController,
                           didChangeFilterRule rule: TodoFilterRule,
                           with filterType: TodoFilterType) {
    }
}
