//
//  CountdownRepeatMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation
import UIKit

class CountdownRepeatMenuController: TPBaseMenuController<CountdownTimePlanType> {
    
    let date: CountdownDate
    
    let timePlan: CountdownTimePlan?
    
    init(date: CountdownDate, timePlan: CountdownTimePlan? = nil) {
        self.date = date
        self.timePlan = timePlan
        super.init()
    }

    override func orderedMenuActionTypeLists() -> [Array<CountdownTimePlanType>] {
        var lists: [Array<CountdownTimePlanType>]
        lists = [[.none],
                 [.daily,
                  .weekly,
                  .monthly,
                  .yearly],
                 [.custom]]
        return lists
    }
     
    override func menuActionTypes() -> [CountdownTimePlanType] {
        return [.none, .daily, .weekly, .monthly, .yearly, .custom]
    }
    
    override func updateMenuAction(_ action: TPMenuAction, for type: CountdownTimePlanType) {
        super.updateMenuAction(action, for: type)
        action.subtitle = subtitle(for: type)
        action.handleBeforeDismiss = type != .custom
        
        var selectedType = timePlan?.type ?? .none
        if selectedType == .custom, timePlan?.recurrenceRule == nil {
            selectedType = .none
        }
        
        action.isChecked = selectedType == type
    }
    
    private func subtitle(for type: CountdownTimePlanType) -> String? {
        let targetDate = date.targetDate
        if date.type == .gregorian {
            /// 公历日期
            switch type {
            case .weekly:
                return targetDate.weekdaySymbol()
            case .monthly:
                return targetDate.dayOfTheMonthOrdinalSymbol(prefix: "the ", suffix: " day")
            case .yearly:
                return targetDate.monthDayString
            case .custom:
                return timePlan?.recurrenceRule?.title
            default:
                return nil
            }
        } else {
            /// 农历日期
            switch type {
            case .weekly:
                return targetDate.weekdaySymbol()
            case .monthly:
                return targetDate.lunarDayString
            case .yearly:
                return targetDate.lunarMonthDayString
            case .custom:
                return timePlan?.recurrenceRule?.title
            default:
                return nil
            }
        }
    }
    
}
