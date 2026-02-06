//
//  BarChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/28.
//

import Foundation
import UIKit

class BarChartView: BaseChartView {
    
    /// 柱状图绘制颜色
    var barColor: UIColor = Color(0x5856D6)
    
    /// 柱背景色
    var barBackColor: UIColor?
    
    /// 两柱之间最小间距
    var minimumBarMargin: CGFloat = 2.0
    
    /// 柱最小宽度
    var minimumBarWidth: CGFloat = 4.0
    
    /// 柱最大宽度
    var maximumBarWidth: CGFloat = 30.0
    
    /// 柱标记
    var barMarks: [ChartMark] = []
    
    /// 柱视图数组
    private var bars = [BarElementView]()

    override func strokeChart(with chartItem: ChartItem) {
        super.strokeChart(with: chartItem)
        if let chartItem = chartItem as? BarChartItem {
            minimumBarMargin = chartItem.minimumBarMargin
            minimumBarWidth = chartItem.minimumBarWidth
            maximumBarWidth = chartItem.maximumBarWidth
            barMarks = chartItem.barMarks
            barColor = chartItem.barColor
            barBackColor = chartItem.barBackColor
        } else {
            barMarks = []
        }
        
        self.isEmpty = barMarks.count == 0
        self.removeViews(bars)
        self.setupBars()
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBars()
    }
    
    func setupBars() {
        var bars: [BarElementView] = []
        for (index, mark) in barMarks.enumerated() {
            if mark.x > xAxis.range.maxValue ||
                mark.x < xAxis.range.minValue ||
                mark.y < yAxis.range.minValue {
                continue
            }

            let bar = BarElementView(mark: mark)
            bar.tag = index
            bars.append(bar)
            canvasView.addSubview(bar)
        }
        
        self.bars = bars
    }
    
    func layoutBars() {
        var barWidth = stepWidth - minimumBarMargin
        barWidth = min(max(minimumBarWidth, barWidth), maximumBarWidth)
        let canvasFrame = canvasFrame
        for bar in bars {
            bar.barColor = barColor
            bar.barBackColor = barBackColor
            let position = positionForChartMark(bar.mark)
            bar.frame = CGRect(x: position.x - barWidth / 2.0,
                               y: canvasFrame.minY,
                               width: barWidth,
                               height: canvasFrame.height)
            bar.grade = validatedProgress(bar.mark.y / yAxis.range.maxValue)
        }
    }
    
    override func element(at point: CGPoint) -> ChartHighlightEelement? {
        for bar in bars {
            if bar.frame.contains(point) {
                return bar
            }
        }

        return nil
    }
}
