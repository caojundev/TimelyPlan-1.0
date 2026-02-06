//
//  RectangleChartMark.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/4.
//

import Foundation
import UIKit

/// 图表标记
struct RectangleChartMark {
    
    /// x 开始数值
    let xStart: CGFloat
    
    /// x 结束数值
    let xEnd: CGFloat
    
    /// y 开始数值
    let yStart: CGFloat
    
    /// y 结束数值
    let yEnd: CGFloat
    
    /// 区域颜色
    var color: UIColor = Color(0x5856D6) 
    
    /// 高亮文本
    var highlightText: String?
}
