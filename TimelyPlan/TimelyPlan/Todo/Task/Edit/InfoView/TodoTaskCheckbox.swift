//
//  TodoTaskCheckbox.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/6.
//

import Foundation
import UIKit

struct TodoTaskCheckboxConfig: Equatable {
    
    var size: CGSize
    
    var cornerRadius: CGFloat
    
    var borderWidth: CGFloat
    
    var checkmarkLineWidth: CGFloat
    
    static var normal: TodoTaskCheckboxConfig {
        return TodoTaskCheckboxConfig(size: .size(5),
                                      cornerRadius: 6.0,
                                      borderWidth: 2.0,
                                      checkmarkLineWidth: 3.0)
    }
    
    static var small: TodoTaskCheckboxConfig {
        return TodoTaskCheckboxConfig(size: .size(4),
                               cornerRadius: 4.0,
                               borderWidth: 1.6,
                               checkmarkLineWidth: 1.8)
    }
}

class TodoTaskCheckbox: TPImageButton {
    
    enum Mode: Int {
        case normal /// 正常
        case plus   /// 加
        case minus  /// 减
    }
    
    var mode: Mode = .normal {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 正常颜色
    var normalColor: UIColor = .grayPrimary {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 选中状态颜色
    var checkedColor: UIColor = .primary {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 加减号线条宽度
    var signLineWidth: CGFloat = 2.0 {
        didSet {
            signLayer.signLineWidth = signLineWidth
        }
    }
    
    var config: TodoTaskCheckboxConfig = .normal {
        didSet {
            updateCheckboxConfig()
        }
    }
    
    private lazy var checkmarkLayer: TPCheckmarkLayer = {
        let layer = TPCheckmarkLayer()
        return layer
    }()
    
    /// 加减号图层
    private lazy var signLayer: TodoTaskPlusMinusLayer = {
        let layer = TodoTaskPlusMinusLayer()
        layer.signLineWidth = signLineWidth
        return layer
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.layer.addSublayer(checkmarkLayer)
        contentView.layer.addSublayer(signLayer)
        normalBackgroundColor = .clear
        updateCheckboxConfig()
    }
    
    override func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateScaledLineWidths()
        super.layoutSubviews()
        updateCheckBoxStyle()
        checkmarkLayer.frame = bounds.middleCircleInnerSquareRect
        signLayer.frame = bounds
        signLayer.strokeColor = normalColor.cgColor
        updateSignLayer()
        CATransaction.commit()
    }
    
    override func setChecked(_ isChecked: Bool, animated: Bool = false) {
        super.setChecked(isChecked, animated: animated)
        updateCheckBoxStyle()
        checkmarkLayer.setChecked(isChecked, animated: animated)
        updateSignLayer()
    }
    
    private func updateCheckboxConfig() {
        cornerRadius = config.cornerRadius
        updateScaledLineWidths()
        setNeedsLayout()
    }
    
    /// 按实际尺寸等比缩放配置中的线宽，避免小尺寸时线条过粗
    private func updateScaledLineWidths() {
        let designLength = config.size.shortSideLength
        let length = bounds.size.shortSideLength
        guard designLength > 0.0, length > 0.0 else {
            return
        }
        
        let scale = length / designLength
        let scaledBorderWidth = config.borderWidth * scale
        let scaledCheckmarkLineWidth = config.checkmarkLineWidth * scale
        
        if borderWidth != scaledBorderWidth {
            borderWidth = scaledBorderWidth
        }
        
        if checkmarkLayer.lineWidth != scaledCheckmarkLineWidth {
            checkmarkLayer.lineWidth = scaledCheckmarkLineWidth
        }
    }
    
    private func updateCheckBoxStyle() {
        if self.isChecked {
            normalImageColor = .green
            normalBorderColor = checkedColor
            selectedBorderColor = checkedColor
            normalBackgroundColor = checkedColor
            selectedBackgroundColor = checkedColor
        } else {
            normalImageColor = normalColor
            normalBorderColor = normalColor
            selectedBorderColor = normalColor
            normalBackgroundColor = .clear
            selectedBackgroundColor = .clear
        }
    }
    
    /// 更新加减号图层
    private func updateSignLayer() {
        switch mode {
        case .plus:
            signLayer.mode = .plus
            signLayer.isHidden = isChecked
        case .minus:
            signLayer.mode = .minus
            signLayer.isHidden = isChecked
        case .normal:
            signLayer.isHidden = true
        }
    }
}

/// 加减号图层
private final class TodoTaskPlusMinusLayer: CAShapeLayer {
    
    enum Mode {
        case plus   /// 加号
        case minus  /// 减号
    }
    
    /// 默认线条宽度
    static let kDefaultLineWidth: CGFloat = 2.0
    
    /// 符号长度占图层较短边的比例
    static let kSignLengthRatio: CGFloat = 0.4
    
    /// 符号样式
    var mode: Mode = .plus {
        didSet {
            if mode != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 线条宽度
    var signLineWidth: CGFloat = TodoTaskPlusMinusLayer.kDefaultLineWidth {
        didSet {
            if signLineWidth != oldValue {
                lineWidth = signLineWidth
                setNeedsLayout()
            }
        }
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setupLayer()
    }
    
    override init() {
        super.init()
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayer() {
        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.white.cgColor
        lineCap = .round
        lineJoin = .round
        lineWidth = TodoTaskPlusMinusLayer.kDefaultLineWidth
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updateSignPath()
    }
    
    /// 根据图层尺寸更新符号路径
    private func updateSignPath() {
        let length = bounds.size.shortSideLength
        guard length > 0 else {
            path = nil
            return
        }
        
        let halfLength = length * TodoTaskPlusMinusLayer.kSignLengthRatio / 2.0
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: center.x - halfLength, y: center.y))
        bezierPath.addLine(to: CGPoint(x: center.x + halfLength, y: center.y))
        
        if mode == .plus {
            bezierPath.move(to: CGPoint(x: center.x, y: center.y - halfLength))
            bezierPath.addLine(to: CGPoint(x: center.x, y: center.y + halfLength))
        }
        
        path = bezierPath.cgPath
    }
}
