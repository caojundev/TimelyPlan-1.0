//
//  TimeOffset.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/15.
//

import Foundation

enum TimeUnit: Int, Hashable, Codable, TPMenuRepresentable {
    case hour
    case day
    case week
    case month
    case year
    
    var title: String {
        return localizedUnit(for: 1)
    }
    
    func unit(for count: Int) -> String {
        let unit: String
        switch self {
        case .hour:
            unit = count > 1 ? "Hours" : "Hour"
        case .day:
            unit = count > 1 ? "Days" : "Day"
        case .week:
            unit = count > 1 ? "Weeks" : "Week"
        case .month:
            unit = count > 1 ? "Months" : "Month"
        case .year:
            unit = count > 1 ? "Years" : "Year"
        }
        
        return unit
    }

    func localizedUnit(for count: Int) -> String {
        let unit = unit(for: count)
        return resGetString(unit)
    }
}

// 时间偏移量
struct TimeOffset: Hashable, Codable {
    
    enum Direction: Int, Hashable, Codable, TPMenuRepresentable {
        case before = -1
        case after = 1
        
        var title: String {
            switch self {
            case .before:
                return resGetString("Before")
            case .after:
                return resGetString("After")
            }
        }
    }
    
    /// 偏移方向
    var direction: Direction? = .after
    
    /// 数量
    var amount: Int? = 0
    
    /// 时间单位
    var unit: TimeUnit? = .day
    
    var title: String? {
        guard let amount = amount, amount != 0 else {
            return nil
        }

        let unit = unit ?? .day
        let amountUnitFormat = resGetString("%@ %@")
        let amountUnitString = String(format: amountUnitFormat, "\(abs(amount))", unit.localizedUnit(for: amount))
        
        let direction = direction ?? .after
        let format: String
        if direction == .before {
            format = resGetString("%@ Early")
        } else {
            format = resGetString("%@ Later")
        }
        
        return String(format: format, amountUnitString)
    }
    
    func getAmount() -> Int {
        return amount ?? 0
    }
    
    func getUnit() -> TimeUnit {
        return unit ?? .day
    }
    
    func getDirection() -> Direction {
        return direction ?? .after
    }
    
}

