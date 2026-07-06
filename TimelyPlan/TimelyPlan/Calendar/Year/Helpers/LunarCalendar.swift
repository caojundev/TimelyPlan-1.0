//
//  LunarCalendar.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/4.
//

import Foundation

// MARK: - 农历工具类
struct LunarCalendar {
    private static let chineseCalendar = Calendar(identifier: .chinese)
    private static let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    private static let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    private static let zodiac = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    
    // 判断是否为农历初一
    static func isLunarFirstDay(date: Date) -> Bool {
        let components = chineseCalendar.dateComponents([.day], from: date)
        return components.day == 1
    }
    
    // 判断是否为农历正月初一
    static func isLunarNewYear(date: Date) -> Bool {
        let components = chineseCalendar.dateComponents([.month, .day], from: date)
        return components.month == 1 && components.day == 1
    }
    
    // 获取农历年份的干支生肖描述
    static func getChineseYearDescription(year: Int) -> String {
        let stemIndex = (year - 4) % 10
        let branchIndex = (year - 4) % 12
        return "\(heavenlyStems[stemIndex])\(earthlyBranches[branchIndex])\(zodiac[branchIndex])年"
    }
    
    // 获取某月的所有农历初一日
    static func getLunarFirstDays(year: Int, month: Int) -> Set<Int> {
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: year, month: month)
        dateComponents.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        var lunarFirstDays = Set<Int>()
        
        for day in 1...range.count {
            dateComponents.day = day
            if let date = calendar.date(from: dateComponents),
               isLunarFirstDay(date: date) {
                lunarFirstDays.insert(day)
            }
        }
        
        return lunarFirstDays
    }
}
