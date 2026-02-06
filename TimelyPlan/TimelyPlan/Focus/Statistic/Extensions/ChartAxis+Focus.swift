//
//  ChartAxis+Focus.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/1.
//

import Foundation

extension ChartAxis {
    
    /// 设置默认的时长y轴
    static var defaultDurationYAxis: ChartAxis {
        let labelMarks = [ChartAxisLabelMark(value: 0, text: "0m"),
                           ChartAxisLabelMark(value: 20 * 60, text: "20m"),
                           ChartAxisLabelMark(value: 40 * 60, text: "40m"),
                           ChartAxisLabelMark(value: 60 * 60, text: "1h")]
        let range = ChartAxisRange(minValue: 0.0, maxValue: 3600.0)
        var axis = ChartAxis(range: range, labelMarks: labelMarks)
        axis.guideline = ChartGuideline(range: range, step: 1200.0)
        axis.labelStyle.textAlignment = .right
        return axis
    }
}
