//
//  CalendarTimelineBackLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/12.
//

import Foundation

class CalendarTimelineBackLayer: CALayer {
    
    // 横线图层
    let horizontalLinesLayer = CAShapeLayer()
    
    // 竖线图层
    var verticalLinesLayer = CAShapeLayer()
    
    // 左侧分割线
    private var leftDividerLayer: CALayer?
    
    var showHorizontalLines: Bool = true {
        didSet {
            updatePaths()
        }
    }
    
    var layout = CalendarAxisLayout() {
        didSet {
            leftDividerBottomMargin = layout.bottomMargin
            updatePaths()
            setNeedsLayout()
        }
    }
    
    // 横线颜色
    var horizontalLineColor: UIColor = CalendarConstant.horizontalSeparatorColor {
        didSet {
            horizontalLinesLayer.strokeColor = horizontalLineColor.cgColor
        }
    }
    
    // 竖线颜色
    var verticalLineColor: UIColor = CalendarConstant.verticalSeparatorColor {
        didSet {
            verticalLinesLayer.strokeColor = verticalLineColor.cgColor
        }
    }
    
    // 左侧分割线颜色
    var leftDividerColor: UIColor = CalendarConstant.dividerColor {
        didSet {
            leftDividerLayer?.backgroundColor = leftDividerColor.cgColor
        }
    }

    lazy var leftDividerBottomMargin: CGFloat = {
        return layout.bottomMargin
    }()

    private var columnsCount: Int

    let mode: CalendarPageMode
    
    init(mode: CalendarPageMode) {
        self.mode = mode
        switch mode {
        case .day:
            self.columnsCount = 1
        case .week:
            self.columnsCount = DAYS_PER_WEEK
        }
        
        super.init()
        self.setupLayers()
    }
    
    override init(layer: Any) {
        self.mode = .day
        self.columnsCount = 1
        super.init(layer: layer)
        self.setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setupLayers() {
        // 配置横线图层
        horizontalLinesLayer.lineWidth = CalendarConstant.separatorLineWidth
        addSublayer(horizontalLinesLayer)
        
        verticalLinesLayer.lineWidth = CalendarConstant.separatorLineWidth
        addSublayer(verticalLinesLayer)
        
        // 配置竖线图层
        if mode == .week {
            let leftDividerLayer = CALayer()
            addSublayer(leftDividerLayer)
            self.leftDividerLayer = leftDividerLayer
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updateColors()
        updatePaths()
        
        // 设置左侧分割线的frame
        
        if let leftDividerLayer = leftDividerLayer {
            let leftDividerFrame = CGRect(x: 0,
                                          y: 0,
                                          width: 1.2,
                                          height: bounds.height - leftDividerBottomMargin)
            executeWithoutAnimation {
                leftDividerLayer.frame = leftDividerFrame
            }
        }
    }
    
    func updateColors() {
        horizontalLinesLayer.strokeColor = horizontalLineColor.cgColor
        verticalLinesLayer.strokeColor = verticalLineColor.cgColor
        leftDividerLayer?.backgroundColor = leftDividerColor.cgColor
    }
    
    private func updatePaths() {
        horizontalLinesLayer.path = createHorizontalLinesPath()
        verticalLinesLayer.path = createVerticalLinesPath()
    }
    
    func createHorizontalLinesPath() -> CGPath? {
        guard showHorizontalLines else {
            return nil
        }
        
        let path = UIBezierPath()
        for hour in 0...24 {
            let yPosition = layout.topMargin + layout.hourHeight * CGFloat(hour)
            path.move(to: CGPoint(x: 0.0, y: yPosition))
            path.addLine(to: CGPoint(x: bounds.width, y: yPosition))
        }
        
        return path.cgPath
    }
    
    func createVerticalLinesPath() -> CGPath? {
        guard self.mode == .week else {
            return nil
        }
        
        let path = UIBezierPath()
        guard columnsCount > 1 else {
            return path.cgPath
        }
        
        let columnWidth = self.bounds.width / CGFloat(columnsCount)
        for i in 0...columnsCount {
            let x = CGFloat(i) * columnWidth
            path.move(to: CGPoint(x: x, y: 0.0))
            let y = bounds.height
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path.cgPath
    }
}
