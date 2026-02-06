//
//  CalendarDayTimelineBackLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/6.
//

import Foundation
import UIKit

class CalendarDayTimelineBackLayer: CAShapeLayer {
    
    var hourHeight: CGFloat = 40 {
        didSet {
            if hourHeight != oldValue {
                updatePath()
            }
        }
    }
    
    var topPadding: CGFloat = 20 {
        didSet {
            if topPadding != oldValue {
                updatePath()
            }
        }
    }
    
    var lineColor: UIColor = .separator {
        didSet {
            strokeColor = lineColor.cgColor
        }
    }
    
    var bottomPadding: CGFloat = 40 {
        didSet {
            if bottomPadding != oldValue {
                updatePath()
            }
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

    private func setupLayer() {
        self.lineWidth = 0.6
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updatePath()
        updateColors()
    }
    
    func updateColors() {
        self.strokeColor = lineColor.cgColor
    }
    
    private func updatePath() {
        let path = UIBezierPath()
        
        for hour in 0...24 {
            let yPosition = topPadding + hourHeight * CGFloat(hour)
            path.move(to: CGPoint(x: 0, y: yPosition))
            path.addLine(to: CGPoint(x: bounds.width, y: yPosition))
        }
        
        self.path = path.cgPath
    }
    
}
