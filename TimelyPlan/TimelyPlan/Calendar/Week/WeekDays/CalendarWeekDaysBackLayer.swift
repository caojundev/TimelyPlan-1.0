//
//  CalendarWeekDaysBackLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/12.
//

import Foundation

class CalendarWeekDaysBackLayer: TPGridsLayer {
    
    // 左侧分割线
    private let leftDividerLayer = CALayer()
    
    // 左侧分割线颜色
    var leftDividerColor: UIColor = .lightGray {
        didSet {
            leftDividerLayer.backgroundColor = leftDividerColor.cgColor
        }
    }
    
    // 左侧分割线宽度
    var leftDividerWidth: CGFloat = 1.2 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init() {
        super.init()
        self.setupLayer()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayer() {
        var style = TPGridsLayoutStyle()
        style.columsCount = DAYS_PER_WEEK
        style.fromColum = 0
        style.toColum = DAYS_PER_WEEK
        style.rowsCount = 1
        style.fromRow = 1
        style.toRow = 1
        style.lineWidth = 0.4
        style.lineColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.2)
        self.layoutStyle = style
        
        // 配置左侧分割线
        leftDividerLayer.backgroundColor = leftDividerColor.cgColor
        addSublayer(leftDividerLayer)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        executeWithoutAnimation {
            leftDividerLayer.frame = CGRect(x: 0, y: 0, width: leftDividerWidth, height: bounds.height)
        }
    }
    
    override func updateColors() {
        super.updateColors()
        leftDividerLayer.backgroundColor = leftDividerColor.cgColor
    }
}

