//
//  CalendarAxisLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/16.
//

import Foundation

struct CalendarAxisLayout {
    
    // 小时高度
    var hourHeight: CGFloat = 80.0
    
    // 顶部间距
    let topMargin: CGFloat = 20
    
    // 底部间距
    let bottomMargin: CGFloat = 20
    
    /// 内容高度
    var contentHeight: CGFloat {
        let height = hourHeight * CGFloat(HOURS_PER_DAY) + topMargin + bottomMargin
        return height
    }
    
    /// 获取整点的位置
    func position(of hour: Int) -> CGPoint {
        let y = topMargin + hourHeight * CGFloat(hour)
        return CGPoint(x: 0.0, y: y)
    }
    
    /// 获取日期对应的位置
    func position(of date: Date) -> CGPoint {
        let offset = date.offset()
        let timelineHeight = hourHeight * CGFloat(HOURS_PER_DAY)
        let y = timelineHeight * CGFloat(offset) / CGFloat(SECONDS_PER_DAY)
        return CGPoint(x: 0.0, y: y)
    }
}
