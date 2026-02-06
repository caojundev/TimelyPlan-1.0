//
//  CalendarStripLayoutProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/25.
//

import Foundation

/// 事件位置信息
struct CalendarEventPosition {
    
    /// 事件在周视图中的列（从0开始）
    let column: Int
    
    /// 事件跨越的长度
    let length: Int
}

struct CalendarEventPath {
    
    /// 事件在周视图中的行（从0开始）
    let row: Int
    
    /// 事件跨越的长度（以列为单位）
    let position: CalendarEventPosition
}

struct CalendarEventPathInfo {
    
    /// 事件
    let event: CalendarEvent
    
    /// 位置信息
    let path: CalendarEventPath
}

struct CalendarEventLayout {
    
    /// 路径信息
    let pathInfos: [CalendarEventPathInfo]
    
    /// 横跨天数
    let days: Int
    
    /// column 对应的 pathInfo 数组
    private let columnPathInfos: [[CalendarEventPathInfo]]
    
    init(pathInfos: [CalendarEventPathInfo], days: Int = DAYS_PER_WEEK) {
        self.pathInfos = pathInfos
        self.days = days
        self.columnPathInfos = CalendarEventLayout.pathInfosByColumn(for: pathInfos, days: days)
    }
    
    private static func pathInfosByColumn(for pathInfos: [CalendarEventPathInfo], days: Int) -> [[CalendarEventPathInfo]] {
        var pathInfosByColumn = [[CalendarEventPathInfo]](repeating: [], count: days)
        for pathInfo in pathInfos {
            let position = pathInfo.path.position
            let column = position.column
            let length = position.length
            if length < 0 {
                continue
            }
            
            for i in 0...length {
                if column + i < days {
                    pathInfosByColumn[column + i].append(pathInfo)
                }
            }
        }
        
        return pathInfosByColumn
    }
    
    /// 获取特定列的事件数目
    func eventsCount(at column: Int) -> Int {
        guard column >= 0, column < days else {
            return 0
        }
        
        return columnPathInfos[column].count
    }
    
    /// 获取特定列对应的最大行索引，如果列没有事件则返回 -1
    func maxRow(at column: Int) -> Int {
        guard column >= 0, column < days else {
            return -1
        }
        
        let pathInfos = columnPathInfos[column]
        let maxRow = pathInfos.map { $0.path.row }.max()
        return maxRow ?? -1
    }
    
}

class CalendarStripLayoutProvider {
    
    private struct PositionInfo {
        let event: CalendarEvent
        let position: CalendarEventPosition
    }

    func layout(events: [CalendarEvent], firstDate: Date, days: Int = DAYS_PER_WEEK) -> CalendarEventLayout {
        /// 排序事件位置信息
        let sortedPositionInfos = sortedPositionInfos(for: events, firstDate: firstDate, days: days)
        let pathInfos = pathInfos(for: sortedPositionInfos, days: days)
        return CalendarEventLayout(pathInfos: pathInfos, days: days)
    }
    
    private func sortedPositionInfos(for events: [CalendarEvent],
                                     firstDate: Date,
                                     days: Int = DAYS_PER_WEEK) -> [PositionInfo] {
        var positionInfos = [PositionInfo]()
        for event in events {
            
            if let position = event.position(firstDate: firstDate, days: days) {
                let positionInfo = PositionInfo(event: event, position: position)
                positionInfos.append(positionInfo)
            }
        }
        
        /// 排序事件位置信息
        let sortedPositionInfos = positionInfos.sorted {
            if $0.position.column == $1.position.column {
                if $0.position.length == $1.position.length {
                    return $0.event.startDate < $1.event.startDate
                }
                
                return $0.position.length > $1.position.length
                
            }
            
            return $0.position.column < $1.position.column
        }
        
        return sortedPositionInfos
    }
    
    private func pathInfos(for positionInfos: [PositionInfo],
                           days: Int = DAYS_PER_WEEK) -> [CalendarEventPathInfo] {
        var pathInfos = [CalendarEventPathInfo]()
        var rowEnds = [Int](repeating: 0, count: days)
        
        for positionInfo in positionInfos {
            let event = positionInfo.event
            let position = positionInfo.position
            
            // 使用优先队列（最小堆）来找到第一个可以放置该事件的行
            var row = 0
            while row < rowEnds.count {
                if rowEnds[row] <= position.column {
                    break
                }
                row += 1
            }
            
            // 如果找到合适的行，更新该行的结束位置
            if row < rowEnds.count {
                rowEnds[row] = position.column + position.length + 1
                
                // 创建路径信息
                let path = CalendarEventPath(row: row, position: position)
                let pathInfo = CalendarEventPathInfo(event: event, path: path)
                pathInfos.append(pathInfo)
            }
        }
        
        return pathInfos
    }
}
