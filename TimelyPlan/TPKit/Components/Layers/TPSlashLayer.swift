//
//  TPSlashLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/22.
//

import Foundation

class TPSlashLayer: CAShapeLayer {
    
    var margin: CGFloat = 5.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init() {
        super.init()
        setup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }
    
    func setup() {
        self.masksToBounds = true
        self.lineWidth = 2.0
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updateLayerPath()
    }
    
    private func updateLayerPath() {
        let path = UIBezierPath()
        let contentWidth = bounds.width + bounds.height
        var x = 0.0
        while x < contentWidth {
            let startPoint = CGPoint(x: x, y: 0.0)
            let endPoint = CGPoint(x: x - bounds.height, y: bounds.height)
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            x += margin
        }
        
        self.path = path.cgPath
    }
    
}
