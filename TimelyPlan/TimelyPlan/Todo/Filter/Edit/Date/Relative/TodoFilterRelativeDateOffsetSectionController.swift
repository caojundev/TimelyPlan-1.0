//
//  TodoFilterRelativeDateOffsetSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/2.
//

import Foundation

class TodoFilterRelativeDateOffsetSectionController: TPTableItemSectionController {
    
    /// 任务日期改变
    var didChangeDateOffset: ((TodoRelativeDateOffset) -> Void)?
     
    lazy var directionCellItem: TPFullSizeSegmentedMenuTableCellItem = {
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = TodoRelativeDateOffset.Direction.segmentedMenuItems()
        cellItem.updater = { [weak self] in
            self?.updateDirectionCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let direction: TodoRelativeDateOffset.Direction? = menuItem.actionType()
            if let direction = direction {
                self?.selectDirection(direction)
            }
        }
        
        return cellItem
    }()
    
    lazy var quantityCellItem: TPCountPickerTableCellItem = {
        let cellItem = TPCountPickerTableCellItem()
        cellItem.minimumCount = TodoRelativeDateOffset.minimumAmount
        cellItem.maximumCount = TodoRelativeDateOffset.maximumAmount
        cellItem.updater = { [weak self] in
            self?.updateQuantityCellItem()
        }
        
        cellItem.didPickCount = { [weak self] count in
            self?.selectQuantity(count)
        }
        
        return cellItem
    }()
    
    lazy var timeUnitCellItem: TPFullSizeSegmentedMenuTableCellItem = {
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = TPSegmentedMenuItem.items(with: TodoRelativeDateOffset.permittedUnits)
        cellItem.updater = { [weak self] in
            self?.updateTimeUnitCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let unit: TimeUnit? = menuItem.actionType()
            if let unit = unit {
                self?.selectTimeUnit(unit)
            }
        }
        
        return cellItem
    }()
    
    private(set) var dateOffset: TodoRelativeDateOffset
    
    init(dateOffset: TodoRelativeDateOffset?) {
        self.dateOffset = dateOffset ?? TodoRelativeDateOffset()
        super.init()
        self.headerItem.height = 10.0
        self.footerItem.height = 0.0
    }
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            let direction = dateOffset.direction
            if direction != .current {
                return [directionCellItem, quantityCellItem, timeUnitCellItem]
            } else {
                return [directionCellItem, timeUnitCellItem]
            }
        }
        
        set {}
    }

    // MARK: - Update CellItems
    
    func updateTimeUnitCellItem() {
        let timeUnit = dateOffset.getTimeUnit()
        timeUnitCellItem.selectedMenuTag = timeUnit.rawValue
    }
    
    func updateQuantityCellItem() {
        let quantity = dateOffset.getAmount()
        let timeUnit = dateOffset.getTimeUnit()
        quantityCellItem.count = quantity
        quantityCellItem.tailingTextForCount = { count in
            return timeUnit.localizedUnit(for: count)
        }
    }
 
    private func updateDirectionCellItem() {
        let direction = dateOffset.getDirection()
        directionCellItem.selectedMenuTag = direction.rawValue
    }
    
    private func selectDirection(_ direction: TodoRelativeDateOffset.Direction) {
        dateOffset.direction = direction
        if direction == .current {
            /// 选中当前周期，数目设置为1
            dateOffset.amount = 1
        }
        
        adapter?.performUpdate(with: .fade, completion: nil)
        adapter?.reloadCell(forItem: quantityCellItem, with: .none)
        didChangeDateOffset?(dateOffset)
    }
    
    func selectTimeUnit(_ timeUnit: TimeUnit) {
        dateOffset.unit = timeUnit
        adapter?.performUpdate(with: .fade, completion: nil)
        adapter?.reloadCell(forItem: quantityCellItem, with: .none)
        didChangeDateOffset?(dateOffset)
    }

    func selectQuantity(_ quantity: Int) {
        dateOffset.amount = quantity
        didChangeDateOffset?(dateOffset)
    }
}
