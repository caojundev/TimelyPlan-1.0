//
//  RepeatDaysOfTheWeekSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/22.
//

import Foundation

class RepeatDaysOfWeekSectionController: TPTableItemSectionController {
    
    /// 周天数改变回调
    var weekdaysDidChange: (([Weekday]) -> Void)?
    
    /// 定期规则关联的周中的天
    var weekdays: [Weekday] = [Weekday()]
    
    lazy var weekdaysCellItem: RepeatDayOfWeekTableCellItem = {  [weak self] in
        let cellItem = RepeatDayOfWeekTableCellItem()
        cellItem.updater = {
            self?.updateWeekdaysCellItem()
        }
        
        cellItem.daysChangedHandler = { weekdays in
            self?.didSelectWeekdays(Array(weekdays))
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = 10.0
        self.footerItem.height = 0.0
        self.cellItems = [weekdaysCellItem]
    }
    
    // MARK: - Update CellItems
    func updateWeekdaysCellItem() {
        self.weekdaysCellItem.days = Set(weekdays)
    }
    
    func didSelectWeekdays(_ weekdays: [Weekday]) {
        self.weekdays = weekdays
        self.weekdaysDidChange?(weekdays)
    }
}
