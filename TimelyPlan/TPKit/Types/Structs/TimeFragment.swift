//
//  TimeFragment.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/15.
//

import Foundation

/// 时间切片
struct TimeFragment: Codable, Equatable {
    
    /// 开始日期
    var startDate: Date
    
    /// 时长
    var interval: TimeInterval

    var duration: Duration {
        return Duration(interval)
    }
    
    /// 结束日期
    var endDate: Date {
        return startDate.addingTimeInterval(interval)
    }
    
    /// 判断两个时间段是否相交
    func intersects(_ other: TimeFragment) -> Bool {
        if self.endDate <= other.startDate || other.endDate <= self.startDate {
            return false
        }
        
        return true
    }
    
    func intersects(_ dateRange: DateRange) -> Bool {
        guard let startDate = dateRange.startDate, let endDate = dateRange.endDate else {
            return false
        }
        
        if endDate <= self.startDate || self.endDate <= startDate {
            return false
        }
        
        return true
    }
    
    /// 获取两个时间段交集时长
    func intersectionDuration(with other: TimeFragment) -> Int {
        guard intersects(other) else {
            return 0
        }
        
        // 计算相交的开始和结束时间
        let intersectStartDate = max(self.startDate, other.startDate)
        let intersectEndDate = min(self.endDate, other.endDate)

        // 返回相交的时长
        return Int(intersectEndDate.timeIntervalSince(intersectStartDate))
    }

    /// 判断该专注片段是否跨天
    var isSpanningMultipleDays: Bool {
        return !(startDate.isInSameDayAs(endDate))
    }
    
    /// 生成每天的片段
    func dailyFragments() -> [TimeFragment] {
        guard isSpanningMultipleDays else {
            return [TimeFragment(startDate: startDate, interval: interval)]
        }
        
        /// 跨天
        var fragments: [TimeFragment] = []
        var currentStartDate = startDate
        var currentEndDate = startDate.dateByAddingDays(1)!.startOfDay()
        let endDate = self.endDate
        
        /// 首段
        let firstInterval = currentEndDate.timeIntervalSince(currentStartDate)
        let firstFragment = TimeFragment(startDate: currentStartDate, interval: firstInterval)
        fragments.append(firstFragment)
        
        while !currentEndDate.isInSameDayAs(endDate) {
            currentStartDate = currentEndDate
            let fragment = TimeFragment(startDate: currentStartDate, interval: TimeInterval(SECONDS_PER_DAY))
            fragments.append(fragment)
            currentEndDate = currentStartDate.dateByAddingDays(1)!.startOfDay()
        }
        
        /// 末段
        let lastStartDate = endDate.startOfDay()
        let lastInterval = endDate.timeIntervalSince(lastStartDate)
        let lastFragment = TimeFragment(startDate: lastStartDate, interval: lastInterval)
        fragments.append(lastFragment)
        return fragments
    }
    
    /// 计算每个小时的总持续时间
    func hourlyDuration() -> [Int: Duration] {
        var durationPerHour = [Int: Duration]()
        var currentDate = self.startDate
        let endDate = self.endDate
        while currentDate < endDate {
            var nextHourStartDate = currentDate.dateByAddingHours(1)!
            // 将此日期的分钟和秒数归零，使其指向开始于下一个整点时间。
            nextHourStartDate = nextHourStartDate.dateByRemovingMinuteAndSecond()!
            if nextHourStartDate > endDate {
                nextHourStartDate = endDate
            }

            // 计算此 hour 的 duration，并加入到 dictionary 中。
            let duration = Duration(nextHourStartDate.timeIntervalSince(currentDate))
            durationPerHour[currentDate.hour, default: 0] += duration
            currentDate = nextHourStartDate
        }

        return durationPerHour
    }
}

extension Array where Element == TimeFragment {
    
    var interval: TimeInterval {
        let result = self.reduce(0) { (result, fragment) in
            return result + fragment.interval
        }
            
        return result
    }
    
    /// 数组内时间片段是否与特定日期范围有交集
    func intersects(_ dateRange: DateRange) -> Bool {
        for fragment in self {
            if fragment.intersects(dateRange) {
                return true
            }
        }
        
        return false
    }
    
}
