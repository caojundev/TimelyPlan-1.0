//
//  TPCalendarMultipleDateSelection.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/11.
//

import Foundation

/// 多日期选择器
protocol TPCalendarMultipleDateSelectionDelegate: AnyObject {
    
    /// 点击该日期时是否高亮
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, shouldHighlightedDate date: DateComponents) -> Bool

    /// 是否可以选中日期
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, canSelectDate date: DateComponents) -> Bool

    /// 是否可以反选日期
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, canDeselectDate date: DateComponents) -> Bool

    /// 选中日期
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, didSelectDate date: DateComponents)

    /// 反选日期
    func multipleDateSelection(_ selection: TPCalendarMultipleDateSelection, didDeselectDate date: DateComponents)
}

class TPCalendarMultipleDateSelection: TPCalendarDateSelection {
    
    /// 代理对象
    weak var delegate: TPCalendarMultipleDateSelectionDelegate?
    
    /// 选中日期
    private(set) var selectedDates: Set<DateComponents> = []

    init(dates: [DateComponents] = []) {
        super.init()
        self.selectedDates = Set(dates)
    }
    
    /// 直接设置选中日期，不通知Delegate
    func setSelectedDates(_ dates: [DateComponents]) {
        let oldDates = Array(selectedDates)
        let updateDateSet = Set(oldDates + dates)
        self.selectedDates = Set(dates)
        notifyDelegates { (delegate: TPCalendarDateSelectionUpdater) in
            delegate.updateCalendar(forDates: Array(updateDateSet))
        }
    }
    
    /// 选中日期数目
    var selectedCount: Int {
        return selectedDates.count
    }

    override func shouldHighlightDate(_ date: DateComponents) -> Bool {
        return delegate?.multipleDateSelection(self, shouldHighlightedDate: date) ?? true
    }

    private func canSelectDate(_ date: DateComponents) -> Bool {
        return delegate?.multipleDateSelection(self, canSelectDate: date) ?? true
    }

    private func canDeselectDate(_ date: DateComponents) -> Bool {
        return delegate?.multipleDateSelection(self, canDeselectDate: date) ?? true
    }

    private func didSelectDate(_ date: DateComponents) {
        delegate?.multipleDateSelection(self, didSelectDate: date)
    }

    private func didDeselectDate(_ date: DateComponents) {
        delegate?.multipleDateSelection(self, didDeselectDate: date)
    }

    // MARK: - 重写方法
    override func isSelectedDate(_ components: DateComponents) -> Bool {
        return selectedDates.contains(components)
    }
    
    override func selectDate(_ date: DateComponents) {
        var shouldUpdate = false
        if isSelectedDate(date) {
            /// 反选
            if canDeselectDate(date) {
                selectedDates.remove(date)
                didDeselectDate(date)
                shouldUpdate = true
            }
        } else {
            /// 选择该日期
            if canSelectDate(date) {
                selectedDates.insert(date)
                didSelectDate(date)
                shouldUpdate = true
            }
        }
        
        if shouldUpdate {
            notifyDelegates { (delegate: TPCalendarDateSelectionUpdater) in
                delegate.updateCalendar(forDates: [date])
            }
        }
    }

    override func deselectDate(_ date: DateComponents) {
        var bShouldUpdate = false
        if selectedDates.contains(date) {
            selectedDates.remove(date)
            didDeselectDate(date)
            bShouldUpdate = true
        }
        
        if bShouldUpdate {
            notifyDelegates { (delegate: TPCalendarDateSelectionUpdater) in
                delegate.updateCalendar(forDates: [date])
            }
        }
    }
}
