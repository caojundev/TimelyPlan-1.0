//
//  TodoFilterRuleProgressEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/27.
//

import Foundation

class TodoFilterRuleProgressEditSectionController: TodoFilterRuleEditBaseSectionController {
    
    var filterValue: TodoProgressFilterValue?
    
    init(rule: TodoFilterRule) {
        super.init(rule: rule, type: .progress)
        self.filterValue = rule.progressFilterValue
    }
    
    override func updateFilterTypeCellItem() {
        if let filterValue = filterValue, filterValue.filterType != nil {
            filterTypeCellItem.isActive = true
            filterTypeCellItem.subtitle = filterValue.description
        } else {
            filterTypeCellItem.isActive = false
            filterTypeCellItem.subtitle = nil
        }
    }

    override func selectFilterType() {
        let vc = TodoFilterProgressEditViewController(filterValue: filterValue)
        vc.didEndEditing = { newValue in
            self.setFilterValue(newValue)
        }

        vc.showAsNavigationRoot()
    }
    
    override func clickDelete() {
        setFilterValue(nil)
    }
    
    private func setFilterValue(_ value: TodoProgressFilterValue?) {
        guard filterValue != value else {
            return
        }
        
        filterValue = value
        filterRule.progressFilterValue = value
        reloadFilterTypeCell()
        ruleDidChange()
    }
}
