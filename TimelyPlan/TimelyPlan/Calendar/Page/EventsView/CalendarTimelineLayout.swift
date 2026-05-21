//
//  CalendarTimelineLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/2.
//

import Foundation
import UIKit

// MARK: - 时间线布局工具
final class CalendarTimelineLayout {
    
    /// 内容尺寸
    var containerSize: CGSize = UIScreen.main.bounds.size {
        didSet {
            if containerSize != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 边界间距
    let edgeMargin: CGFloat = 2.0
    
    // 添加事件间距变量
    let eventMargin: CGFloat = 2.0
    
    /// 最小高度
    let minEventHeight: CGFloat = 20.0

    let offsetWidth = 4.0
    
    /// 时间线日期范围
    let dateRange: DateInterval
    
    let events: [CalendarEvent]
    
    private var eventFrames: [CalendarEvent: CGRect] = [:]
    
    private var needsLayout: Bool = true
    
    init(events: [CalendarEvent], dateRange: DateInterval) {
        /// 过滤掉不在时间线上的事项
        var validEvents = [CalendarEvent]()
        for event in events {
            if !event.isAllDay, event.dateRange.intersects(dateRange) {
                validEvents.append(event)
            }
        }
        
        self.events = validEvents.sorted { $0.startDate <= $1.startDate}
        self.dateRange = dateRange
    }
    
    // MARK: - 公有方法
    func setNeedsLayout() {
        needsLayout = true
    }
    
    func frame(for event: CalendarEvent) -> CGRect {
        if needsLayout {
            layout()
            needsLayout = false
        }
        
        return eventFrames[event] ?? .zero
    }

    // MARK: - 私有方法
    
    // MARK: 事件分组
    /// 将重叠事件位置分组（直接或间接重叠的分为同一组）
    private func groupOverlappingEventPositions(_ positions: [EventPosition]) -> [[EventPosition]] {
        guard !positions.isEmpty else { return [] }
        
        // 使用并查集算法合并重叠事件
        var uf = UnionFind(count: positions.count)
        for i in 0..<positions.count {
            for j in (i+1)..<positions.count {
                if positions[i].overlaps(with: positions[j], contentHeight: minEventHeight) {
                    uf.union(i, j)
                }
            }
        }
        
        // 根据并查集结果分组
        var groups: [Int: [EventPosition]] = [:]
        for (index, position) in positions.enumerated() {
            let root = uf.find(index)
            groups[root, default: []].append(position)
        }
        
        return Array(groups.values)
    }
    
    // MARK: 计算最大重叠数
    /// 使用扫描线算法计算最大同时发生事件数
    private func calculateMaxOverlapCount(in eventPositions: [EventPosition]) -> Int {
        var points: [(originY: CGFloat, isStart: Bool)] = []

        // 生成所有纵坐标点（开始/结束）
        eventPositions.forEach {
           points.append(($0.yStart, true))
           points.append(($0.yEnd, false))
        }

        // 排序规则：时间相同则结束事件优先处理
        points.sort {
           if $0.originY == $1.originY {
               return !$0.isStart && $1.isStart
           }
           return $0.originY < $1.originY
        }

        // 扫描计算最大重叠数
        var currentOverlap = 0
        var maxOverlap = 0
        points.forEach { point in
           currentOverlap += point.isStart ? 1 : -1
           maxOverlap = max(maxOverlap, currentOverlap)
        }

        return maxOverlap
    }
    
    // MARK: 轨道分配
    /// 将事件分配到轨道（行）中，确保同一轨道无重叠
    private func eventAssignments(for overlappingPositions: [EventPosition]) -> [EventAssignment] {
        let maxOverlapCount = calculateMaxOverlapCount(in: overlappingPositions)
        let sortedEventPositions = overlappingPositions.sorted {
            if $0.height > $1.height {
                return true
            } else {
                return $0.yStart < $1.yStart
            }
        }
        
        var tracks: [CGFloat] = [] // 记录每个轨道的最后结束位置
        var assignments: [EventAssignment] = []
        for eventPosition in sortedEventPositions {
            // 查找第一个可用的轨道
            var availableTrack: Int?
            for (index, lastEnd) in tracks.enumerated() where lastEnd <= eventPosition.yStart {
                availableTrack = index
                break
            }
            
            var assignmentTrack: Int
            if let track = availableTrack {
                // 占用现有轨道
                tracks[track] = eventPosition.yEnd
                assignmentTrack = track
            } else {
                // 创建新轨道
                tracks.append(eventPosition.yEnd)
                assignmentTrack = tracks.count - 1
            }
            
            let assignment = EventAssignment(position: eventPosition,
                                             track: assignmentTrack,
                                             maxOverlapCount: maxOverlapCount)
            assignments.append(assignment)
        }
        
        return assignments
    }
    
    // MARK: - Helpers
    private func layout() {
        var eventFrames: [CalendarEvent: CGRect] = [:]
        
        let eventPositions = events.map { calculatePosition(for: $0) }
        let groups = groupOverlappingEventPositions(eventPositions)
        var trackAssignments = [Int: [EventAssignment]]()
        for group in groups {
            let eventAssignments = eventAssignments(for: group)
            for eventAssignment in eventAssignments {
                let track = eventAssignment.track
                trackAssignments[track, default: []].append(eventAssignment)
            }
        }

        for eventAssignments in Array(trackAssignments.values) {
            for eventAssignment in eventAssignments {
                let offset = eventOffset(for: eventAssignment, trackAssignments: trackAssignments)
                let event = eventAssignment.position.event
                let eventFrame = frameForEventAssignment(eventAssignment, offset: offset)
                eventFrames[event] = eventFrame
            }
        }

        self.eventFrames = eventFrames
    }
    
    private func eventOffset(for eventAssignment: EventAssignment,
                             trackAssignments: [Int: [EventAssignment]]) -> Int {
        var offset = 0
        let track = eventAssignment.track
        guard let eventAssignments = trackAssignments[track], eventAssignments.count > 1 else {
            return offset
        }
        
        /// 根据开始位置排序
        let sortedEventAssignments = eventAssignments.sorted {
            $0.position.yStart < $1.position.yStart
        }
        
        /// 找到当前事件在数组中的位置
        let index = sortedEventAssignments.firstIndex {
            $0.position.event.identifier == eventAssignment.position.event.identifier
        }
        
        guard let index = index, index > 0 else {
            return offset
        }
        
        for i in 0..<index {
            let sortedEventAssignment = sortedEventAssignments[i]
            if sortedEventAssignment.position.overlaps(with: eventAssignment.position) {
                offset += 1
            }
        }
        
        return offset
    }
    
    /// 计算事件的垂直位置和高度
    private func calculatePosition(for event: CalendarEvent) -> EventPosition {
        let totalMinutes = dateRange.end.timeIntervalSince(dateRange.start) / 60
        let minutesFromStart = CGFloat(event.startDate.timeIntervalSince(dateRange.start)) / 60
        let durationMinutes = CGFloat(event.endDate.timeIntervalSince(event.startDate)) / 60
        let y = (minutesFromStart / totalMinutes) * containerSize.height
        var h = (durationMinutes / totalMinutes) * containerSize.height
        if h < minEventHeight {
            h = minEventHeight
        }

        return EventPosition(event: event, yStart: y, yEnd: y + h)
    }
    
    private func frameForEventAssignment(_ eventAssignment: EventAssignment, offset: Int) -> CGRect {
        let eventPosition = eventAssignment.position
        let track = eventAssignment.track
        let overlapsCount = max(eventAssignment.maxOverlapCount, 1)
        var w = (containerSize.width - 2 * edgeMargin - CGFloat(overlapsCount - 1) * eventMargin) / CGFloat(overlapsCount)
        var x = edgeMargin + CGFloat(track) * (w + eventMargin)
        
        let offsetWidth = CGFloat(offset) * offsetWidth
        x += offsetWidth
        w -= offsetWidth
        return CGRect(x: x, y: eventPosition.yStart, width: w, height: eventPosition.height)
    }
    
    // MARK: - Struct
    
    // 定义日历事件在视图中的位置
    private struct EventPosition {
        let event: CalendarEvent
        let yStart: CGFloat
        let yEnd: CGFloat
        
        /// 高度
        var height: CGFloat {
            return max(yEnd - yStart, 0.0)
        }
        
        /// 检查两个事件是否位置重叠
        func overlaps(with other: EventPosition, contentHeight: CGFloat? = nil) -> Bool {
            let currentContentYEnd: CGFloat
            let otherContentYEnd: CGFloat
            if let contentHeight = contentHeight {
                currentContentYEnd = yStart + contentHeight
                otherContentYEnd = other.yStart + contentHeight
            } else {
                currentContentYEnd = yEnd
                otherContentYEnd = other.yEnd
            }
            
            return yStart < otherContentYEnd && other.yStart < currentContentYEnd
        }
    }
    
    private struct EventAssignment {
        let position: EventPosition
        let track: Int
        let maxOverlapCount: Int
    }
    
    // MARK: - 并查集数据结构
    private struct UnionFind {
        private var parent: [Int]
        private var rank: [Int]
        
        init(count: Int) {
            parent = Array(0..<count)
            rank = Array(repeating: 1, count: count)
        }
        
        mutating func find(_ x: Int) -> Int {
            if parent[x] != x {
                parent[x] = find(parent[x]) // 路径压缩
            }
            return parent[x]
        }
        
        mutating func union(_ x: Int, _ y: Int) {
            let rootX = find(x)
            let rootY = find(y)
            if rootX == rootY { return }
            
            // 按秩合并
            if rank[rootX] < rank[rootY] {
                parent[rootX] = rootY
            } else {
                parent[rootY] = rootX
                if rank[rootX] == rank[rootY] {
                    rank[rootX] += 1
                }
            }
        }
    }
    
}
