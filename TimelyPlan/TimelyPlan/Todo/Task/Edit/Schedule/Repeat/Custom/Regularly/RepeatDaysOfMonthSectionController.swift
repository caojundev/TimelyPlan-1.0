//
//  RepeatDaysOfMonthSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/22.
//

import Foundation

class RepeatDaysOfMonthSectionController: TPTableItemSectionController {

    /// 周天数改变回调
    var daysOfTheMonthDidChange: (([Int]?) -> Void)?
    
    /// 按周模式下，周重复日改变回调
    var dayOfTheWeekDidChange: ((RepeatDayOfWeek) -> Void)?
    
    /// 月重复模式改变回调
    var monthlyModeDidChange: ((RepeatMonthlyMode) -> Void)?
    
    /// 月重复模式
    var monthlyMode: RepeatMonthlyMode = .onDays
    
    /// 定期规则关联的月份中的天（1～31，-1表示最后一天）
    var daysOfTheMonth: [Int] = [Date().day]
    
    var dayOfTheWeek: RepeatDayOfWeek = RepeatDayOfWeek(dayOfTheWeek: .monday, weekNumber: RepeatWeekNumber.first.rawValue)
    
    /// 月重复模式
    lazy var monthlyModeCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = RepeatMonthlyMode.segmentedMenuItems()
        cellItem.updater = {
            self?.updateMonthlyModeCellItem()
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            let mode: RepeatMonthlyMode? = menuItem.actionType()
            if let mode = mode {
                self?.selectMonthlyMode(mode)
            }
        }
        
        return cellItem
    }()
    
    lazy var daysOfMonthCellItem: RepeatDayOfMonthTableCellItem = { [weak self] in
        let cellItem = RepeatDayOfMonthTableCellItem()
        cellItem.updater = {
            self?.updateDaysOfMonthCellItem()
        }
        
        cellItem.didSelectDaysOfMonth = { days in
            self?.selectDaysOfTheMonth(Array(days))
        }
        
        return cellItem
    }()
    
    lazy var weekdayOfMonthCellItem: RepeatWeekdayOfMonthTableCellItem = { [weak self] in
        let cellItem = RepeatWeekdayOfMonthTableCellItem()
        cellItem.updater = {
            self?.updateWeekdayOfMonthCellItem()
        }
        
        cellItem.didPickDayOfTheWeek = { dayOfTheWeek in
            self?.pickDayOfTheWeek(dayOfTheWeek)
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = 10.0
        self.footerItem.height = 0.0
    }
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var cellItems: [TPBaseTableCellItem] = [monthlyModeCellItem]
            if monthlyMode == .onDays {
                cellItems.append(daysOfMonthCellItem)
            } else {
                cellItems.append(weekdayOfMonthCellItem)
            }
            
            return cellItems
        }
        
        set {}
    }
    
    // MARK: - Update CellItems
    func updateMonthlyModeCellItem() {
        monthlyModeCellItem.selectedMenuTag = monthlyMode.rawValue
    }
    
    func updateDaysOfMonthCellItem() {
        daysOfMonthCellItem.days = Set(daysOfTheMonth)
    }
    
    func updateWeekdayOfMonthCellItem() {
        weekdayOfMonthCellItem.dayOfTheWeek = dayOfTheWeek
    }

    func selectMonthlyMode(_ mode: RepeatMonthlyMode) {
        self.monthlyMode = mode
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade)
        self.monthlyModeDidChange?(mode)
    }
    
    func selectDaysOfTheMonth(_ days: [Int]) {
        self.daysOfTheMonth = days
        self.daysOfTheMonthDidChange?(days)
    }
    
    func pickDayOfTheWeek(_ dayOfTheWeek: RepeatDayOfWeek) {
        self.dayOfTheWeek = dayOfTheWeek
        self.dayOfTheWeekDidChange?(dayOfTheWeek)
    }
    
}
