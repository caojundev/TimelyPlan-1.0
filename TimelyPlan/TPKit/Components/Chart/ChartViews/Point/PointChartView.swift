//
//  DotChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/30.
//

import Foundation
import UIKit

class PointChartView: BaseChartView {
    
    var dotSize: CGSize = CGSize(width: 8.0, height: 8.0)
    
    var pointMarks: [ChartMark] = []
    
    private var elementViews = [PointElementView]()
    
    /// 圆点视图
    let pointsView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.highlightView.margin = 20.0
        self.highlightView.startFromElement = true
        self.highlightView.endOnTop = false
        self.canvasView.addSubview(self.pointsView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pointsView.frame = canvasView.bounds
        layoutElementViews()
    }

    override func strokeChart(with chartItem: ChartItem) {
        super.strokeChart(with: chartItem)
        let chartItem = chartItem as! PointChartItem
        self.pointMarks = chartItem.pointMarks
        self.isEmpty = pointMarks.count == 0
        self.setupElementViews()
        self.setNeedsLayout()
    }

    func setupElementViews() {
        self.removeViews(self.elementViews)
        var elementViews = [PointElementView]()
        for (index, mark) in pointMarks.enumerated() {
            guard xAxis.contains(mark.x) && yAxis.contains(mark.y) else {
                continue
            }
            
            let elementView = PointElementView(mark: mark)
            elementView.tag = index
            pointsView.addSubview(elementView)
            elementViews.append(elementView)
        }
        
        self.elementViews = elementViews
        self.isEmpty = elementViews.count == 0
    }
    
    func layoutElementViews() {
        super.layoutSubviews()
        for elementView in elementViews {
            elementView.size = dotSize
            elementView.center = positionForChartMark(elementView.mark)
        }
    }
    
    /// 获取触摸点处的点
    override func element(at point: CGPoint) -> ChartHighlightEelement? {
        let width = self.stepWidth
        let height = self.canvasView.height
        var views = [PointElementView]()
        for view in elementViews {
            let rect = CGRect(x: view.left - width / 2.0, y: 0.0, width: width, height: height)
            if rect.contains(point) {
                views.append(view)
            }
        }
        
        return views.verticalClosestView(to: point)
    }
}
