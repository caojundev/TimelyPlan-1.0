//
//  ChartAxisLabelMark+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/2.
//

import Foundation

extension ChartAxisLabelMark {
    
    /// 时间线坐标轴标签标记
    /// - Parameters:
    ///   - fromHour: 开始时间
    ///   - toHour: 结束时间
    ///   - step: 小时步长
    ///   - isSecondsValue: 是否以秒为单位
    /// - Returns: 时间线标签标记数组
    static func timelineMarks(fromHour: Int,
                              toHour: Int,
                              step: Int,
                              isSecondsValue: Bool = false) -> [ChartAxisLabelMark] {
        
        let multiplier = isSecondsValue ? SECONDS_PER_HOUR : 1
        var labelMarks: [ChartAxisLabelMark] = []
        var hour = fromHour
        while hour <= toHour {
            var text: String
            if hour == HOURS_PER_DAY {
                text = "00:00"
            } else {
                text = String(format: "%02ld:00", hour)
            }
            
            let mark = ChartAxisLabelMark(value: hour * multiplier, text: text)
            labelMarks.append(mark)
            hour += step
        }
        
        return labelMarks
    }
}
