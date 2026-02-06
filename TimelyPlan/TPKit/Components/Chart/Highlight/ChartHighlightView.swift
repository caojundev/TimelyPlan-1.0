//
//  ChartHighlightView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/2.
//

import Foundation
import UIKit

class ChartHighlightView: UIView {
    
    var margin: CGFloat = 10.0
    
    /// 线条是否从元素视图中心点开始，否则从最底部开始
    var startFromElement: Bool = false
    
    /// 线条结束于顶部，否则结束于元素上方
    var endOnTop: Bool = true
    
    /// 图标元素视图
    private(set) var element: ChartHighlightEelement?
    
    private lazy var infoLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 10.0, vertical: 8.0)
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        label.textColor = Color(0xFFFFFF, 0.6)
        return label
    }()
    
    private lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 2.0
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.clipsToBounds = false
        self.layer.addSublayer(self.lineLayer)
        self.addSubview(self.infoLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var lineStartPoint: CGPoint? {
        guard let element = element as? UIView else {
            return nil
        }

        let frame = element.frame
        if startFromElement {
            return CGPoint(x: frame.midX, y: frame.midY)
        }
        
        return CGPoint(x: frame.midX, y: bounds.height)
    }
    
    private var lineEndPoint: CGPoint? {
        guard let element = element as? UIView else {
            return nil
        }

        let frame = element.frame
        if endOnTop {
            return CGPoint(x: frame.midX, y: -margin)
        }
        
        return CGPoint(x: frame.midX, y: frame.minY - margin)
    }
    
    // MARK: - 显示
    func show(element: ChartHighlightEelement) {
        self.element = element
        self.infoLabel.text = element.highlightText
        setNeedsLayout()
    }
    
    func hide() {
        self.element = nil
        setNeedsLayout()
    }
    
    var isInfoHidden: Bool = true {
        didSet {
            infoLabel.isHidden = isInfoHidden
            lineLayer.isHidden = isInfoHidden
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = bounds
        lineLayer.strokeColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha:0.2).cgColor
        
        guard let startPoint = lineStartPoint, let endPoint = lineEndPoint else {
            isInfoHidden = true
            lineLayer.path = nil
            return
        }

        isInfoHidden = false
        
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        lineLayer.path = linePath.cgPath
        
        /// 标签布局
        infoLabel.sizeToFit()
        if infoLabel.width > bounds.width {
            infoLabel.width = bounds.width
        }
        
        infoLabel.bottom = endPoint.y
        infoLabel.centerX = endPoint.x
        if infoLabel.left < -20.0 {
            infoLabel.left = -20.0
        } else if infoLabel.right > bounds.width {
            infoLabel.right = bounds.width
        }
        
        infoLabel.layer.backgroundColor = Color(0x232323).cgColor
        infoLabel.layer.cornerRadius = 4.0
        infoLabel.layer.setBorderShadow(color: .shadow, offset: .zero, radius: 4.0)
    }
}
