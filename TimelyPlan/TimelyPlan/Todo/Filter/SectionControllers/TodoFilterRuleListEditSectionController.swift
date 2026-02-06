//
//  TodoFilterRuleListEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/27.
//

import Foundation

class TodoFilterRuleListEditSectionController: TodoFilterRuleEditBaseSectionController {
    
    var filterValue: TodoListFilterValue? {
        didSet {
            updateValueDescription()
        }
    }
    
    private var valueDescription: String?
    
    init(rule: TodoFilterRule) {
        super.init(rule: rule, type: .list)
        self.filterValue = rule.listFilterValue
        self.updateValueDescription()
    }
    
    override func updateFilterTypeCellItem() {
        if filterValue != nil {
            filterTypeCellItem.isActive = true
            filterTypeCellItem.subtitle = valueDescription
        } else {
            filterTypeCellItem.isActive = false
            filterTypeCellItem.subtitle = nil
        }
    }

    override func selectFilterType() {
        let vc = TodoFilterListEditViewController(filterValue: filterValue)
        vc.didEndEditing = { value in
            self.setFilterValue(value)
        }
        
        vc.showAsNavigationRoot()
    }
    
    override func clickDelete() {
        setFilterValue(nil)
    }
    
    private func setFilterValue(_ value: TodoListFilterValue?) {
        guard filterValue != value else {
            return
        }
        
        filterValue = value
        filterRule.listFilterValue = value
        reloadFilterTypeCell()
        ruleDidChange()
    }
    
    private func updateValueDescription() {
        guard let filterValue = filterValue else {
            self.valueDescription = nil
            return
        }

        self.valueDescription = filterValue.description
    }
}
