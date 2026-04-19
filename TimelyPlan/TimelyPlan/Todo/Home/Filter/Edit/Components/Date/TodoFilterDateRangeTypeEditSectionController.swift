//
//  TodoFilterDateRangeTypeEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/2.
//

import Foundation

class TodoFilterDateRangeTypeEditSectionController: TPTableItemSectionController {
    
    var didSelectRangeType: ((TodoDateFilterValue.RangeType) -> Void)?

    lazy var typeCellItem: TPFullSizeSegmentedMenuTableCellItem = {
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = TodoDateFilterValue.RangeType.segmentedMenuItems()
        cellItem.updater = { [weak self] in
            self?.updateTypeCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let type: TodoDateFilterValue.RangeType? = menuItem.actionType()
            if let type = type {
                self?.selectRangeType(type)
            }
        }
        
        return cellItem
    }()

    private(set) var rangeType: TodoDateFilterValue.RangeType
    
    init(rangeType: TodoDateFilterValue.RangeType) {
        self.rangeType = rangeType
        super.init()
        self.headerItem.height = 10.0
        self.cellItems = [typeCellItem]
    }
    
    private func updateTypeCellItem() {
        typeCellItem.selectedMenuTag = rangeType.rawValue
    }
    
    private func selectRangeType(_ type: TodoDateFilterValue.RangeType) {
        rangeType = type
        didSelectRangeType?(type)
    }
}
