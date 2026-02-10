//
//  FocusTimelineEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation

class FocusTimelineEvent: NSObject {
    
    /// 名称
    var name: String? {
        return session.timerShotName
    }
    
    /// 开始日期
    var startDate: Date {
        return session.startDate ?? .now
    }
    
    /// 结束日期
    var endDate: Date {
        return session.endDate ?? .now
    }
    
    /// 专注时长
    var focusDuration: Duration {
        return Duration(timeline.focusInterval)
    }
    
    /// 颜色
    let color: UIColor
    
    let session: FocusSession
    
    let timeline: FocusRecordTimeline
    
    init(session: FocusSession) {
        self.session = session
        self.timeline = session.recordTimeline
        self.color = CalendarEventColor.random
        super.init()
    }
}
