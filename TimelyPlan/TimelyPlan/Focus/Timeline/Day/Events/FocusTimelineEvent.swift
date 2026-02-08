//
//  FocusTimelineEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation

class FocusTimelineEvent: NSObject {
    
    /// 名称
    var name: String?
    
    /// 颜色
    let color: UIColor
    
    /// 开始日期
    let startDate: Date
    
    /// 结束日期
    let endDate: Date
    
    /// 专注时长
    let focusDuration: Duration
    
    init(name: String?, color: UIColor, startDate: Date, endDate: Date, focusDuration: Duration) {
        self.name = name
        self.color = color
        self.startDate = startDate
        self.endDate = endDate
        self.focusDuration = focusDuration
        super.init()
    }
}
