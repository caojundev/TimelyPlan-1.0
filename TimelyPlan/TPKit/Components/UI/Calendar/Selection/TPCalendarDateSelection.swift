//
//  TPCalendarDateSelection.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/12.
//

import Foundation

protocol TPCalendarDateSelectionUpdater: AnyObject {
    
    /// 更新日历对应的日期
    func updateCalendar(forDates dates: [DateComponents])
}

class TPCalendarDateSelection: NSObject {
    
    var updaters: [TPCalendarDateSelectionUpdater]? {
        return weakDelegates.allObjects as? [TPCalendarDateSelectionUpdater]
    }
    
    /// 添加更新对象
    func addUpdater(_ updater: TPCalendarDateSelectionUpdater) {
        addDelegate(updater)
    }
    
    /// 是否是选中日期
    func isSelectedDate(_ components: DateComponents) -> Bool {
        return true
    }
    
    /// 选择日期
    func selectDate(_ components: DateComponents) {
        
    }
    
    /// 反选日期
    func deselectDate(_ components: DateComponents) {
        
    }
    
    /// 是否高亮日期
    func shouldHighlightDate(_ components: DateComponents) -> Bool {
        return true
    }
}
