//
//  TPStrikethroughLabel.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/16.
//

import Foundation
import UIKit

class TPStrikethroughLabel: UILabel {
    
    override var text: String? {
        didSet {
            if text != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var normalTextColor: UIColor = Color(light: 0x232323,
                                         dark: 0xFEFEFF,
                                         alpha: 1.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var strikethroughColor: UIColor = Color(light: 0x121212,
                                            dark: 0xFEFEFE,
                                            alpha: 0.8) {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    private var duration: TimeInterval {
        let count = self.text?.count ?? 0
        let duration = TimeInterval(count) / 100.0
        return min(max(0.4, duration), 0.6)
    }
    
    // 删除线图层
    private lazy var strikethroughLayer: CAShapeLayer = {
        let strikethroughLayer = CAShapeLayer()
        strikethroughLayer.fillColor = UIColor.clear.cgColor
        strikethroughLayer.lineWidth = 1.2
        strikethroughLayer.strokeEnd = 0.0
        return strikethroughLayer
    }()

    private var _isStrikethrough: Bool = false
    var isStrikethrough: Bool {
        get {
            return _isStrikethrough
        }
        
        set {
            setStrikethrough(newValue, animated: false)
        }
    }
    
    func setStrikethrough(_ isStrikethrough: Bool, animated: Bool) {
        _isStrikethrough = isStrikethrough
        
        /// 更新文本颜色
        self.updateTextColor()
        
        if _isStrikethrough {
            updateStrikethroughLayerPath()
        }
        
        let strokeEnd = _isStrikethrough ? 1.0 : 0.0
        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            strikethroughLayer.strokeEnd = strokeEnd
            CATransaction.commit()
        } else {
            strikethroughLayer.removeAllAnimations()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            strikethroughLayer.strokeEnd = strokeEnd
            CATransaction.commit()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        strikethroughLayer.strokeEnd = 0.0
        layer.addSublayer(strikethroughLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        strikethroughLayer.strokeColor = strikethroughColor.cgColor
        strikethroughLayer.frame = bounds
        updateStrikethroughLayerPath()
        updateTextColor()
    }

    private func updateTextColor() {
        self.textColor = isStrikethrough ? strikethroughColor : normalTextColor
    }
     
    private func updateStrikethroughLayerPath() {
        guard isStrikethrough else {
            strikethroughLayer.path = nil
            return
        }
        
        let path = UIBezierPath()
        let lineFrames = lineFrames()
        for lineFrame in lineFrames {
            path.move(to: CGPoint(x: lineFrame.minX, y: lineFrame.midY))
            path.addLine(to: CGPoint(x: lineFrame.maxX, y: lineFrame.midY))
        }
        
        strikethroughLayer.path = path.cgPath
    }

}

