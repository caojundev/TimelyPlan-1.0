//
//  Weekday.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/2.
//

import Foundation

/// 符号样式
enum WeekdaySymbolStyle {
    case full      /// 完整
    case short     /// 短符号
    case veryShort /// 最短符号（单字符）
}

enum Weekday: Int, Hashable, Codable, CaseIterable, TPMenuRepresentable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    /// 周末
    static var weekendDays: [Weekday] = [.saturday, .sunday]
    
    /// 工作日
    static var weekdayDays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday]
    
    /// 默认周开始日
    static var firstWeekday: Weekday {
        return .sunday
    }
    
    var title: String {
        return symbol
    }
    
    /// 符号
    var symbol: String {
        return Date.weekdaySymbol(style: .full, weekday: self)
    }

    var shortSymbol: String {
        return Date.weekdaySymbol(style: .short, weekday: self)
    }
    
    var veryShortSymbol: String {
        return Date.weekdaySymbol(style: .veryShort, weekday: self)
    }
    
    /// 是否是周末
    var isWeekend: Bool {
        return self == .sunday || self == .saturday
    }
    
    /// 是否是工作日
    var isWorkday: Bool {
        return !isWeekend
    }
    
    /// 创建今天对应的 weekday 枚举对象
    init() {
        self.init(date: Date())
    }
    
    /// 根据日期创建其对应的 weekday 枚举对象
    init(date: Date) {
        self = Weekday(rawValue: date.weekday)!
    }
}

/// 周日在末尾的顺序数组
let kSundayLastOrderedWeekdays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

extension Array where Element == Weekday {
    
    /// 按顺序排列的周符号
    var orderedSymbols: [String]? {
        return orderedWeekdaySymbols(of: .full)
    }
    
    var orderedShortSymbols: [String]? {
        return orderedWeekdaySymbols(of: .short)
    }
    
    func orderedWeekdaySymbols(of style: WeekdaySymbolStyle) -> [String]? {
        var symbols: [String] = []
        for weekday in kSundayLastOrderedWeekdays {
            if self.contains(weekday) {
                var symbol: String
                switch style {
                case .full:
                    symbol = weekday.symbol
                case .short:
                    symbol = weekday.shortSymbol
                case .veryShort:
                    symbol = weekday.veryShortSymbol
                }
                
                symbols.append(symbol.lowercased())
            }
        }
        
        if symbols.count == 0 {
            return nil
        }
    
        return symbols
    }
    
    /// 获取weekNumber对应的周重复日数组
    func daysOfTheWeek(with weekNumber: Int) -> [RepeatDayOfWeek] {
        var days: [RepeatDayOfWeek] = []
        for weekday in self {
            let repeatDay = RepeatDayOfWeek(dayOfTheWeek: weekday, weekNumber: weekNumber)
            days.append(repeatDay)
        }
        
        return days
    }
}
