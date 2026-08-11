//
//  MyDayEventProcessor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/23.
//

import Foundation
import UIKit

class MyDayEventProcessor {
    
    private let repository = MyDayRepository()
    
    func clickStart(for event: MyDayEvent) {
        guard let timer = event.sourceItem as? FocusTimer else {
            return
        }
        
        FocusPresenter.startFocus(with: timer,
                                  for: nil,
                                  forceAutoStart: true)
    }
    
    /// 点击事项
    func clickEvent(_ event: MyDayEvent) {
        switch event.source {
        case .calendar:
            clickCalendarEvent(event)
        case .todo:
            clickTodoEvent(event)
        case .habit:
            clickHabitEvent(event)
        case .focus:
            clickFocusEvent(event)
        }
    }
    
    /// 点击日历事项
    private func clickCalendarEvent(_ event: MyDayEvent) {
        #warning("点击日历事项")
    }
    
    /// 点击待办
    private func clickTodoEvent(_ event: MyDayEvent) {
        guard let task = event.sourceItem as? TodoTask else {
            return
        }
        
        if !task.isDetached {
            TPImpactFeedback.impactWithSoftStyle()
            MyDayPresenter.editTodoEvent(event)
        }
    }
    
    /// 点击专注计时器
    private func clickFocusEvent(_ event: MyDayEvent) {
        TPImpactFeedback.impactWithSoftStyle()
        MyDayPresenter.editFocusEvent(event)
    }
    
    /// 点击习惯
    private func clickHabitEvent(_ event: MyDayEvent) {
        TPImpactFeedback.impactWithSoftStyle()
        MyDayPresenter.editHabitEvent(event)
    }
    
}
