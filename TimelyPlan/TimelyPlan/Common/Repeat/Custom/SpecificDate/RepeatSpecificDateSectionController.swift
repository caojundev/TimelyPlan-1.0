//
//  RepeatSpecificDateSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/20.
//

import Foundation

class RepeatSpecificDateSectionController: TPTableItemSectionController,
                                            TPCalendarMultipleDateSelectionDelegate {
    
    var dates: [Date] {
        get {
            var dates = [Date]()
            for compontents in dateSelection.selectedDates {
                if let date = Date.dateFromComponents(compontents) {
                    dates.append(date)
                }
            }
            
            return dates
        }
        
        set {
            let componentsArray = newValue.map { $0.yearMonthDayComponents }
            dateSelection.setSelectedDates(componentsArray)
        }
    }
    
    var selectedDatesDidChange: (([Date]) -> Void)?
    
    // MARK: - 自选日期
    private lazy var dateSelection: TPCalendarMultipleDateSelection = {
        let selection = TPCalendarMultipleDateSelection(dates: [])
        selection.delegate = self
        return selection
    }()

    /// 日历
    lazy var calendarCellItem: TPCalendarTableCellItem = {
        let cellItem = TPCalendarTableCellItem()
        cellItem.selection = dateSelection
        cellItem.height = 420.0
        return cellItem
    }()
    
    lazy var datesCellItem: RepeatSpecificDateTableCellItem = {
        let cellItem = RepeatSpecificDateTableCellItem()
        cellItem.selection = dateSelection
        cellItem.didClickDate = { [weak self] components in
            self?.didClickSpecificDate(components)
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = 10.0
        self.footerItem.height = 0.0
        self.cellItems = [calendarCellItem, datesCellItem]
    }
    
    /// 点击列表日期，日历滚动到该日期所在月份
    func didClickSpecificDate(_ dateComponents: DateComponents) {
        if calendarCellItem.visibleDateComponents.isInSameMonth(as: dateComponents) {
            return
        }
        
        calendarCellItem.visibleDateComponents = dateComponents
        let cell = adapter?.cellForItem(calendarCellItem) as? TPCalendarTableCell
        cell?.calendarView.setVisibleDateComponents(dateComponents, animated: true)
    }
    
    // MARK: - TPCalendarMultipleDateSelectionDelegate
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, shouldHighlightedDate date: DateComponents) -> Bool {
        return true
    }
    
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, canSelectDate date: DateComponents) -> Bool {
        return true
    }
    
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, canDeselectDate date: DateComponents) -> Bool {
        return true
    }
    
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, didSelectDate date: DateComponents) {
        selectedDatesDidChange?(dates)
    }
    
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, didDeselectDate date: DateComponents) {
        selectedDatesDidChange?(dates)
    }

}
