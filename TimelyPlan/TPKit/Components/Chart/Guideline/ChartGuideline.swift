//
//  ChartGuidelineLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/30.
//

import Foundation

struct ChartGuideline {
    
    enum LineStyle {
        case solid /// 实线
        case dash  /// 虚线
    }
    
    /// 线条样式
    var style: LineStyle = .dash
    
    /// 线条颜色
    var color = Color(0x888888, 0.2)
    
    /// 辅助线坐标数值范围
    var range: ChartAxisRange
    
    /// 辅助线数值数组
    var values: [CGFloat]?
    
    /// 虚线图案样式
    private var _dashPattern: [NSNumber]? = [4.0, 4.0]
    var dashPattern: [NSNumber]? {
        get {
            return style == .dash ? _dashPattern : nil
        }
        
        set {
            _dashPattern = newValue
        }
    }
    
    init(range: ChartAxisRange, values: [CGFloat]? = nil) {
        self.range = range
        self.values = values
    }
    
    init(range: ChartAxisRange, from: CGFloat? = nil, to: CGFloat? = nil, step: CGFloat) {
        self.range = range
        self.setupValues(from: from, to: to, step: step)
    }
    
    /// 设置x轴辅助线
    mutating func setupValues(from: CGFloat? = nil,
                              to: CGFloat? = nil,
                              step: CGFloat = 1.0) {
        var values: [CGFloat] = []
        var value: CGFloat
        if let from = from {
            value = max(range.minValue, from)
        } else {
            value = range.minValue
        }
        
        let toValue = to ?? .greatestFiniteMagnitude
        while value <= range.maxValue && value < toValue {
            values.append(value)
            value += step /// 添加步长
        }
        
        self.values = values
    }
}
