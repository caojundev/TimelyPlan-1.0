//
//  TodoFilterRulePriorityEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/31.
//

import Foundation

class TodoFilterRulePriorityEditSectionController: TodoFilterRuleEditBaseSectionController {
    
    var filterValue: TodoPriorityFilterValue?

    init(rule: TodoFilterRule) {
        super.init(rule: rule, type: .priority)
        self.filterValue = rule.priorityFilterValue
    }
    
    override func updateFilterTypeCellItem() {
        if let filterValue = filterValue {
            filterTypeCellItem.isActive = true
            filterTypeCellItem.subtitle = filterValue.description
        } else {
            filterTypeCellItem.isActive = false
            filterTypeCellItem.subtitle = nil
        }
    }

    override func selectFilterType() {
        let priorities = filterValue?.priorities ?? []
        let vc = TodoFilterPriorityEditViewController(priorities: Set(priorities))
        vc.didEndEditing = { newPriorities in
            self.selectPriorities(newPriorities)
        }
        
        vc.showAsNavigationRoot()
    }
    
    private func selectPriorities(_ priorities: Set<TodoTaskPriority>?) {
        guard let priorities = priorities, priorities.count > 0 else {
            setFilterValue(nil)
            return
        }

        let value = TodoPriorityFilterValue(priorities: Array(priorities))
        setFilterValue(value)
    }
    
    override func clickDelete() {
        setFilterValue(nil)
    }
    
    private func setFilterValue(_ value: TodoPriorityFilterValue?) {
        guard filterValue != value else {
            return
        }
        
        filterValue = value
        filterRule.priorityFilterValue = value
        reloadFilterTypeCell()
        ruleDidChange()
    }
}
