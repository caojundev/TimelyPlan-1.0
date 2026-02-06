//
//  TimePeriod.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/15.
//

import Foundation

enum TimePeriod: String {
    case morning
    case noon
    case afternoon
    case dusk
    case evening
    case midnight
    
    var title: String {
        return resGetString(rawValue.capitalized)
    }
}

extension Duration {
    
    var timePeriod: TimePeriod {
        let normalizedOffset = (self % SECONDS_PER_DAY + SECONDS_PER_DAY) % SECONDS_PER_DAY
        if normalizedOffset >= 6 * SECONDS_PER_HOUR && normalizedOffset < 12 * SECONDS_PER_HOUR {
            return .morning
        } else if normalizedOffset >= 12 * SECONDS_PER_HOUR && normalizedOffset < 13 * SECONDS_PER_HOUR {
            return .noon
        } else if normalizedOffset >= 13 * SECONDS_PER_HOUR && normalizedOffset < 18 * SECONDS_PER_HOUR {
            return .afternoon
        } else if normalizedOffset >= 18 * SECONDS_PER_HOUR && normalizedOffset < 19 * SECONDS_PER_HOUR {
            return .dusk
        } else if normalizedOffset >= 19 * SECONDS_PER_HOUR && normalizedOffset < 24 * SECONDS_PER_HOUR {
            return .evening
        } else {
            return .midnight
        }
    }
}
