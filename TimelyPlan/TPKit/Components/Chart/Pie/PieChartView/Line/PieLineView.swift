//
//  PieLineView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/10.
//

import Foundation
import UIKit

class PieLineView: UIView {
    
    var radius: CGFloat = 160.0 {
        didSet {
            drawer.radius = radius
            setNeedsDisplay()
        }
    }
    
    var margin: CGFloat = 5.0 {
        didSet {
            drawer.margin = margin
            setNeedsDisplay()
        }
    }
    
    var visual: PieVisual? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let drawer = PieLineDrawer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let visual = visual, let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let angles = visual.drawAngles()
        for angle in angles {
            let color = visual.color(of: angle.index)
            let curve = drawer.lineQuadCurve(rect: bounds, angle: angle)
            context.move(to: curve.start)
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(1.5)
            context.addQuadCurve(to: curve.end, control: curve.control)
            context.strokePath()
        }
    }
}

