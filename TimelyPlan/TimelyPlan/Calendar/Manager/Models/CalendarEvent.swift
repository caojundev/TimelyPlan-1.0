//
//  CalendarEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/23.
//

import Foundation
import UIKit

class CalendarEventColor {
    
    ///日历事件颜色
    static let colors = [Color(0x999DA8),
                         Color(0x34B729),
                         Color(0x4286F5),
                         Color(0xC274FF),
                         Color(0x7E64FD),
                         Color(0x01CFD4),
                         Color(0x00CF85),
                         Color(0xD40102),
                         Color(0xF3501D),
                         Color(0xFE887C),
                         Color(0xF6BF25)]
    
    /// 默认颜色
    static let defaultColor: UIColor = colors[3]
    
    /// 随机事件颜色
    static var random: UIColor {
        let index = Int(arc4random()) % colors.count
        return colors[index]
    }
    
    /// 获取事件颜色对应的背景色
    static func backgroundColor(for eventColor: UIColor) -> UIColor {
        return eventColor.withAlphaComponent(0.25)
    }
    
    static func foregroundColor(for eventColor: UIColor) -> UIColor {
        let lightColor = eventColor.withBrightness(0.3)
        let darkColor = eventColor.withSaturation(0.3)
        return UIColor(.dm, light: lightColor, dark: darkColor)
    }
    
    static func highlightedForegroundColor(for eventColor: UIColor) -> UIColor {
        return .white
    }
}


class CalendarEvent: NSObject {
    
    /// 名称
    var name: String?
    
    /// 颜色
    let color: UIColor
    
    /// 开始日期
    let startDate: Date
    
    /// 结束日期
    let endDate: Date
    
    init(name: String?, color: UIColor, startDate: Date, endDate: Date) {
        self.name = name
        self.color = color
        self.startDate = startDate
        self.endDate = endDate
        super.init()
    }
}

extension CalendarEvent {
    
    /// 根据开始日期和布局持续天数，获取事件对应的位置
    func position(firstDate: Date, days: Int = DAYS_PER_WEEK) -> CalendarEventPosition? {
        var column = Date.days(fromDate: firstDate, toDate: startDate)
        var length = Date.days(fromDate: startDate, toDate: endDate)
        if length < 0 || column >= days || column + length < 0 {
            return nil
        }
        
        let maxLength = days - 1
        if column < 0 {
            length = min(column + length, maxLength)
            column = 0
        } else {
            if column + length > maxLength {
                length = maxLength - column
            }
        }
        
        return CalendarEventPosition(column: column, length: length)
    }
}
