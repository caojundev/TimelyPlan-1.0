//
//  HabitDateFrequencySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/2.
//

import Foundation

class HabitDateFrequencySectionController: TPTableItemSectionController {
    
    var dateRange: DateRange = DateRange()
    
    var timePlan: HabitTimePlan = HabitTimePlan()
    
    var dateRangeDidChange: ((DateRange) -> Void)?
    
    var timePlanDidChange: ((HabitTimePlan) -> Void)?
    
    private let defaultCellHeight = 55.0
    
    /// 开始日期
    lazy var startDateCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = true
        cellItem.minimumHeight = defaultCellHeight
        cellItem.title = resGetString("Start Date")
        cellItem.updater = {
            guard let self = self else { return }
            self.startDateCellItem.subtitle = self.dateRange.startDateText()
            self.startDateCellItem.valueConfig = .valueText(self.dateRange.startDateDescription())
        }
        
        cellItem.didSelectHandler = {
            self?.editDateRangeWithType(.start)
        }
        
        return cellItem
    }()
    
    /// 结束日期
    lazy var endDateCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = true
        cellItem.minimumHeight = defaultCellHeight
        cellItem.title = resGetString("End Date")
        cellItem.updater = {
            guard let self = self else { return }
            self.endDateCellItem.subtitle = self.dateRange.endDateText()
            self.endDateCellItem.valueConfig = .valueText(self.dateRange.lastsCountDescription())
        }
        
        cellItem.didSelectHandler = {
            self?.editDateRangeWithType(.end)
        }
        
        return cellItem
    }()
    
    /// 频率
    lazy var frequencyCellItem: TPDefaultInfoTableCellItem = {  [weak self] in
        let cellItem = TPDefaultInfoTableCellItem(autoResizable: true)
        cellItem.minimumHeight = defaultCellHeight
        cellItem.titleConfig.font = .boldSystemFont(ofSize: 16.0)
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
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var cellItems: [TPBaseTableCellItem] = []
            cellItems.append(startDateCellItem)
            if dateRange.endDate != nil {
                cellItems.append(endDateCellItem)
            }
            
            cellItems.append(frequencyCellItem)
            return cellItems
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.headerItem.title = resGetString("Date And Frequency")
    }

    // MARK: - Edit
    func editDateRangeWithType(_ type: DateRangeEditType) {
        let vc = HabitDateRangeEditViewController(dateRange: dateRange,
                                                  editType: type)
        vc.didEndEditing = { dateRange in
            self.dateRange = dateRange
            self.dateRangeDidChange?(dateRange)
            self.adapter?.performUpdate(completion: nil)
            self.adapter?.reloadCell(forItems: [self.startDateCellItem,
                                                self.endDateCellItem], with: .none)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
    
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
