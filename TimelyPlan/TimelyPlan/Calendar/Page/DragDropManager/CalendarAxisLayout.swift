//
//  CalendarAxisLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/16.
//

import Foundation

class CalendarAxisLayout {
    
    // 小时高度
    var hourHeight: CGFloat = 80.0
    
    // 顶部间距
    let topMargin: CGFloat = 20
    
    // 底部间距
    let bottomMargin: CGFloat = 20
    
    /// 内容高度
    var contentHeight: CGFloat {
        let height = timelineHeight + topMargin + bottomMargin
        return height
    }
    
    /// 时间线高度
    var timelineHeight: CGFloat {
        return hourHeight * CGFloat(HOURS_PER_DAY)
    }
    
    /// 吸附分钟数
    let snapGridMinutes: Int = 5
    
    /// 获取整点的位置
    func position(of hour: Int) -> CGPoint {
        let y = topMargin + hourHeight * CGFloat(hour)
        return CGPoint(x: 0.0, y: y)
    }
    
    /// 获取日期对应的位置
    func position(of date: Date) -> CGPoint {
        let offset = date.offset()
        let timelineHeight = hourHeight * CGFloat(HOURS_PER_DAY)
        let y = topMargin + timelineHeight * CGFloat(offset) / CGFloat(SECONDS_PER_DAY)
        return CGPoint(x: 0.0, y: y)
    }
    
    func date(of position: CGPoint) -> Date {
        let timeOffset = timeOffset(of: position)
        return Date().dateWithTimeOffset(timeOffset)
    }
    
    func timeOffset(of position: CGPoint) -> Duration {
        let percent = (position.y - topMargin) / timelineHeight
        let offset = CGFloat(SECONDS_PER_DAY) * clampedValue(percent, 0.0, 1.0)
        return Duration(round(offset))
    }
    
    /// 根据吸附分钟数获取特定位置对应的吸附位置
    private var gridUnit: CGFloat {
        return CGFloat(snapGridMinutes) / CGFloat(MINUTES_PER_HOUR) * hourHeight
    }
    
    func snappedPosition(of position: CGPoint) -> CGPoint {
        let gridUnit = gridUnit
        var snappedY = topMargin + round((position.y - topMargin) / gridUnit) * gridUnit
        snappedY = clampedValue(snappedY, topMargin, topMargin + timelineHeight)
        return CGPoint(x: position.x, y: snappedY)
    }
    
    func snappedHeight(of height: CGFloat) -> CGFloat {
        let gridUnit = gridUnit
        return round(height / gridUnit) * gridUnit
    }
    
    func snappedFrame(of rect: CGRect, minHeight: CGFloat) -> CGRect {
        var snappedY = snappedPosition(of: rect.origin).y
        var snappedHeight = snappedHeight(of: rect.height)
        
        // 防止吸附后太小
        if snappedHeight < minHeight {
            snappedHeight = minHeight
        }
        
        // 防止吸附后超出屏幕下方
        let maxY = topMargin + timelineHeight
        if snappedY + snappedHeight > maxY {
            snappedY = maxY - snappedHeight
        }
        
        if snappedY < topMargin {
            snappedY = topMargin
        }
        
        return CGRect(x: rect.minX,
                      y: snappedY,
                      width: rect.width,
                      height: snappedHeight)
    }
    
    func dateRange(of frame: CGRect) -> DateInterval {
        let startDate = date(of: frame.origin)
        let endPoint = CGPoint(x: 0.0, y: frame.maxY)
        let endDate = date(of: endPoint)
        return DateInterval(start: startDate, end: endDate)
    }
    
    func frame(of dateRange: DateInterval, minHeight: CGFloat) -> CGRect {
        let startPosition = position(of: dateRange.start)
        let endPosition = position(of: dateRange.end)
        var height = endPosition.y - startPosition.y
        if height < minHeight {
            height = minHeight
        }
        
        return CGRect(x: 0.0,
                      y: startPosition.y,
                      width: 0.0,
                      height: height)
    }
    
    func snappedDateRange(onDay dayDate: Date,
                          touchPoint: CGPoint,
                          minutes: Int = 30) -> DateInterval {
        let position = snappedPosition(of: touchPoint)
        var startDate = date(of: position)
        var endDate = startDate.dateByAddingMinutes(minutes)!
        if !endDate.isInSameDayAs(startDate) {
            endDate = startDate.endOfDay()
            startDate = endDate.dateByAddingMinutes(-minutes)!
        }
        
        startDate = startDate.dateByReplacingDay(with: dayDate)
        endDate = endDate.dateByReplacingDay(with: dayDate)
        return DateInterval(start: startDate, end: endDate)
    }
}
