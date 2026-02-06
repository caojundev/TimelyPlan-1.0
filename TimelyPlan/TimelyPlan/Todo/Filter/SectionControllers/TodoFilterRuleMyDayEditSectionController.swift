//
//  TodoFilterRuleMyDayEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/26.
//

import Foundation

class TodoFilterRuleMyDayEditSectionController: TodoFilterRuleEditBaseSectionController {
    
    var filterValue: TodoMyDayFilterValue?
    
    init(rule: TodoFilterRule) {
        super.init(rule: rule, type: .myDay)
        self.filterValue = rule.myDayFilterValue
    }
    
    override func updateFilterTypeCellItem() {
        if let filterValue = filterValue {
            filterTypeCellItem.isActive = true
            filterTypeCellItem.subtitle = filterValue.title
        } else {
            filterTypeCellItem.isActive = false
            filterTypeCellItem.subtitle = nil
        }
    }

    override func selectFilterType() {
        guard let cell = filterTypeCell else {
            return
        }
        
        let menuItem = TPMenuItem.item(with: TodoMyDayFilterValue.allCases) { value, action in
            action.handleBeforeDismiss = true
            if value == self.filterValue {
                action.isChecked = true
            }
        }

        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = 180.0
        menuList.menuItems = [menuItem]
        menuList.didSelectMenuAction = { action in
            self.selectMenuAction(action)
        }

        popoverShow(menuList, from: cell, position: .left)
    }
    
    func selectMenuAction(_ action: TPMenuAction) {
        let value: TodoMyDayFilterValue? = action.actionType()
        setFilterValue(value)
    }
    
    override func clickDelete() {
        setFilterValue(nil)
    }
    
    private func setFilterValue(_ value: TodoMyDayFilterValue?) {
        guard filterValue != value else {
            return
        }
        
        filterValue = value
        filterRule.myDayFilterValue = value
        reloadFilterTypeCell()
        ruleDidChange()
    }
    
}
