//
//  CalendarWeekTimelineBackLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/12.
//

import Foundation

class CalendarWeekTimelineBackLayer: CALayer {
    
    // 横线图层
    private let horizontalLinesLayer = CAShapeLayer()
    
    // 竖线图层
    private let verticalLinesLayer = CAShapeLayer()
    
    // 左侧分割线
    private let leftDividerLayer = CALayer()
    
    var hourHeight: CGFloat = 40 {
        didSet {
            if hourHeight != oldValue {
                updatePaths()
            }
        }
    }
    
    var topPadding: CGFloat = 20 {
        didSet {
            if topPadding != oldValue {
                updatePaths()
            }
        }
    }
    
    var bottomPadding: CGFloat = 40 {
        didSet {
            if bottomPadding != oldValue {
                updatePaths()
            }
        }
    }
    
    // 横线颜色
    var horizontalLineColor: UIColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.2) {
        didSet {
            horizontalLinesLayer.strokeColor = horizontalLineColor.cgColor
        }
    }
    
    // 竖线颜色
    var verticalLineColor: UIColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.1) {
        didSet {
            verticalLinesLayer.strokeColor = verticalLineColor.cgColor
        }
    }
    
    // 左侧分割线颜色
    var leftDividerColor: UIColor = .lightGray {
        didSet {
            leftDividerLayer.backgroundColor = leftDividerColor.cgColor
        }
    }

    var columnsCount: Int = 1 {
        didSet {
            if columnsCount != oldValue {
                updatePaths()
            }
        }
    }
    
    override init() {
        super.init()
        self.setupLayers()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setupLayers() {
        // 配置横线图层
        horizontalLinesLayer.lineWidth = 0.6
        addSublayer(horizontalLinesLayer)
        
        // 配置竖线图层
        verticalLinesLayer.lineWidth = 0.6
        addSublayer(verticalLinesLayer)

         // 配置左侧分割线
        addSublayer(leftDividerLayer)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updateColors()
        updatePaths()
        // 设置左侧分割线的frame
        leftDividerLayer.frame = CGRect(x: 0, y: 0, width: 1.2, height: bounds.height - bottomPadding)
    }
    
    
    func updateColors() {
        horizontalLinesLayer.strokeColor = horizontalLineColor.cgColor
        verticalLinesLayer.strokeColor = verticalLineColor.cgColor
        leftDividerLayer.backgroundColor = leftDividerColor.cgColor
    }
    
    private func updatePaths() {
        horizontalLinesLayer.path = createHorizontalLinesPath()
        verticalLinesLayer.path = createVerticalLinesPath()
    }
    
    private func createHorizontalLinesPath() -> CGPath {
        let path = UIBezierPath()
        for hour in 0...24 {
            let yPosition = topPadding + hourHeight * CGFloat(hour)
            path.move(to: CGPoint(x: 0, y: yPosition))
            path.addLine(to: CGPoint(x: bounds.width, y: yPosition))
        }
        return path.cgPath
    }
    
    private func createVerticalLinesPath() -> CGPath {
        let path = UIBezierPath()
        guard columnsCount > 1 else {
            return path.cgPath
        }
        
        let columnWidth = self.bounds.width / CGFloat(columnsCount)
        for i in 0...columnsCount {
            let x = CGFloat(i) * columnWidth
            path.move(to: CGPoint(x: x, y: 0.0))
            let y = topPadding + hourHeight * CGFloat(HOURS_PER_DAY)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path.cgPath
    }
}
