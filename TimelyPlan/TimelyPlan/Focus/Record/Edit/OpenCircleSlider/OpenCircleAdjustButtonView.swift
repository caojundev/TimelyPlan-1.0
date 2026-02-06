//
//  OpenCircleAdjustView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/28.
//

import Foundation
import UIKit

class OpenCircleAdjustButtonView: UIView {
        
    var positiveHandler: (() -> Void)?
    
    var negativeHandler: (() -> Void)?
    
    private let backLayer = CAShapeLayer()

    private(set) lazy var negativeButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.image = resGetImage("NegativeCircleFill")
        button.imageConfig.size = .default
        button.imageConfig.color = .label
        return button
    }()
    
    private(set) lazy var positiveButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.image = resGetImage("PositiveCircleFill")
        button.imageConfig.size = .default
        button.imageConfig.color = .label
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(backLayer)
        backLayer.lineWidth = 1.0
        backLayer.lineDashPattern = [4, 4]
    
        negativeButton.addTarget(self,
                                action: #selector(clickNegative(_:)),
                                for: .touchUpInside)
        positiveButton.addTarget(self,
                                action: #selector(clickPositive(_:)),
                                for: .touchUpInside)
        addSubview(negativeButton)
        addSubview(positiveButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backLayer.strokeColor = UIColor(white: 0.5, alpha: 0.2).cgColor
        let path = UIBezierPath()
        path.move(to: CGPoint(x: halfWidth, y: 15.0))
        path.addLine(to: CGPoint(x: halfWidth, y: height - 15.0))
        backLayer.path = path.cgPath
    
        negativeButton.sizeToFit()
        negativeButton.centerX = halfWidth / 2.0
        negativeButton.alignVerticalCenter()
        
        positiveButton.sizeToFit()
        positiveButton.centerX = halfWidth * 1.5
        positiveButton.alignVerticalCenter()
    }
    
    
    @objc func clickPositive(_ button: UIButton) {
        positiveHandler?()
    }
    
    @objc func clickNegative(_ button: UIButton) {
        negativeHandler?()
    }
}
