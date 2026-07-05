//
//  CalendarYearEventsFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/5.
//

import Foundation

class CalendarYearEventsFetcher: CalendarYearEventsProvider {
    private let repository = CalendarRepository()
    private let calculationQueue = DispatchQueue(label: "com.calendar.eventCalculation",
                                                  qos: .userInitiated,
                                                  attributes: .concurrent)
    func fetchEventsForMonth(year: Int, month: Int, completion: @escaping (CalendarMonthEventsInfo) -> Void) {
        guard let interval = Calendar.current.monthInterval(year: year, month: month) else {
            let info = CalendarMonthEventsInfo(year: year, month: month, dayEvents: [])
            completion(info)
            return
        }
        
        repository.fetchEvents(in: interval) { [weak self] events in
            guard let self = self else { return }
            self.calculationQueue.async {
                let dayEvents = self.calculateDayEvents(
                    events: events,
                    year: year,
                    month: month,
                    monthInterval: interval
                )
                
                let result = CalendarMonthEventsInfo(year: year, month: month, dayEvents: dayEvents)
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    /// 优化版本：使用 Set 去重，减少数组查找
    private func calculateDayEvents(
        events: [CalendarEvent],
        year: Int,
        month: Int,
        monthInterval: DateInterval
    ) -> [CalendarDayEventInfo] {
        let calendar = Calendar.current
        
        guard let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: startDate) else {
            return []
        }
        
        let daysInMonth = range.count
        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end
        
        // 使用有序字典保持颜色插入顺序
        var dayColorsMap: [Int: OrderedSet<UIColor>] = [:]
        
        // 预分配内存，减少动态扩容
        for day in 1...daysInMonth {
            dayColorsMap[day] = OrderedSet<UIColor>()
        }
        
        for event in events {
            let eventStart = max(event.startDate, monthStart)
            let eventEnd = min(event.endDate, monthEnd)
            
            guard eventStart <= eventEnd else { continue }
            
            // 计算开始和结束的天索引
            let startDay = calendar.component(.day, from: eventStart)
            let endDay = calendar.component(.day, from: eventEnd)
            
            // 直接遍历天数，避免创建 Date 数组
            for day in startDay...endDay {
                guard day >= 1 && day <= daysInMonth else { break }
                dayColorsMap[day]?.append(event.color)
            }
        }
        
        // 构建结果
        var dayEvents: [CalendarDayEventInfo] = []
        dayEvents.reserveCapacity(daysInMonth)
        
        for day in 1...daysInMonth {
            let colors = dayColorsMap[day]?.array ?? []
            dayEvents.append(CalendarDayEventInfo(day: day, indicatorColors: colors))
        }
        
        return dayEvents
    }
}

// MARK: - 有序集合（去重且保持插入顺序）
struct OrderedSet<T: Hashable> {
    private var elements: [T] = []
    private var set: Set<T> = []
    
    var array: [T] { return elements }
    
    mutating func append(_ element: T) {
        if !set.contains(element) {
            elements.append(element)
            set.insert(element)
        }
    }
    
    mutating func append(contentsOf newElements: [T]) {
        for element in newElements {
            append(element)
        }
    }
}


/*
// MARK: - 测试用事项数据提供者
class MockCalendarEventsProvider: CalendarYearEventsProvider {
    
    // 模拟事项颜色
    private let eventColors: [UIColor] = [
        .systemRed,
        .systemBlue,
        .systemGreen
    ]
    
    // 模拟网络延迟
    private let simulatedDelay: TimeInterval
    
    // 存储进行中的请求，用于支持取消
    private var pendingRequests: [String: DispatchWorkItem] = [:]
    private let requestQueue = DispatchQueue(label: "com.calendar.mockEvents", qos: .userInitiated)
    
    init(simulatedDelay: TimeInterval = 0.3) {
        self.simulatedDelay = simulatedDelay
    }
    
    func fetchEventsForMonth(year: Int, month: Int, completion: @escaping (CalendarMonthEventsInfo) -> Void) {
        let requestKey = "\(year)-\(month)"
        
        // 取消之前的同月请求
        cancelFetchForMonth(year: year, month: month)
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            // 生成模拟事项数据
            let eventsInfo = self.generateMockEvents(year: year, month: month)
            
            DispatchQueue.main.async {
                completion(eventsInfo)
                
                // 清除已完成的请求
                self.pendingRequests.removeValue(forKey: requestKey)
            }
        }
        
        pendingRequests[requestKey] = workItem
        
        // 模拟异步网络请求
        requestQueue.asyncAfter(deadline: .now() + simulatedDelay, execute: workItem)
    }
    
    func cancelFetchForMonth(year: Int, month: Int) {
        let requestKey = "\(year)-\(month)"
        if let workItem = pendingRequests[requestKey] {
            workItem.cancel()
            pendingRequests.removeValue(forKey: requestKey)
        }
    }
    
    private func generateMockEvents(year: Int, month: Int) -> CalendarMonthEventsInfo {
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: year, month: month)
        dateComponents.day = 1
        
        guard let firstDay = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return CalendarMonthEventsInfo(year: year, month: month, dayEvents: [])
        }
        
        let daysInMonth = range.count
        var dayEvents: [CalendarDayEventInfo] = []
        
        // 随机生成事项（约40%的天有事）
        for day in 1...daysInMonth {
            // 使用日期作为随机种子，保证同一日期每次生成相同结果
            let seed = year * 10000 + month * 100 + day
            var randomGenerator = SeededRandomGenerator(seed: seed)
            
            // 40% 的概率有事项
            if randomGenerator.next() < 0.4 {
                // 随机1-5个事项
                let eventCount = Int(randomGenerator.next() * 5) + 1
                var colors: [UIColor] = []
                
                for _ in 0..<eventCount {
                    let colorIndex = Int(randomGenerator.next() * Double(eventColors.count))
                    colors.append(eventColors[colorIndex])
                }
                
                dayEvents.append(CalendarDayEventInfo(day: day, indicatorColors: colors))
            } else {
                // 没有事项的天
                dayEvents.append(CalendarDayEventInfo(day: day, indicatorColors: []))
            }
        }
        
        return CalendarMonthEventsInfo(year: year, month: month, dayEvents: dayEvents)
    }
}

// MARK: - 可复现的随机数生成器
struct SeededRandomGenerator {
    private var seed: UInt64
    
    init(seed: Int) {
        self.seed = UInt64(abs(seed))
    }
    
    /// 生成 0.0 到 1.0 之间的随机数
    mutating func next() -> Double {
        // 使用简单的线性同余生成器
        seed = (seed &* 6364136223846793005 &+ 1442695040888963407)
        return Double(seed >> 32) / Double(UInt32.max)
    }
}

// MARK: - 更有真实感的测试数据提供者
class RealisticMockCalendarEventsProvider: CalendarYearEventsProvider {
    
    // 不同类别的事项颜色
    private let workColor = UIColor.systemBlue
    private let personalColor = UIColor.systemGreen
    private let importantColor = UIColor.systemRed
    private let healthColor = UIColor.systemOrange
    private let travelColor = UIColor.systemPurple
    
    private let simulatedDelay: TimeInterval
    private var pendingRequests: [String: DispatchWorkItem] = [:]
    private let requestQueue = DispatchQueue(label: "com.calendar.realisticMockEvents", qos: .userInitiated)
    
    init(simulatedDelay: TimeInterval = 0.2) {
        self.simulatedDelay = simulatedDelay
    }
    
    func fetchEventsForMonth(year: Int, month: Int, completion: @escaping (CalendarMonthEventsInfo) -> Void) {
        let requestKey = "\(year)-\(month)"
        cancelFetchForMonth(year: year, month: month)
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let eventsInfo = self.generateRealisticEvents(year: year, month: month)
            DispatchQueue.main.async {
                completion(eventsInfo)
                self.pendingRequests.removeValue(forKey: requestKey)
            }
        }
        
        pendingRequests[requestKey] = workItem
        requestQueue.asyncAfter(deadline: .now() + simulatedDelay, execute: workItem)
    }
    
    func cancelFetchForMonth(year: Int, month: Int) {
        let requestKey = "\(year)-\(month)"
        pendingRequests[requestKey]?.cancel()
        pendingRequests.removeValue(forKey: requestKey)
    }
    
    private func generateRealisticEvents(year: Int, month: Int) -> CalendarMonthEventsInfo {
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: year, month: month)
        dateComponents.day = 1
        
        guard let firstDay = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return CalendarMonthEventsInfo(year: year, month: month, dayEvents: [])
        }
        
        var dayEvents: [CalendarDayEventInfo] = []
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        for day in 1...range.count {
            var colors: [UIColor] = []
            
            // 模拟不同场景的事项
            let isWeekend = { () -> Bool in
                dateComponents.day = day
                if let date = calendar.date(from: dateComponents) {
                    let weekday = calendar.component(.weekday, from: date)
                    return weekday == 1 || weekday == 7 // 周日或周六
                }
                return false
            }()
            
            // 每个工作日有60%概率有工作事项
            if !isWeekend && day % 3 != 0 {
                if Int.random(in: 0...10) < 6 {
                    colors.append(workColor)
                }
            }
            
            // 周末有个人事项
            if isWeekend && day % 2 == 0 {
                colors.append(personalColor)
            }
            
            // 月初和月末有重要事项
            if (day <= 3 || day >= range.count - 2) && Int.random(in: 0...10) < 7 {
                colors.append(importantColor)
            }
            
            // 每周三有健康事项
            dateComponents.day = day
            if let date = calendar.date(from: dateComponents),
               calendar.component(.weekday, from: date) == 4 { // 周三
                if Int.random(in: 0...10) < 5 {
                    colors.append(healthColor)
                }
            }
            
            // 15号左右有旅行事项
            if abs(day - 15) <= 2 && Int.random(in: 0...10) < 4 {
                colors.append(travelColor)
            }
            
            // 如果是今天，添加一个特殊标记
            if year == todayComponents.year && month == todayComponents.month && day == todayComponents.day {
                if colors.isEmpty {
                    colors = [.systemRed] // 今天至少有红色标记
                } else {
                    colors.insert(.systemRed, at: 0) // 今天优先显示红色
                }
            }
            
            dayEvents.append(CalendarDayEventInfo(day: day, indicatorColors: colors))
        }
        
        return CalendarMonthEventsInfo(year: year, month: month, dayEvents: dayEvents)
    }
}
*/

