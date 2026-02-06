//
//  TodoFilterRuleTagEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/27.
//

import Foundation
import UIKit

class TodoFilterRuleTagEditSectionController: TodoFilterRuleEditBaseSectionController {

    var filterValue: TodoTagFilterValue? {
        didSet {
            updateValueDescription()
        }
    }
    
    private var valueDescription: String?
    
    init(rule: TodoFilterRule) {
        super.init(rule: rule, type: .tag)
        self.filterValue = rule.tagFilterValue
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
        let vc = TodoFilterTagEditViewController(filterValue: filterValue)
        vc.didEndEditing = { value in
            self.setFilterValue(value)
        }
        
        vc.showAsNavigationRoot()
    }
    
    override func clickDelete() {
        setFilterValue(nil)
    }
    
    private func setFilterValue(_ value: TodoTagFilterValue?) {
        guard filterValue != value else {
            return
        }
        
        filterValue = value
        filterRule.tagFilterValue = value
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
