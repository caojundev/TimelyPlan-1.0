//
//  RectangleChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/4.
//

import Foundation
import UIKit

class RectangleChartView: BaseChartView {
    
    /// 柱标记
    var rectangleMarks: [RectangleChartMark] = []
    
    /// 柱视图数组
    private var elementViews = [RectangleElementView]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.highlightView.margin = 15.0
        self.highlightView.startFromElement = true
        self.highlightView.endOnTop = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func strokeChart(with chartItem: ChartItem) {
        super.strokeChart(with: chartItem)
        let chartItem = chartItem as! RectangleChartItem
        self.rectangleMarks = chartItem.rectangleMarks
        self.isEmpty = rectangleMarks.count == 0
        self.removeViews(elementViews)
        self.setupElementViews()
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutElementViews()
    }
    
    func setupElementViews() {
        var elementViews: [RectangleElementView] = []
        for rectangleMark in rectangleMarks {
            let elementView = RectangleElementView(mark: rectangleMark)
            elementView.backgroundColor = rectangleMark.color
            elementViews.append(elementView)
            canvasView.addSubview(elementView)
        }
        
        self.elementViews = elementViews
    }
    
    func layoutElementViews() {
        for elementView in elementViews {
            let mark = elementView.mark
            elementView.frame = rectangleFrame(for: mark)
        }
    }
    
    private func rectangleFrame(for mark: RectangleChartMark) -> CGRect {
        let topLeft = position(xValue: xAxis.validatedValue(mark.xStart),
                               yValue: yAxis.validatedValue(mark.yEnd))
        let bottomRight = position(xValue: xAxis.validatedValue(mark.xEnd),
                                   yValue: yAxis.validatedValue(mark.yStart))
        let width = max(bottomRight.x - topLeft.x, 0.0)
        let height = max(bottomRight.y - topLeft.y, 0.0)
        let frame = CGRect(x: topLeft.x, y: topLeft.y, width: width, height: height)
        return frame
    }
    
    override func element(at point: CGPoint) -> ChartHighlightEelement? {
        let height = self.canvasView.height
        var views = [RectangleElementView]()
        for elementView in elementViews {
            let rect = CGRect(x: elementView.left, y: 0.0, width: elementView.width, height: height)
            if rect.contains(point) {
                views.append(elementView)
            }
        }
        
        return views.verticalClosestView(to: point)
    }
}

