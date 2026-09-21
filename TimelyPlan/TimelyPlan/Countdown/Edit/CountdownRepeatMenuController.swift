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
                 [.custom],
                 [.milestone]]
        return lists
    }
     
    override func menuActionTypes() -> [CountdownTimePlanType] {
        return [.none, .daily, .weekly, .monthly, .yearly, .custom, .milestone]
    }
    
    override func updateMenuAction(_ action: TPMenuAction, for type: CountdownTimePlanType) {
        super.updateMenuAction(action, for: type)
        action.subtitle = subtitle(for: type)
        action.handleBeforeDismiss = type != .custom && type != .milestone
        
        var selectedType = timePlan?.type ?? .none
        if selectedType == .custom, timePlan?.recurrenceRule == nil {
            selectedType = .none
        }
        
        if selectedType == .milestone, !(timePlan?.hasMilestone ?? false) {
            selectedType = .none
        }
        
        action.isChecked = selectedType == type
    }
    
    private func subtitle(for type: CountdownTimePlanType) -> String? {
        /// 与日期类型无关的描述
        switch type {
        case .custom:
            return timePlan?.recurrenceRule?.title
        case .milestone:
            return timePlan?.milestonesDescription
        default:
            break
        }
        
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
            default:
                return nil
            }
        }
    }
    
}
