//
//  ChartItem.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/4.
//

import Foundation
import UIKit

/// 图表条目
class ChartItem {
    
    /// x轴
    var xAxis: ChartAxis = ChartAxis()
    
    /// y轴
    var yAxis: ChartAxis = ChartAxis()
    
    /// x轴标签高度
    var xAxisLabelHeight: CGFloat = 35.0
    
    /// y坐标位置
    var yAxisPosition: ChartYAxisPosition  = .left
    
    /// y轴标签最小宽度
    var yAxisLabelMinWidth = 0.0
    
    /// y轴标签最大宽度
    var yAxisLabelMaxWidth = 80.0
}

/// 柱状图表条目
class BarChartItem: ChartItem {
    
    /// 柱标记数组
    var barMarks: [ChartMark] = []

    /// 两柱之间最小间距
    var minimumBarMargin: CGFloat = 2.0
    
    /// 柱最小宽度
    var minimumBarWidth: CGFloat = 4.0
    
    /// 柱最大宽度
    var maximumBarWidth: CGFloat = 30.0
    
    /// 柱颜色
    var barColor: UIColor = Color(0x5856D6)
   
    /// 柱背景色
    var barBackColor: UIColor?
}

class CurveChartItem: PointChartItem {
    
    /// 曲线颜色
    var lineColor: UIColor = .primary
}

class PointChartItem: ChartItem {
    
    /// 坐标点标记数组
    var pointMarks: [ChartMark] = []
}

class RectangleChartItem: ChartItem {
    
    /// 矩形标记数组
    var rectangleMarks: [RectangleChartMark] = []
}
