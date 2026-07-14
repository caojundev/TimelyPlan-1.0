//
//  DateFrequencySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/2.
//

import Foundation

class DateFrequencySectionController: TPTableItemSectionController {
    
    var dateRange: DateRange = DateRange()
    
    var timePlan: HabitTimePlan = HabitTimePlan()
    
    var dateRangeDidChange: ((DateRange) -> Void)?
    
    var timePlanDidChange: ((HabitTimePlan) -> Void)?
    
    let defaultCellHeight = 55.0
    
    /// 开始日期
    lazy var dateRangeCellItem: HabitDateRangeEditTableCellItem = { [weak self] in
        let cellItem = HabitDateRangeEditTableCellItem()
        cellItem.updater = {
            guard let self = self else { return}
            self.dateRangeCellItem.dateRange = self.dateRange
        }
        
        cellItem.didEndEditing = { dateRange in
            self?.dateRange = dateRange
            self?.dateRangeDidChange?(dateRange)
        }
        
        return cellItem
    }()
    
    /// 频率
    lazy var frequencyCellItem: TPImageInfoTableCellItem = {  [weak self] in
        let cellItem = TPImageInfoTableCellItem()
        cellItem.autoResizable = true
        cellItem.minimumHeight = defaultCellHeight
        cellItem.subtitleConfig.numberOfLines = 0
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Frequency")
        cellItem.updater = {
            guard let self = self else { return }
            self.frequencyCellItem.title = self.timePlan.title
            self.frequencyCellItem.subtitle = self.timePlan.subtitle
        }
    
        cellItem.didSelectHandler = {
            self?.editFrequency()
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [dateRangeCellItem, frequencyCellItem]
    }

    // MARK: - Edit
    func editFrequency() {
        let vc = HabitTimePlanEditViewController(timePlan: timePlan)
        vc.didEndEditing = { timePlan in
            self.timePlan = timePlan
            self.timePlanDidChange?(timePlan)
            self.adapter?.reloadCell(forItem: self.frequencyCellItem, with: .none)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
}
