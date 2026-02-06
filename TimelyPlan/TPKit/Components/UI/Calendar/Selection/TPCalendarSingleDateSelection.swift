//
//  TPCalendarSingleDateSelection.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/11.
//

import Foundation

protocol TPCalendarSingleDateSelectionDelegate: AnyObject {
    
    /// 是否可以选中日期
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, canSelect date: DateComponents) -> Bool
    
    /// 是否可以反选选日期
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, canDeselect date: DateComponents) -> Bool
    
    /// 选中日期
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents)
    
    /// 反选日期
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didDeselect date: DateComponents)
}

extension TPCalendarSingleDateSelectionDelegate {
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, canSelect date: DateComponents) -> Bool {
        return true
    }
    
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, canDeselect date: DateComponents) -> Bool {
        return true
    }
    
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        
    }

    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didDeselect date: DateComponents) {
        
    }
}

class TPCalendarSingleDateSelection: TPCalendarDateSelection {
    
    /// 代理对象
    weak var delegate: TPCalendarSingleDateSelectionDelegate?
    
    /// 当前选中日期
    private(set) var selectedDate: DateComponents?

    private func canSelectDate(_ date: DateComponents) -> Bool {
        return delegate?.singleDateSelection(self, canSelect: date) ?? true
    }
    
    private func canDeselectDate(_ date: DateComponents) -> Bool {
        return delegate?.singleDateSelection(self, canSelect: date) ?? true
    }
    
    // MARK: - TPCalendarDateSelection
    override func isSelectedDate(_ components: DateComponents) -> Bool {
        return components == selectedDate
    }
    
    /// 直接设置选中日期，不通知Delegate
    func setSelectedDateComponents(_ dateComponents: DateComponents?) {
        guard self.selectedDate != dateComponents else {
            return
        }
        
        var dateComponentsArray = [DateComponents]()
        if let previousDateComponents = selectedDate {
            dateComponentsArray.append(previousDateComponents)
        }
        
        if let currentDateComponents = dateComponents {
            dateComponentsArray.append(currentDateComponents)
        }
        
        self.selectedDate = dateComponents
        notifyDelegates { (delegate: TPCalendarDateSelectionUpdater) in
            delegate.updateCalendar(forDates: dateComponentsArray)
        }
    }
    
    override func selectDate(_ date: DateComponents) {
        if isSelectedDate(date) {
            /// 点击已选中的日期直接通知delegate
            delegate?.singleDateSelection(self, didSelect: date)
            return
        }
        
        guard canSelectDate(date) else {
            return
        }
        
        let previousDate = selectedDate
        selectedDate = date
    
        var updateDates = [date]
        if let deselectDate = previousDate {
            updateDates.append(deselectDate)
            delegate?.singleDateSelection(self, didDeselect: deselectDate)
        }

        delegate?.singleDateSelection(self, didSelect: date)
        
        /// 通知 Updater 更新 UI
        notifyDelegates { (delegate: TPCalendarDateSelectionUpdater) in
            delegate.updateCalendar(forDates: updateDates)
        }
    }
    
    override func deselectDate(_ date: DateComponents) {
        if isSelectedDate(date), canDeselectDate(date) {
            selectedDate = nil
            delegate?.singleDateSelection(self, didDeselect: date)
            
            /// 通知 Updater
            notifyDelegates { (delegate: TPCalendarDateSelectionUpdater) in
                delegate.updateCalendar(forDates: [date])
            }
        }
    }
    
    /// 反选当前选中日期
    func deselectSelectedDate() {
        guard let selectedDate = selectedDate else {
            return
        }

        deselectDate(selectedDate)
    }
}
