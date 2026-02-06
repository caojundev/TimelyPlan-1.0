//
//  TPGridsLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/9.
//

import Foundation
import QuartzCore
import UIKit

struct TPGridsLayoutStyle: Equatable {
    
    /// 内间距
    var padding: UIEdgeInsets = .zero
    
    /// 线条宽度
    var lineWidth: CGFloat = 1.0
    
    /// 线条颜色
    var lineColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.2)

    /// 行数
    var rowsCount: Int = 0
    
    /// 开始绘制行
    var fromRow: Int = 1
    
    /// 结束绘制行
    var toRow: Int = .max
    
    /// 列数
    var columsCount: Int = 0
    
    /// 开始绘制列
    var fromColum: Int = 1
    
    /// 结束绘制行
    var toColum: Int = .max
}

class TPGridsLayer: CAShapeLayer {
    
    /// 布局样式
    var layoutStyle: TPGridsLayoutStyle = TPGridsLayoutStyle() {
        didSet {
            if layoutStyle != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        self.lineWidth = layoutStyle.lineWidth
        updateLayerPath()
        updateColors()
    }
    
    func updateColors() {
        self.strokeColor = layoutStyle.lineColor.cgColor
    }
    
    func updateLayerPath() {
        let frame = bounds.inset(by: layoutStyle.padding)
        let bezierPath = UIBezierPath()
        
        /// 绘制行
        let rowHeight = bounds.height / CGFloat(layoutStyle.rowsCount)
        for row in 0...layoutStyle.rowsCount {
            guard row >= layoutStyle.fromRow, row <= layoutStyle.toRow else {
                continue
            }
            
            var fromPoint = CGPoint(x: frame.minX, y: CGFloat(row) * rowHeight)
            if row == 0 {
                fromPoint.y = fromPoint.y + lineWidth / 2.0
            } else if row == layoutStyle.rowsCount {
                fromPoint.y = fromPoint.y - lineWidth / 2.0
            }
            
            let toPoint = CGPoint(x: frame.maxX, y: fromPoint.y)
            bezierPath.move(to: fromPoint)
            bezierPath.addLine(to: toPoint)
        }
        
        /// 绘制列
        let columnWidth = bounds.width / CGFloat(layoutStyle.columsCount)
        for column in 0...layoutStyle.columsCount {
            guard column >= layoutStyle.fromColum, column <= layoutStyle.toColum else {
                continue
            }
            
            let fromPoint = CGPoint(x: CGFloat(column) * columnWidth, y: frame.minY)
            let toPoint = CGPoint(x: fromPoint.x, y: frame.maxY)
            bezierPath.move(to: fromPoint)
            bezierPath.addLine(to: toPoint)
        }
        
        self.path = bezierPath.cgPath
    }
}
