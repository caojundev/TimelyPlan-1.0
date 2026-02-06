//
//  TodoFilterRuleDateEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/2.
//

import Foundation

class TodoFilterRuleDateEditSectionController: TodoFilterRuleEditBaseSectionController {
    
    var filterValue: TodoDateFilterValue?
    
    init(rule: TodoFilterRule) {
        super.init(rule: rule, type: .date)
        self.filterValue = rule.dateFilterValue
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
        let vc = TodoFilterDateEditViewController(filterValue: filterValue)
        vc.didEndEditing = { newValue in
            self.setFilterValue(newValue)
        }

        vc.showAsNavigationRoot()
    }
    
    override func clickDelete() {
        setFilterValue(nil)
    }
    
    private func setFilterValue(_ value: TodoDateFilterValue?) {
        guard filterValue != value else {
            return
        }
        
        filterValue = value
        filterRule.dateFilterValue = value
        reloadFilterTypeCell()
        ruleDidChange()
    }
}
