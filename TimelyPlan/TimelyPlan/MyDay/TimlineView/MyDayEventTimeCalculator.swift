//
//  MyDayEventTimeCalculator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/12.
//

import Foundation

// MARK: - 事项时间计算器

/// 根据时间线连接条目计算新事项的建议时间
class MyDayEventTimeCalculator {
    
    // MARK: - 配置
    
    /// 时间计算配置
    struct Configuration {
        /// 最小间隔（秒），低于此值不适合插入事项
        var minimumInterval: TimeInterval = 300 // 5分钟
        
        /// 短间隔上限（秒）
        var shortIntervalThreshold: TimeInterval = 1800 // 30分钟
        
        /// 中等间隔上限（秒）
        var mediumIntervalThreshold: TimeInterval = 7200 // 2小时
        
        /// 短间隔缓冲比例（前后各占20%）
        var shortIntervalBufferRatio: Double = 0.2
        
        /// 中等间隔前缓冲比例
        var mediumIntervalStartBufferRatio: Double = 0.15
        
        /// 中等间隔后缓冲比例
        var mediumIntervalEndBufferRatio: Double = 0.10
        
        /// 最小缓冲时间（秒）
        var minimumBuffer: TimeInterval = 120 // 2分钟
        
        /// 最大缓冲时间（秒）
        var maximumBuffer: TimeInterval = 900 // 15分钟
        
        /// 默认长间隔事项时长（秒）
        var defaultLongDuration: TimeInterval = 3600 // 1小时
        
        /// 特殊时段事项时长（秒）
        var specialPeriodDuration: TimeInterval = 1800 // 30分钟
        
        /// 超长间隔阈值（秒）
        var veryLongIntervalThreshold: TimeInterval = 14400 // 4小时
        
        /// 超长间隔事项时长（秒）
        var veryLongDuration: TimeInterval = 5400 // 1.5小时
        
        /// 长时间缓冲（秒）
        var longBuffer: TimeInterval = 600 // 10分钟
        
        /// 可用时间不足时的使用比例
        var insufficientTimeRatio: Double = 0.7
    }
    
    // MARK: - 结果模型
    
    /// 建议的事项时间
    struct SuggestedEventTime {
        let startDate: Date
        let endDate: Date
        let duration: TimeInterval
        let intervalInfo: IntervalInfo
    }
    
    /// 间隔信息
    struct IntervalInfo {
        /// 间隔类型
        enum IntervalType: String {
            case tooShort
            case short
            case medium
            case long
            case veryLong
            case overlapping
        }
        
        let type: IntervalType
        let totalInterval: TimeInterval
        let availableTime: TimeInterval
        let startBuffer: TimeInterval
        let endBuffer: TimeInterval
        let suggestedDuration: TimeInterval
    }
    
    // MARK: - 属性
    
    private let config: Configuration
    private let calendar: Calendar
    
    // MARK: - 初始化
    
    init(config: Configuration = Configuration(), calendar: Calendar = .current) {
        self.config = config
        self.calendar = calendar
    }
    
    // MARK: - 公共方法
    
    /// 计算建议的事项时间
    /// - Parameters:
    ///   - topDate: 上一个事项的结束时间
    ///   - bottomDate: 下一个事项的开始时间
    /// - Returns: 建议的事项时间，如果不适合插入则返回 nil
    func calculateSuggestedTime(topDate: Date, bottomDate: Date) -> SuggestedEventTime? {
        let interval = bottomDate.timeIntervalSince(topDate)
        let intervalInfo = analyzeInterval(interval: interval, topDate: topDate, bottomDate: bottomDate)
        
        // 检查是否适合插入事项
        guard intervalInfo.type != .tooShort && intervalInfo.type != .overlapping else {
            return nil
        }
        
        let (startDate, endDate) = calculateTimeRange(intervalInfo: intervalInfo, topDate: topDate, bottomDate: bottomDate)
        
        return SuggestedEventTime(
            startDate: startDate,
            endDate: endDate,
            duration: endDate.timeIntervalSince(startDate),
            intervalInfo: intervalInfo
        )
    }
    
    /// 批量计算多个连接条目的建议时间
    func calculateSuggestedTimes(connections: [TimelineConnectionItem]) -> [SuggestedEventTime?] {
        return connections.map { connection in
            calculateSuggestedTime(topDate: connection.topDate, bottomDate: connection.bottomDate)
        }
    }
    
    // MARK: - 私有方法
    
    /// 分析时间间隔
    private func analyzeInterval(interval: TimeInterval, topDate: Date, bottomDate: Date) -> IntervalInfo {
        let type: IntervalInfo.IntervalType
        
        if interval <= 0 {
            type = .overlapping
        } else if interval < config.minimumInterval {
            type = .tooShort
        } else if interval < config.shortIntervalThreshold {
            type = .short
        } else if interval < config.mediumIntervalThreshold {
            type = .medium
        } else if interval < config.veryLongIntervalThreshold {
            type = .long
        } else {
            type = .veryLong
        }
        
        let (startBuffer, endBuffer, suggestedDuration) = calculateBuffers(
            interval: interval,
            type: type,
            topDate: topDate,
            bottomDate: bottomDate
        )
        
        let availableTime = interval - startBuffer - endBuffer
        
        return IntervalInfo(
            type: type,
            totalInterval: interval,
            availableTime: availableTime,
            startBuffer: startBuffer,
            endBuffer: endBuffer,
            suggestedDuration: suggestedDuration
        )
    }
    
    /// 计算缓冲时间
    private func calculateBuffers(
        interval: TimeInterval,
        type: IntervalInfo.IntervalType,
        topDate: Date,
        bottomDate: Date
    ) -> (startBuffer: TimeInterval, endBuffer: TimeInterval, suggestedDuration: TimeInterval) {
        
        switch type {
        case .overlapping, .tooShort:
            return (0, 0, 0)
            
        case .short:
            return calculateShortIntervalBuffers(interval: interval)
            
        case .medium:
            return calculateMediumIntervalBuffers(interval: interval)
            
        case .long, .veryLong:
            return calculateLongIntervalBuffers(interval: interval, topDate: topDate, bottomDate: bottomDate)
        }
    }
    
    /// 短间隔缓冲计算
    private func calculateShortIntervalBuffers(interval: TimeInterval) -> (TimeInterval, TimeInterval, TimeInterval) {
        let bufferTime = interval * config.shortIntervalBufferRatio
        let actualBuffer = max(bufferTime, config.minimumBuffer)
        
        let eventDuration = interval - (actualBuffer * 2)
        let minDuration: TimeInterval = 300 // 5分钟
        let finalDuration = max(eventDuration, minDuration)
        
        // 如果剩余时间不够，使用最小缓冲
        if finalDuration >= interval {
            let adjustedBuffer = (interval - minDuration) / 2
            return (adjustedBuffer, adjustedBuffer, minDuration)
        }
        
        return (actualBuffer, actualBuffer, finalDuration)
    }
    
    /// 中等间隔缓冲计算
    private func calculateMediumIntervalBuffers(interval: TimeInterval) -> (TimeInterval, TimeInterval, TimeInterval) {
        let startBuffer = min(max(interval * config.mediumIntervalStartBufferRatio, config.minimumBuffer), config.maximumBuffer)
        let endBuffer = min(max(interval * config.mediumIntervalEndBufferRatio, config.minimumBuffer), config.maximumBuffer)
        
        let eventDuration = interval - startBuffer - endBuffer
        
        return (startBuffer, endBuffer, eventDuration)
    }
    
    /// 长间隔缓冲计算
    private func calculateLongIntervalBuffers(
        interval: TimeInterval,
        topDate: Date,
        bottomDate: Date
    ) -> (TimeInterval, TimeInterval, TimeInterval) {
        let startBuffer = config.longBuffer
        let endBuffer = config.longBuffer
        
        var suggestedDuration = config.defaultLongDuration
        
        // 根据时间段调整
        let topHour = calendar.component(.hour, from: topDate)
        let bottomHour = calendar.component(.hour, from: bottomDate)
        
        // 特殊时段（工作开始或下午开始）
        if isSpecialPeriod(topHour: topHour, bottomHour: bottomHour) {
            suggestedDuration = config.specialPeriodDuration
        }
        
        // 超长间隔
        if interval > config.veryLongIntervalThreshold {
            suggestedDuration = config.veryLongDuration
        }
        
        // 检查可用时间是否足够
        let availableTime = interval - startBuffer - endBuffer
        
        if availableTime < suggestedDuration {
            suggestedDuration = availableTime * config.insufficientTimeRatio
        }
        
        return (startBuffer, endBuffer, suggestedDuration)
    }
    
    /// 判断是否为特殊时段
    private func isSpecialPeriod(topHour: Int, bottomHour: Int) -> Bool {
        // 工作开始时段（8-10点之间）
        if topHour < 9 && bottomHour > 9 {
            return true
        }
        // 下午开始时段（13-15点之间）
        if topHour < 14 && bottomHour > 14 {
            return true
        }
        return false
    }
    
    /// 计算具体时间范围
    private func calculateTimeRange(
        intervalInfo: IntervalInfo,
        topDate: Date,
        bottomDate: Date
    ) -> (Date, Date) {
        
        let startTime = topDate.addingTimeInterval(intervalInfo.startBuffer)
        let roundedStart = roundStartTime(startTime, intervalType: intervalInfo.type)
        
        let endTime = roundedStart.addingTimeInterval(intervalInfo.suggestedDuration)
        let roundedEnd = roundEndTime(endTime, intervalType: intervalInfo.type)
        
        // 确保不超出边界
        let maxEndTime = bottomDate.addingTimeInterval(-intervalInfo.endBuffer)
        let finalEnd = min(roundedEnd, maxEndTime)
        
        // 如果结束时间早于开始时间（极端情况），调整
        if finalEnd <= roundedStart {
            let adjustedEnd = roundedStart.addingTimeInterval(300) // 至少5分钟
            return (roundedStart, min(adjustedEnd, maxEndTime))
        }
        
        return (roundedStart, finalEnd)
    }
    
    // MARK: - 时间取整方法
    
    /// 开始时间取整
    private func roundStartTime(_ date: Date, intervalType: IntervalInfo.IntervalType) -> Date {
        switch intervalType {
        case .short, .medium:
            return roundToNearestFiveMinutes(date)
        case .long, .veryLong:
            return roundToNearestHalfHour(date)
        default:
            return date
        }
    }
    
    /// 结束时间取整
    private func roundEndTime(_ date: Date, intervalType: IntervalInfo.IntervalType) -> Date {
        switch intervalType {
        case .short:
            return roundToNearestFiveMinutes(date)
        case .medium:
            return roundToNearestFifteenMinutes(date)
        case .long, .veryLong:
            return roundToNearestFifteenMinutes(date)
        default:
            return date
        }
    }
    
    /// 取整到最近的5分钟
    private func roundToNearestFiveMinutes(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let minute = components.minute ?? 0
        
        let roundedMinute = (minute / 5) * 5
        let remainder = minute % 5
        
        // 如果余数大于等于3，向上取整
        let finalMinute = remainder >= 3 ? min(roundedMinute + 5, 55) : roundedMinute
        
        var adjustedComponents = components
        adjustedComponents.minute = finalMinute
        adjustedComponents.second = 0
        
        return calendar.date(from: adjustedComponents) ?? date
    }
    
    /// 取整到最近的15分钟
    private func roundToNearestFifteenMinutes(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let minute = components.minute ?? 0
        
        let roundedMinute = (minute / 15) * 15
        
        var adjustedComponents = components
        adjustedComponents.minute = roundedMinute
        adjustedComponents.second = 0
        
        return calendar.date(from: adjustedComponents) ?? date
    }
    
    /// 取整到最近的半小时
    private func roundToNearestHalfHour(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let minute = components.minute ?? 0
        
        let roundedMinute = minute < 15 ? 0 : (minute < 45 ? 30 : 0)
        let adjustedHour = (components.hour ?? 0) + (minute >= 45 ? 1 : 0)
        
        var adjustedComponents = components
        adjustedComponents.hour = adjustedHour
        adjustedComponents.minute = roundedMinute
        adjustedComponents.second = 0
        
        return calendar.date(from: adjustedComponents) ?? date
    }
}

// MARK: - 自定义配置示例

extension MyDayEventTimeCalculator.Configuration {
    
    /// 紧凑型配置（适合忙碌的日程）
    static var compact: MyDayEventTimeCalculator.Configuration {
        var config = MyDayEventTimeCalculator.Configuration()
        config.minimumInterval = 180        // 3分钟
        config.minimumBuffer = 60           // 1分钟
        config.maximumBuffer = 300          // 5分钟
        config.defaultLongDuration = 1800   // 30分钟
        config.shortIntervalBufferRatio = 0.15
        return config
    }
    
    /// 宽松型配置（适合轻松的日程）
    static var relaxed: MyDayEventTimeCalculator.Configuration {
        var config = MyDayEventTimeCalculator.Configuration()
        config.minimumInterval = 600        // 10分钟
        config.minimumBuffer = 300          // 5分钟
        config.maximumBuffer = 1200         // 20分钟
        config.defaultLongDuration = 5400   // 1.5小时
        config.shortIntervalBufferRatio = 0.3
        config.mediumIntervalStartBufferRatio = 0.25
        config.mediumIntervalEndBufferRatio = 0.20
        return config
    }
}
