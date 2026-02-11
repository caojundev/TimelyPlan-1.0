//
//  PieLabelsView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/10.
//

import Foundation
import UIKit

class PieLabelsView: UIView {
    
    var radius: CGFloat = 160.0 {
        didSet {
            drawer.radius = radius
            setNeedsLayout()
        }
    }
    
    var margin: CGFloat = 5.0 {
        didSet {
            drawer.margin = margin
            setNeedsLayout()
        }
    }
    
    var visual: PieVisual? {
        didSet {
            setupLabelViews()
            setNeedsLayout()
        }
    }
    
    private let drawer = PieLineDrawer()
    
    private var labelViews: [PieLabelView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutLabelViews()
    }
    
    private func setupLabelViews() {
        self.removeViews(labelViews)
        guard let visual = visual else {
            return
        }
        
        var labelViews = [PieLabelView]()
        let angles = visual.drawAngles()
        for angle in angles {
            let labelView = PieLabelView(angle: angle)
            labelViews.append(labelView)
            addSubview(labelView)
        }
        
        self.labelViews = labelViews
    }
    
    private func layoutLabelViews() {
        for labelView in labelViews {
            let curve = drawer.lineQuadCurve(rect: bounds, angle: labelView.angle)
            labelView.sizeToFit()
            if curve.end.x > curve.start.x {
                /// 右侧
                labelView.titleConfig.textAlignment = .left
                labelView.left = curve.end.x
                if labelView.right > bounds.width {
                    labelView.width = bounds.width - labelView.left
                }
            } else {
                /// 左侧
                labelView.titleConfig.textAlignment = .right
                labelView.right = curve.end.x
                if labelView.left < 0.0 {
                    labelView.width = labelView.right
                    labelView.left = 0.0
                }
            }
            
            labelView.centerY = curve.end.y
            labelView.setNeedsLayout()
        }
    }
}

class PieLabelView: TPInfoView {
    
    let angle: PieSliceAngle
    
    init(frame: CGRect = .zero, angle: PieSliceAngle) {
        self.angle = angle
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 4.0)
        self.subtitleTopMargin = 0.0
        self.titleConfig.font = UIFont.boldSystemFont(ofSize: 12.0)
        self.titleConfig.lineBreakMode = .byTruncatingMiddle
        self.titleConfig.textColor = .label
        self.titleConfig.alpha = 0.8
        self.subtitleConfig.adjustsFontSizeToFitWidth = true
        self.subtitleConfig.minimumScaleFactor = 0.6
        self.subtitleConfig.font = UIFont.systemFont(ofSize: 10.0)
        self.subtitleConfig.lineBreakMode = .byTruncatingMiddle
        self.subtitleConfig.textColor = .secondaryLabel
        self.title = angle.slice.title
        self.subtitle = angle.slice.detail
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
