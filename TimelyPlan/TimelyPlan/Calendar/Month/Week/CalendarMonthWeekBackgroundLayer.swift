//
//  CalendarMonthWeekBackgroundLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/27.
//

import Foundation

class CalendarMonthWeekBackgroundLayer: TPGridsLayer {
    
    var weekStartDate: Date? {
        didSet {
            updateMonthSeparatorLayerPath()
        }
    }
    
    private let monthSeparatorLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 2.0
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.gray.cgColor
        return layer
    }()
    
    override init() {
        super.init()
        setupLayer()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayer() {
        var style = TPGridsLayoutStyle()
        style.rowsCount = 1
        style.columsCount = DAYS_PER_WEEK
        style.fromColum = 1
        style.toColum = 6
        style.fromRow = 1
        style.toRow = 1
        style.lineWidth = 0.4
        style.lineColor = Color(0x888888, 0.2)
        self.layoutStyle = style
        addSublayer(monthSeparatorLayer)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        monthSeparatorLayer.frame = bounds
        CATransaction.commit()
        updateMonthSeparatorLayerPath()
    }
    
    func updateMonthSeparatorLayerPath() {
        guard let weekStartDate = weekStartDate else {
            monthSeparatorLayer.path = nil
            return
        }
        
        let monthEndDate = weekStartDate.endOfMonth()
        let lastDays = Date.days(fromDate: weekStartDate, toDate: monthEndDate)
        guard lastDays < DAYS_PER_WEEK else {
            monthSeparatorLayer.path = nil
            return
        }
        
        let frame = bounds.inset(by: .zero)
        let columnWidth = frame.width / CGFloat(DAYS_PER_WEEK)
        let bezierPath = UIBezierPath()
        
        let column = lastDays + 1
        let columnX = CGFloat(column) * columnWidth
        let y = bounds.height - lineWidth / 2.0
        bezierPath.move(to: CGPoint(x: frame.minX, y: y))
        bezierPath.addLine(to: CGPoint(x: columnX, y: y))
        if column >= layoutStyle.fromColum && column <= layoutStyle.toColum {
            bezierPath.addLine(to: CGPoint(x: columnX, y: lineWidth / 2.0))
            bezierPath.addLine(to: CGPoint(x: frame.maxX, y: lineWidth / 2.0))
        }
        
        monthSeparatorLayer.path = bezierPath.cgPath
    }
}
