//
//  CalendarEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

protocol CalendarEventProvider {
    
    /// 获取特定日期范围的事项
    func fetchEvents(in range: DateInterval, completion: @escaping([CalendarEvent]?) -> Void)
}
