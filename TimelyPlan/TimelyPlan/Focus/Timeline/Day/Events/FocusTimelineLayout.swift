//
//  FocusTimelineLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation
import UIKit

// MARK: - 时间线布局工具
final class FocusTimelineLayout {
    
    // 定义日历事件在视图中的位置
    private struct EventPosition {
        let event: FocusTimelineEvent
        let yStart: CGFloat
        let yEnd: CGFloat
        
        /// 高度
        var height: CGFloat {
            return max(yEnd - yStart, 0.0)
        }
        
        /// 检查两个事件是否位置重叠
        func overlaps(with other: EventPosition) -> Bool {
           return yStart < other.yEnd && other.yStart < yEnd
        }
    }
    
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

    /// 时间线日期范围
    let dateRange: CalendarTimelineDateRange
    
    let events: [FocusTimelineEvent]
    
    private var eventFrames: [FocusTimelineEvent: CGRect] = [:]
    
    private var needsLayout: Bool = true
    
    init(events: [FocusTimelineEvent]?, dateRange: CalendarTimelineDateRange) {
        self.events = events ?? []
        self.dateRange = dateRange
    }
    
    // MARK: - 公有方法
    func setNeedsLayout() {
        needsLayout = true
    }
    
    func frame(for event: FocusTimelineEvent) -> CGRect {
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
                if positions[i].overlaps(with: positions[j]) {
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
    private func assignEventPositionsToTracks(_ eventPositions: [EventPosition]) -> [(eventPosition: EventPosition, track: Int)] {
        let sortedEventPositions = eventPositions.sorted { $0.yStart < $1.yStart }
        var tracks: [CGFloat] = [] // 记录每个轨道的最后结束位置
        var assignments: [(EventPosition, Int)] = []
        for eventPosition in sortedEventPositions {
            // 查找第一个可用的轨道
            var availableTrack: Int?
            for (index, lastEnd) in tracks.enumerated() where lastEnd <= eventPosition.yStart {
                availableTrack = index
                break
            }
            
            if let track = availableTrack {
                // 占用现有轨道
                tracks[track] = eventPosition.yEnd
                assignments.append((eventPosition, track))
            } else {
                // 创建新轨道
                tracks.append(eventPosition.yEnd)
                assignments.append((eventPosition, tracks.count - 1))
            }
        }
        
        return assignments
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
    
    // MARK: - Helpers
    private func layout() {
        let eventPositions = events.map { calculatePosition(for: $0) }
        var eventFrames: [FocusTimelineEvent: CGRect] = [:]
        let groups = groupOverlappingEventPositions(eventPositions)
        for group in groups {
            let maxOverlapsCount = calculateMaxOverlapCount(in: group)
            let trackAssignments = assignEventPositionsToTracks(group)
            for trackAssignment in trackAssignments {
                let eventPosition = trackAssignment.eventPosition
                let frame = frameForEventPosition(eventPosition,
                                                  track: trackAssignment.track,
                                                  maxOverlapsCount: maxOverlapsCount)
                eventFrames[eventPosition.event] = frame
            }
        }

        self.eventFrames = eventFrames
    }
    
    /// 计算事件的垂直位置和高度
    private func calculatePosition(for event: FocusTimelineEvent) -> EventPosition {
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
    
    private func frameForEventPosition(_ eventPosition: EventPosition, track: Int, maxOverlapsCount: Int) -> CGRect {
        let overlapsCount = max(maxOverlapsCount, 1)
        let eventWidth = (containerSize.width - 2 * edgeMargin - CGFloat(overlapsCount - 1) * eventMargin) / CGFloat(overlapsCount)
        let x = edgeMargin + CGFloat(track) * (eventWidth + eventMargin)
        return CGRect(x: x, y: eventPosition.yStart, width: eventWidth, height: eventPosition.height)
    }
}
