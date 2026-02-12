//
//  ChartAxis.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/30.
//

import Foundation

/// 统计图坐标轴的数值范围
struct ChartAxisRange {
    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 1.0
    
    var length: CGFloat {
        let value = maxValue - minValue
        return value <= 0 ? 1.0 : value
    }
    
    init() { }
    
    init(minValue: CGFloat, maxValue: CGFloat) {
        self.minValue = minValue
        self.maxValue = maxValue
    }
    
    /// 判断区间是否包含数值
    func contains(_ value: CGFloat) -> Bool {
        return value >= minValue && value <= maxValue
    }
    
    /// 返回区间内一个有效数值
    func validatedValue(_ value: CGFloat) -> CGFloat {
        return max(min(value, maxValue), minValue)
    }
}

struct ChartAxis {
    
    /// 坐标范围
    var range: ChartAxisRange
    
    /// 步长数值
    var stepValue: CGFloat = 1.0
    
    /// 最小的步长宽度
    var minimumStepWidth: CGFloat = 0.0
    
    var stepsCount: Int {
        return Int(ceil(range.length / stepValue))
    }
    
    /// 标签标记
    var labelMarks: [ChartAxisLabelMark]

    /// 标签样式
    var labelStyle: ChartAxisLabelStyle = ChartAxisLabelStyle()
    
    /// 辅助线
    var guideline: ChartGuideline?
    
    init() {
        self.range = ChartAxisRange()
        self.labelMarks = []
    }
    
    init(range: ChartAxisRange, labelMarks: [ChartAxisLabelMark]) {
        self.range = range
        self.labelMarks = labelMarks
    }
    
    /// 判断区间是否包含数值
    func contains(_ value: CGFloat) -> Bool {
        return range.contains(value)
    }
    
    /// 返回区间内一个有效数值
    func validatedValue(_ value: CGFloat) -> CGFloat {
        return range.validatedValue(value)
    }
    
    static func axis(chartMarks: [ChartMark],
                     minValue: CGFloat = 0.0,
                     maxValue: CGFloat,
                     titleOfValue: ((CGFloat)-> String?)? = nil) -> ChartAxis {
        let result = ChartIntermediateValue.result(with: maxValue)
        let range = ChartAxisRange(minValue: minValue, maxValue: result.maxValue)
        var labelMarks = [ChartAxisLabelMark]()
        let values = [range.minValue] + (result.values ?? []) + [range.maxValue]
        for value in values {
            var title = titleOfValue?(value)
            if title == nil {
                title = value.string(decimalPlaces: 1)
            }
            
            let labelMark = ChartAxisLabelMark(value: value, text: title)
            labelMarks.append(labelMark)
        }
        
        return ChartAxis(range: range, labelMarks: labelMarks)
    }
    
    /// y轴坐标
    private static func yAxis(chartMarks: [ChartMark],
                              titleOfValue: ((CGFloat)-> String?)? = nil) -> ChartAxis {
        let maxValue = chartMarks.maxYValue() ?? 0.0
        let axis = axis(chartMarks: chartMarks,
                        minValue: 0.0,
                        maxValue: maxValue,
                        titleOfValue: titleOfValue)
        return axis
    }
    
    static func yAxisWithGuideline(chartMarks: [ChartMark],
                                   titleOfValue: ((CGFloat)-> String?)? = nil) -> ChartAxis {
        var axis = yAxis(chartMarks: chartMarks, titleOfValue: titleOfValue)
        axis.labelStyle.numberOfLines = 1
        let values = axis.labelMarks.map{ return $0.value}
        let guideline = ChartGuideline(range: axis.range, values: values)
        axis.guideline = guideline
        return axis
    }
}

extension ChartAxis {
    
    /// 获取一周天坐标轴
    static func weekDaysAxis(date: Date = .now,
                             firstWeekday: Weekday = .firstWeekday) -> ChartAxis {
        let dates = date.thisWeekDays(firstWeekday: firstWeekday.rawValue)
        var labelMarks = [ChartAxisLabelMark]()
        for (index, date) in dates.enumerated() {
            let symbol = date.shortWeekdaySymbol() + "\n\(date.day)"
            let mark = ChartAxisLabelMark(value: CGFloat(index + 1), text: symbol)
            labelMarks.append(mark)
        }
        
        let range = ChartAxisRange(minValue: 0.5, maxValue: 7.5)
        var axis = ChartAxis(range: range, labelMarks: labelMarks)
        axis.labelStyle.numberOfLines = 0
        axis.guideline = ChartGuideline(range: axis.range, step: 1.0)
        return axis
    }
    
    static func monthDaysAxis(date: Date = .now,
                              startFromZero: Bool = true) -> ChartAxis {
        let count = date.numberOfDaysInMonth()
        var labelMarks = [ChartAxisLabelMark]()
        let step: Int = 3
        for i in 1...count {
            guard i % step == 1 else {
                continue
            }
            
            let mark = ChartAxisLabelMark(value: CGFloat(i), text: "\(i)")
            labelMarks.append(mark)
        }
        
        let minValue = startFromZero ? 0 : 0.5
        let maxValue = CGFloat(date.numberOfDaysInMonth()) + (startFromZero ? 1.0 : 0.5)
        let range = ChartAxisRange(minValue: minValue, maxValue: maxValue)
        var axis = ChartAxis(range: range, labelMarks: labelMarks)
        axis.labelStyle.numberOfLines = 0
        axis.guideline = ChartGuideline(range: axis.range, step: 1.0)
        return axis
    }
    
    static func monthsAxis() -> ChartAxis {
        let symbols = Date.shortMonthSymbols
        var labelMarks = [ChartAxisLabelMark]()
        let step: Int = 2 /// 每隔两个月显示
        for (index, symbol) in symbols.enumerated() {
            guard index % step == 0 else {
                continue
            }
            
            let month = index + 1
            let mark = ChartAxisLabelMark(value: CGFloat(month), text: symbol)
            labelMarks.append(mark)
        }
        
        let minValue = 0.5
        let maxValue = CGFloat(MONTHS_PER_YEAR) + minValue
        let range = ChartAxisRange(minValue: minValue, maxValue: maxValue)
        var axis = ChartAxis(range: range, labelMarks: labelMarks)
        axis.guideline = ChartGuideline(range: axis.range, step: 1.0)
        return axis
    }

    /// 时间线坐标轴
    static func timelineXAxis() -> ChartAxis {
        let labelMarks = ChartAxisLabelMark.timelineMarks(fromHour: 2,
                                                          toHour: 24,
                                                          step: 4,
                                                          isSecondsValue: false)
        let range = ChartAxisRange(minValue: -1.0, maxValue: 24.0)
        var axis = ChartAxis(range: range, labelMarks: labelMarks)
        axis.guideline = ChartGuideline(range: axis.range, step: 1.0)
        return axis
    }
    
    static func timelineYAxis() -> ChartAxis {
        let step: Int = 6
        let labelMarks = ChartAxisLabelMark.timelineMarks(fromHour: 0,
                                                          toHour: 24,
                                                          step: step,
                                                          isSecondsValue: true)
        let range = ChartAxisRange(minValue: 0.0, maxValue: 24.0 * CGFloat(SECONDS_PER_HOUR))
        var axis = ChartAxis(range: range, labelMarks: labelMarks)
        axis.guideline = ChartGuideline(range: axis.range, step: CGFloat(step * SECONDS_PER_HOUR))
        return axis
    }

    /// 评分坐标轴
    static func scoreAxis() -> ChartAxis {
        let labelMarks = ChartAxisLabelMark.marks(fromValue: 0, toValue: 100, step: 20)
        let range = ChartAxisRange(minValue: 0, maxValue: 100)
        var axis = ChartAxis(range: range, labelMarks: labelMarks)
        axis.guideline = ChartGuideline(range: axis.range, step: 20)
        return axis
    }
}
