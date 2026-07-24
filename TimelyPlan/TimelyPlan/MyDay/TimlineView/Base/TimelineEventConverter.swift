//
//  TimelineEventConverter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation

// MARK: - 事件转换器

struct TimelineEventConverter {
    
    static func convert(events: [MyDayEvent]) -> [TimelineDataItem] {
        let nonAllDayEvents = events.filter { !$0.isAllDay }
        guard !nonAllDayEvents.isEmpty else { return [] }
        
        let nodeStyles = calculateNodeStyles(events: nonAllDayEvents)
        let timelineItems = nonAllDayEvents.enumerated().map { index, event in
            convertToTimelineItem(event: event, nodeStyle: nodeStyles[index])
        }
        
        return insertConnections(items: timelineItems)
    }
    
    // MARK: - 节点样式计算
    
    private static func calculateNodeStyles(events: [MyDayEvent]) -> [TimeLineNodeStyle] {
        let n = events.count
        var styles: [TimeLineNodeStyle] = Array(repeating: .independent, count: n)
        
        // 首先构建直接重叠关系图
        var directOverlap: [[Bool]] = Array(repeating: Array(repeating: false, count: n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                if i != j && eventsOverlap(events[i], events[j]) {
                    directOverlap[i][j] = true
                }
            }
        }
        
        // 计算每个事件是否与前面或后面的事件有"有效重叠"
        for i in 0..<n {
            var overlapsWithPrevious = false
            var overlapsWithNext = false
            
            // 检查与前面事件的有效重叠
            if i > 0 {
                overlapsWithPrevious = hasEffectiveOverlapWithPrevious(
                    index: i,
                    events: events,
                    directOverlap: directOverlap
                )
            }
            
            // 检查与后面事件的有效重叠
            if i < n - 1 {
                overlapsWithNext = hasEffectiveOverlapWithNext(
                    index: i,
                    events: events,
                    directOverlap: directOverlap
                )
            }
            
            // 确定节点样式
            switch (overlapsWithPrevious, overlapsWithNext) {
            case (false, false): styles[i] = .independent
            case (true, false): styles[i] = .connectToPrevious
            case (false, true): styles[i] = .connectToNext
            case (true, true): styles[i] = .connectToBoth
            }
        }
        
        return styles
    }
    
    // MARK: - 有效重叠判断
    
    /// 判断事件是否与前面的事件有"有效重叠"
    /// 有效重叠：通过直接重叠关系链能够连接到前面的某个事件
    private static func hasEffectiveOverlapWithPrevious(
        index: Int,
        events: [MyDayEvent],
        directOverlap: [[Bool]]
    ) -> Bool {
        let n = events.count
        var visited = Array(repeating: false, count: n)
        
        // BFS 从当前事件向前搜索
        var queue: [Int] = []
        queue.append(index)
        visited[index] = true
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            
            // 检查是否已经连接到前面的某个事件
            if current < index {
                // 找到了前面的重叠事件，但需要验证这条路径是否"有效"
                if isValidOverlapPath(from: current, to: index, events: events, directOverlap: directOverlap) {
                    return true
                }
            }
            
            // 继续向前和向后搜索直接重叠的事件
            for j in 0..<n {
                if !visited[j] && directOverlap[current][j] {
                    visited[j] = true
                    queue.append(j)
                }
            }
        }
        
        return false
    }
    
    /// 判断事件是否与后面的事件有"有效重叠"
    private static func hasEffectiveOverlapWithNext(
        index: Int,
        events: [MyDayEvent],
        directOverlap: [[Bool]]
    ) -> Bool {
        let n = events.count
        var visited = Array(repeating: false, count: n)
        
        // BFS 从当前事件向后搜索
        var queue: [Int] = []
        queue.append(index)
        visited[index] = true
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            
            // 检查是否已经连接到后面的某个事件
            if current > index {
                // 找到了后面的重叠事件，但需要验证这条路径是否"有效"
                if isValidOverlapPath(from: index, to: current, events: events, directOverlap: directOverlap) {
                    return true
                }
            }
            
            // 继续向前和向后搜索直接重叠的事件
            for j in 0..<n {
                if !visited[j] && directOverlap[current][j] {
                    visited[j] = true
                    queue.append(j)
                }
            }
        }
        
        return false
    }
    
    /// 验证重叠路径是否有效
    /// 路径有效条件：路径上的事件在时间上是连续的，没有大的时间间隔
    private static func isValidOverlapPath(
        from startIndex: Int,
        to endIndex: Int,
        events: [MyDayEvent],
        directOverlap: [[Bool]]
    ) -> Bool {
        // 如果两个事件直接重叠，路径有效
        if directOverlap[startIndex][endIndex] {
            return true
        }
        
        // 查找从 startIndex 到 endIndex 的最短路径
        let n = events.count
        var queue: [(index: Int, path: [Int])] = [(startIndex, [startIndex])]
        var visited = Array(repeating: false, count: n)
        visited[startIndex] = true
        
        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()
            
            for j in 0..<n {
                if !visited[j] && directOverlap[current][j] {
                    let newPath = path + [j]
                    
                    if j == endIndex {
                        // 找到路径，验证路径上事件的时间连续性
                        return isTimeContinuous(events: events, path: newPath)
                    }
                    
                    visited[j] = true
                    queue.append((j, newPath))
                }
            }
        }
        
        return false
    }
    
    /// 检查路径上事件的时间连续性
    /// 如果中间有任何事件与前后事件都没有时间重叠，则路径无效
    private static func isTimeContinuous(events: [MyDayEvent], path: [Int]) -> Bool {
        // 路径至少要有2个事件
        guard path.count >= 2 else { return false }
        
        // 检查每对相邻事件是否直接重叠
        for i in 0..<(path.count - 1) {
            if !eventsOverlap(events[path[i]], events[path[i+1]]) {
                return false
            }
        }
        
        return true
    }
    
    /// 判断两个事件是否在时间上重叠
    private static func eventsOverlap(_ event1: MyDayEvent, _ event2: MyDayEvent) -> Bool {
        return event1.startDate < event2.endDate && event2.startDate < event1.endDate
    }
    
    // MARK: - 连接线插入
    
    private static func insertConnections(items: [TimelineItem]) -> [TimelineDataItem] {
        var result: [TimelineDataItem] = []
        
        for (index, item) in items.enumerated() {
            result.append(.event(item))
            
            guard index + 1 < items.count else { continue }
            
            let nextItem = items[index + 1]
            let timeInterval = nextItem.startDate.timeIntervalSince(item.endDate)
            
            let style = determineConnectionStyle(
                from: item,
                to: nextItem,
                items: items,
                currentIndex: index
            )
            
            let height = calculateConnectionHeight(
                style: style,
                timeInterval: timeInterval
            )
            
            let connection = TimelineConnectionItem(
                style: style,
                topColor: item.nodeColor,
                bottomColor: nextItem.nodeColor,
                height: height,
                timeInterval: timeInterval
            )
            
            result.append(.connection(connection))
        }
        
        return result
    }
    
    // MARK: - 连接样式判断
    
    private static func determineConnectionStyle(
        from topItem: TimelineItem,
        to bottomItem: TimelineItem,
        items: [TimelineItem],
        currentIndex: Int
    ) -> TimelineConnectionStyle {
        // 检查两个事件是否直接重叠
        if let topEvent = topItem.event,
           let bottomEvent = bottomItem.event,
           eventsOverlap(topEvent, bottomEvent) {
            return .overlapping
        }
        
        // 检查节点样式是否需要 overlapping
        if (topItem.nodeStyle == .connectToNext || topItem.nodeStyle == .connectToBoth) &&
           (bottomItem.nodeStyle == .connectToPrevious || bottomItem.nodeStyle == .connectToBoth) {
            return .overlapping
        }
        
        // 根据时间间隔判断
        let timeInterval = bottomItem.startDate.timeIntervalSince(topItem.endDate)
        if timeInterval >= TimelineConfig.dashedThresholdMinutes {
            return .dashed
        }
        
        return .solid
    }
    
    // MARK: - 连接线高度计算
    
    private static func calculateConnectionHeight(
        style: TimelineConnectionStyle,
        timeInterval: TimeInterval
    ) -> CGFloat {
        switch style {
        case .overlapping:
            return TimelineConfig.overlappingConnectionHeight
            
        case .solid:
            return calculateProportionalHeight(timeInterval: timeInterval)
            
        case .dashed:
            return TimelineConfig.dashedConnectionHeight
        }
    }
    
    private static func calculateProportionalHeight(timeInterval: TimeInterval) -> CGFloat {
        let threshold = TimelineConfig.dashedThresholdMinutes
        let minHeight = TimelineConfig.solidConnectionMinHeight
        let maxHeight = TimelineConfig.solidConnectionMaxHeight
        let ratio = CGFloat(min(timeInterval, threshold) / threshold)
        return minHeight + (maxHeight - minHeight) * ratio
    }
    
    // MARK: - 事件转换
    
    static func convertToTimelineItem(event: MyDayEvent, nodeStyle: TimeLineNodeStyle) -> TimelineItem {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let timeStart = formatter.string(from: event.startDate)
        let timeEnd = formatter.string(from: event.endDate)
        
        let durationText = calculateDuration(from: event.startDate, to: event.endDate)
        let type = determineTimelineType(for: event)
        
        return TimelineItem(
            timeStart: timeStart,
            timeEnd: timeEnd,
            title: event.title ?? "No Title",
            type: type,
            isCompleted: event.isCompleted,
            durationText: durationText,
            nodeColor: event.color,
            nodeStyle: nodeStyle,
            event: event,
            startDate: event.startDate,
            endDate: event.endDate
        )
    }
    
    private static func calculateDuration(from startDate: Date, to endDate: Date) -> String? {
        let interval = endDate.timeIntervalSince(startDate)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours) hr, \(minutes) min"
        } else if hours > 0 {
            return "\(hours) hr"
        } else if minutes > 0 {
            return "\(minutes) min"
        }
        return nil
    }
    
    private static func determineTimelineType(for event: MyDayEvent) -> TimelineItemType {
        let interval = event.endDate.timeIntervalSince(event.startDate)
        let hours = interval / 3600
        
        switch hours {
        case ..<0.5: return .point
        case 0.5..<1: return .short
        default: return .long
        }
    }
}
