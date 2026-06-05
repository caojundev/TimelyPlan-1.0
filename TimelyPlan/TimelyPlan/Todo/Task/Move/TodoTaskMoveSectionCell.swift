//
//  TodoTaskMoveSectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/5.
//

import Foundation
import UIKit

class TodoTaskMoveSectionCell: TPImageInfoTableCell {
    
    var section: TodoSection? {
        didSet {
            self.title = section?.name ?? resGetString("Untitled Section")
            let listDepth = section?.list?.depth ?? 0
            self.depth = listDepth + 1
            self.depthLineLayer.indentationLevel = self.depth
        }
    }
    
    /// 深度绘制层级
    var depthLineLevels: [Int]? {
        get {
            return depthLineLayer.depthLineLevels
        }
        
        set {
            depthLineLayer.depthLineLevels = newValue
        }
    }
    
    /// 缩进分割线图层
    private(set) lazy var depthLineLayer: TodoSectionBranchLayer = {
        let layer = TodoSectionBranchLayer()
        layer.indentationWidth = depthWidth
        layer.lineWidth = 2.0
        layer.strokeColor = UIColor.lightGray.cgColor
        return layer
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        layer.addSublayer(depthLineLayer)
        self.imageConfig.shouldRenderImageWithColor = true
        self.imageConfig.color = resGetColor(.title)
        self.imageContent = .init(imageName: "todo_section_24")
        self.imageConfig.margins = UIEdgeInsets(left: 16.0, right: 4.0)
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        depthLineLayer.frame = CGRect(x: 0.0, y: 0.0, width: contentView.left, height: bounds.height)
        depthLineLayer.indentationWidth = depthWidth
        CATransaction.commit()
    }
    
}

class TodoSectionBranchLayer: CAShapeLayer {
    
    /// 绘制层级
    var depthLineLevels: [Int]?  {
        didSet {
            setNeedsLayout()
        }
    }
    
    var indentationLevel: Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 深度辅助线x偏移距离
    var dx: CGFloat = 0.0 {
        didSet {
            if dx != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 缩进宽度
    var indentationWidth: CGFloat = 25.0 {
        didSet {
            if indentationWidth != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var depthWidth = 16.0
    
    /// 分割线开始层级
    private let fromLevel: Int = 1

    override func layoutSublayers() {
        super.layoutSublayers()
        self.fillColor = UIColor.clear.cgColor
        updateLayerPath()
    }

    private func updateLayerPath() {
        let toLevel = indentationLevel
        guard fromLevel <= toLevel else {
            self.path = nil
            return
        }
  
        let bezierPath = UIBezierPath()
        for i in fromLevel...toLevel {
            if containsLevel(i) {
                let fromPoint = CGPoint(x: lineOffsetX(at: i), y: 0.0)
                bezierPath.move(to: fromPoint)
                let toPoint = CGPoint(x: fromPoint.x, y: bounds.height)
                bezierPath.addLine(to: toPoint)
            }
        }
        
        self.path = bezierPath.cgPath
    }
    
    private func lineOffsetX(at index: Int) -> CGFloat {
        return CGFloat(index) * indentationWidth + dx
    }
    
    private func containsLevel(_ level: Int) -> Bool {
//        if level == indentationLevel {
//            return true
//        }
//        
        return depthLineLevels?.contains(level) ?? false
    }
    

}
