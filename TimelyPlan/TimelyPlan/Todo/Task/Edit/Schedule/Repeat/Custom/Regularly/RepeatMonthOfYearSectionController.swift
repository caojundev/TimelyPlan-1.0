//
//  RepeatMonthOfYearSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/22.
//

import Foundation

class RepeatMonthOfYearSectionController: TPTableItemSectionController {
    
    /// 选中月份回调
    var monthsOfTheYearChanged: (([Int]) -> Void)?
    
    var monthsOfTheYear: [Int] = [Date().month]
    
    lazy var monthsOfYearCellItem: RepeatMonthOfYearTableCellItem = {
        let cellItem = RepeatMonthOfYearTableCellItem()
        cellItem.updater = { [weak self] in
            self?.updateMonthsOfYearCellItem()
        }
        
        cellItem.monthsOfTheYearChanged = { [weak self] monthsOfTheYear in
            self?.monthsOfTheYear = monthsOfTheYear
            self?.updateMonthsOfYearCellItem()
            self?.monthsOfTheYearChanged?(monthsOfTheYear)
        }

        return cellItem
    }()

    override init() {
        super.init()
        self.headerItem.height = 10.0
        self.footerItem.height = 0.0
        self.cellItems = [monthsOfYearCellItem]
    }
    
    func updateMonthsOfYearCellItem() {
        monthsOfYearCellItem.monthsOfTheYear = monthsOfTheYear
    }
    
    func didSelectMonths(_ months: [Int]) {
        self.monthsOfTheYear = months
    }
    
}
