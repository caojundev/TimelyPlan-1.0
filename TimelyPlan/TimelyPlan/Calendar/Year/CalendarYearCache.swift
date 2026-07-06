//
//  CalendarYearCache.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/4.
//

import Foundation

// MARK: - 缓存管理器
class CalendarYearCache {
    static let shared = CalendarYearCache()
    private var cache = NSCache<NSString, MonthInfoWrapper>()
    
    class MonthInfoWrapper {
        let info: MonthInfo
        init(_ info: MonthInfo) {
            self.info = info
        }
    }
    
    func getMonthInfo(year: Int, month: Int, firstWeekday: Int) -> MonthInfo {
        // key 包含 firstWeekday，不同周开始日使用不同缓存
        let key = "\(year)-\(month)-w\(firstWeekday)" as NSString
        
        if let cached = cache.object(forKey: key) {
            return cached.info
        }
        
        let info = calculateMonthInfo(year: year, month: month, firstWeekday: firstWeekday)
        cache.setObject(MonthInfoWrapper(info), forKey: key)
        return info
    }
    
    
    private func calculateMonthInfo(year: Int, month: Int, firstWeekday: Int) -> MonthInfo {
        var calendar = Calendar.current
        calendar.firstWeekday = firstWeekday
        
        let dateComponents = DateComponents(year: year, month: month)
        
        guard let date = calendar.date(from: dateComponents) else {
            return MonthInfo(year: year, month: month, daysCount: 30, firstWeekday: 1, containsToday: false, lunarFirstDays: [])
        }
        
        // 获取该月天数
        let range = calendar.range(of: .day, in: .month, for: date)
        let daysCount = range?.count ?? 30
        
        // 获取该月第一天是周几
        var firstDateComponents = calendar.dateComponents([.year, .month], from: date)
        firstDateComponents.day = 1
        guard let firstDay = calendar.date(from: firstDateComponents) else {
            return MonthInfo(year: year, month: month, daysCount: daysCount, firstWeekday: 1, containsToday: false, lunarFirstDays: [])
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        // 检查是否包含今天
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let containsToday = (year == todayComponents.year && month == todayComponents.month)
        
        // 计算该月的农历初一日期
        let lunarFirstDays = LunarCalendar.getLunarFirstDays(year: year, month: month)
        
        return MonthInfo(
            year: year,
            month: month,
            daysCount: daysCount,
            firstWeekday: firstWeekday,
            containsToday: containsToday,
            lunarFirstDays: lunarFirstDays
        )
    }
    
    func preloadNearbyYears(currentYear: Int, firstWeekday: Int) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            for year in (currentYear - 2)...(currentYear + 2) {
                for month in 1...12 {
                    _ = self.getMonthInfo(year: year, month: month, firstWeekday: firstWeekday)
                }
            }
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
