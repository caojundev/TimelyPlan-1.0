//
//  ChartMark.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/28.
//

import Foundation

/// 图表标记
struct ChartMark {
    
    /// x 轴数值
    let x: CGFloat
    
    /// y 轴数值
    let y: CGFloat
    
    /// 高亮文本
    var highlightText: String?
}

extension Array where Element == ChartMark {
    
    /// 获取x的最大值
    func maxXValue() -> CGFloat? {
        return self.max(by: { $0.y < $1.y })?.y
    }
    
    /// 获取y的最大值
    func maxYValue() -> CGFloat? {
        return self.max(by: { $0.y < $1.y })?.y
    }
}
