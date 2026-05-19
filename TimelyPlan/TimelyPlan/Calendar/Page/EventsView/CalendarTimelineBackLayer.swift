//
//  CalendarTimelineBackLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/12.
//

import Foundation

class CalendarTimelineBackLayer: CALayer {
    
    // 横线图层
    private let horizontalLinesLayer = CAShapeLayer()
    
    // 竖线图层
    private var verticalLinesLayer: CAShapeLayer?
    
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
    var horizontalLineColor: UIColor = CalendarConstant.separatorColor {
        didSet {
            horizontalLinesLayer.strokeColor = horizontalLineColor.cgColor
        }
    }
    
    // 竖线颜色
    var verticalLineColor: UIColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.1) {
        didSet {
            verticalLinesLayer?.strokeColor = verticalLineColor.cgColor
        }
    }
    
    // 左侧分割线颜色
    var leftDividerColor: UIColor = .lightGray {
        didSet {
            leftDividerLayer?.backgroundColor = leftDividerColor.cgColor
        }
    }

    lazy var leftDividerBottomMargin: CGFloat = {
        return layout.bottomMargin
    }()

    private var columnsCount: Int
    
    private let horizontalEdgeMargin: CGFloat

    let mode: CalendarPageMode
    
    init(mode: CalendarPageMode) {
        self.mode = mode
        switch mode {
        case .day:
            self.columnsCount = 1
            self.horizontalEdgeMargin = 5.0
        case .week:
            self.columnsCount = DAYS_PER_WEEK
            self.horizontalEdgeMargin = 0.0
        }
        
        super.init()
        self.setupLayers()
    }
    
    override init(layer: Any) {
        self.mode = .day
        self.columnsCount = 1
        self.horizontalEdgeMargin = 5.0
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
        if mode == .week {
            let verticalLinesLayer = CAShapeLayer()
            verticalLinesLayer.lineWidth = 0.6
            addSublayer(verticalLinesLayer)
            self.verticalLinesLayer = verticalLinesLayer
            
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
        verticalLinesLayer?.strokeColor = verticalLineColor.cgColor
        leftDividerLayer?.backgroundColor = leftDividerColor.cgColor
    }
    
    private func updatePaths() {
        if showHorizontalLines {
            horizontalLinesLayer.path = createHorizontalLinesPath()
        } else {
            horizontalLinesLayer.path = nil
        }
        
        if let verticalLinesLayer = verticalLinesLayer {
            verticalLinesLayer.path = createVerticalLinesPath()
        }
    }
    
    private func createHorizontalLinesPath() -> CGPath {
        let path = UIBezierPath()
        for hour in 0...24 {
            let yPosition = layout.topMargin + layout.hourHeight * CGFloat(hour)
            path.move(to: CGPoint(x: horizontalEdgeMargin, y: yPosition))
            path.addLine(to: CGPoint(x: bounds.width - 2 * horizontalEdgeMargin, y: yPosition))
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
            let y = layout.topMargin + layout.hourHeight * CGFloat(HOURS_PER_DAY)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path.cgPath
    }
}
