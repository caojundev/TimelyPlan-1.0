//
//  CalendarRangeEventsInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/9.
//

import Foundation
import UIKit

struct CalendarRangeEventsInfo {
    
    let range: DateInterval
    
    var dayColors: [DateComponents: [UIColor]] // 所有天的事项信息
    
    func eventColors(for dateComponents: DateComponents) -> [UIColor]? {
        return dayColors[dateComponents]
    }
}

// MARK: - 事项数据获取协议
protocol CalendarRangeEventsProvider: AnyObject {
    /// 异步获取指定日期范围的事项绘制信息
    /// - Returns: 可用于取消请求的标识，如果为nil表示不支持取消
    func fetchRangeEventsInfo(in range: DateInterval, completion: @escaping (CalendarRangeEventsInfo) -> Void)
    
    /// 取消指定范围的请求（可选实现）
    func cancelFetchForRange(_ range: DateInterval)
    
    /// 添加事项变化代理对象
    func addEventChangeDelegate(_ delegate: CalendarEventChangeDelegate)
}

// 默认实现，取消方法可选
extension CalendarRangeEventsProvider {
    func cancelFetchForRange(_ range: DateInterval) { }
}
