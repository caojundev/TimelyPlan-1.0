//
//  TodoFilterProgressSpecificSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/2.
//

import Foundation

enum TodoFilterProgressSpecificValueType: Int, TPMenuRepresentable {
    case any = 0
    case specific
    
    var title: String {
        switch self {
        case .any:
            return resGetString("Any")
        case .specific:
            return resGetString("Specific")
        }
    }
}

class TodoFilterProgressSpecificSectionController: TPTableItemSectionController {
    
    var didChangeValueType: ((TodoFilterProgressSpecificValueType) -> Void)?
    
    var didChangeSpecificValue: ((TodoProgressFilterSpecificValue) -> Void)?
    
    /// 类型单元格
    lazy var typeCellItem: TPFullSizeSegmentedMenuTableCellItem = {
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = TodoFilterProgressSpecificValueType.segmentedMenuItems()
        cellItem.updater = { [weak self] in
            self?.updateTypeCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let type: TodoFilterProgressSpecificValueType = menuItem.actionType()!
            self?.selectSpecificValueType(type)
        }
        
        return cellItem
    }()
    
    lazy var operatorCellItem: TPDefaultInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.height = 50.0
        cellItem.title = resGetString("Comparison Operator")
        cellItem.updater = {
            self?.updateOperatorCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editComparisonOperator()
        }
        
        return cellItem
    }()
    
    lazy var valueCellItem: TPDefaultInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.height = 50.0
        cellItem.title = resGetString("Percentage Value")
        cellItem.updater = {
            self?.updateValueCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editPercentageValue()
        }
        
        return cellItem
    }()
    
    private(set) var specificValue: TodoProgressFilterSpecificValue
    
    private(set) var valueType: TodoFilterProgressSpecificValueType
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var cellItems: [TPBaseTableCellItem] = [typeCellItem]
            if valueType == .specific {
                cellItems.append(contentsOf: [operatorCellItem, valueCellItem])
            }
            
            return cellItems
        }
        
        set {}
    }
    
    init(specificValue: TodoProgressFilterSpecificValue?) {
        if let specificValue = specificValue {
            self.valueType = .specific
            self.specificValue = specificValue
        } else {
            self.valueType = .any
            self.specificValue = TodoProgressFilterSpecificValue()
        }
        
        super.init()
        self.headerItem.height = 10.0
    }
    
    private func updateTypeCellItem() {
        typeCellItem.selectedMenuTag = valueType.rawValue
    }
    
    private func updateOperatorCellItem() {
        let op = specificValue.getComparisonOperator()
        operatorCellItem.valueConfig = .valueText(op.title, textColor: .primary)
    }
    
    private func updateValueCellItem() {
        let percentageValue = specificValue.getPercentage()
        valueCellItem.valueConfig = .valueText("\(percentageValue)%", textColor: .primary)
    }
    
    private func selectSpecificValueType(_ type: TodoFilterProgressSpecificValueType) {
        valueType = type
        didChangeValueType?(type)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    private func editComparisonOperator() {
        guard let cell = adapter?.cellForItem(operatorCellItem) else {
            return
        }
        
        let currentOperator = self.specificValue.getComparisonOperator()
        let menuItem = TPMenuItem.item(with: TodoProgressFilterSpecificValue.ComparisonOperator.allCases) { op, action in
            action.handleBeforeDismiss = true
            if op == currentOperator {
                action.isChecked = true
            }
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = 240.0
        menuList.menuItems = [menuItem]
        menuList.didSelectMenuAction = { action in
            let op: TodoProgressFilterSpecificValue.ComparisonOperator? = action.actionType()
            if let op = op {
                self.selectComparisonOperator(op)
            }
        }

        popoverShow(menuList, from: cell)
    }
    
    private func selectComparisonOperator(_ op: TodoProgressFilterSpecificValue.ComparisonOperator) {
        guard specificValue.comparisonOperator != op else {
            return
        }
        
        specificValue.comparisonOperator = op
        adapter?.reloadCell(forItem: operatorCellItem, with: .none)
        didChangeSpecificValue?(specificValue)
    }
    
    private func editPercentageValue() {
        guard let cell = adapter?.cellForItem(valueCellItem) else {
            return
        }
        
        let vc = TPSliderViewController()
        vc.value = Float(specificValue.getPercentage())
        vc.didChangeValue = { value in
            self.percentageValueChanged(Int(value))
        }
        
        popoverShow(vc, from: cell)
    }
    
    private func percentageValueChanged(_ value: Int) {
        guard specificValue.percentage != value else {
            return
        }
        
        specificValue.percentage = value
        updateValueCellItem()
        if let cell = adapter?.cellForItem(valueCellItem) as? TPDefaultInfoTextValueTableCell {
            cell.updateValueConfig()
        }
        
        didChangeSpecificValue?(specificValue)
    }
}
