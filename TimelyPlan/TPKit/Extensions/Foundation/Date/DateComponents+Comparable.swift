//
//  DateComponents+Comparable.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/12.
//

import Foundation

extension DateComponents: Comparable {
    
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        let calendar = Calendar.current
        guard let lhsDate = calendar.date(from: lhs), let rhsDate = calendar.date(from: rhs) else {
            return false
        }
    
        return lhsDate < rhsDate
    }

    public static func == (lhs: DateComponents, rhs: DateComponents) -> Bool {
        let calendar = Calendar.current
        guard let lhsDate = calendar.date(from: lhs), let rhsDate = calendar.date(from: rhs) else {
            return false
        }
        
        return lhsDate == rhsDate
    }
}
