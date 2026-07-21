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
    
    private static func calculateNodeStyles(events: [MyDayEvent]) -> [TimeLineNodeStyle] {
        var styles: [TimeLineNodeStyle] = []
        
        for (index, event) in events.enumerated() {
            let currentStart = event.startDate
            let currentEnd = event.endDate
            
            var overlapsWithPrevious = false
            var overlapsWithNext = false
            
            if index > 0 {
                for prevIndex in (0..<index).reversed() {
                    let prevEvent = events[prevIndex]
                    
                    if (currentStart >= prevEvent.startDate && currentStart < prevEvent.endDate) ||
                       (prevEvent.endDate > currentStart && prevEvent.endDate <= currentEnd) {
                        overlapsWithPrevious = true
                        break
                    }
                }
            }
            
            if index < events.count - 1 {
                for nextIndex in (index + 1)..<events.count {
                    let nextEvent = events[nextIndex]
                    
                    if (currentEnd > nextEvent.startDate && currentEnd <= nextEvent.endDate) ||
                       (nextEvent.startDate >= currentStart && nextEvent.startDate < currentEnd) {
                        overlapsWithNext = true
                        break
                    }
                }
            }
            
            let style: TimeLineNodeStyle
            switch (overlapsWithPrevious, overlapsWithNext) {
            case (false, false): style = .independent
            case (true, false): style = .connectToPrevious
            case (false, true): style = .connectToNext
            case (true, true): style = .connectToBoth
            }
            
            styles.append(style)
        }
        
        return styles
    }
    
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
                timeInterval: timeInterval
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
        let maxHeight = TimelineConfig.solidConnectionMinHeight
        let ratio = CGFloat(min(timeInterval, threshold) / threshold)
        return minHeight + (maxHeight - minHeight) * ratio
    }
    
    private static func determineConnectionStyle(
        from topItem: TimelineItem,
        to bottomItem: TimelineItem,
        timeInterval: TimeInterval
    ) -> TimelineConnectionStyle {
        if (topItem.nodeStyle == .connectToNext || topItem.nodeStyle == .connectToBoth) &&
           (bottomItem.nodeStyle == .connectToPrevious || bottomItem.nodeStyle == .connectToBoth) {
            return .overlapping
        }
        
        if timeInterval >= TimelineConfig.dashedThresholdMinutes {
            return .dashed
        }
        
        return .solid
    }
    
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
            subtitle: nil,
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
