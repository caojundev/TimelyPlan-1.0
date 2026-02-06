//
//  TPBaseButton.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/28.
//

import Foundation
import UIKit

class TPBaseButton: UIButton, Checkable {
    
    /// 点击回调
    var didClickHandler: (() -> Void)?
    
    /// 圆角半径
    var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 正常背景颜色
    var normalBackgroundColor: UIColor? {
        didSet {
            if normalBackgroundColor != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 选中背景颜色
    var selectedBackgroundColor: UIColor?  {
        didSet {
            if selectedBackgroundColor != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 边框宽度
    var borderWidth: CGFloat = 0.0 {
        didSet {
            if borderWidth != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 正常边框颜色
    var normalBorderColor: UIColor? {
        didSet {
            if normalBorderColor != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 选中边框颜色
    var selectedBorderColor: UIColor? {
        didSet {
            if selectedBorderColor != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 首选缩放系数
    var preferredTappedScale: CGFloat = 0.9
    
    /// 缩放允许最大长度
    var scaleMaxLength: CGFloat?

    /// 触感反馈方式，为 nil 时无反馈
    var impactFeedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle? = .soft
    
    /// 禁用状态下透明度
    var disabledAlpha: CGFloat = 0.4 {
        didSet {
            updateEnabledStyle()
        }
    }

    /// 按钮是否可用
    override var isEnabled: Bool {
        didSet {
            updateEnabledStyle()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateStatus(animated: true)
        }
    }
    
    /// 内容视图
    let contentView = TPButtonContentView()
    
    /// 是否按下
    private(set) var isTapped: Bool = false
    
    /// 最外层容器视图
    private var containerView = UIView()

    /// 当前缩放系数
    private var tappedScale: CGFloat {
        guard let scaleMaxLength = scaleMaxLength else {
            return preferredTappedScale
        }

        let longSideLength = bounds.size.longSideLength
        let scaleLength = longSideLength * (1.0 - preferredTappedScale)
        guard scaleLength > scaleMaxLength else {
            return preferredTappedScale
        }

        var scale = 1.0 - scaleMaxLength / longSideLength
        clampValue(&scale, 0.0, 1.0)
        return scale
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.padding = .zero
        isUserInteractionEnabled = true
        addTarget(self, action: #selector(didTouchDownInside), for: [.touchDown, .touchDownRepeat])
        addTarget(self, action: #selector(didTouchUpInside), for: [.touchUpInside])
        addTarget(self, action: #selector(didDragOutside), for: [.touchDragExit, .touchCancel])
        addTarget(self, action: #selector(didDragInside), for: [.touchDragEnter])
        
        addSubview(containerView)
        containerView.isUserInteractionEnabled = false
        containerView.addSubview(contentView)
        setupContentSubviews()
    }
    
    func setupContentSubviews() {
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let constraintSize = CGSize(width: size.width - padding.horizontalLength,
                                    height: size.height - padding.verticalLength)
        let fitSize = contentSizeThatFits(constraintSize)
        return CGSize(width: fitSize.width + padding.horizontalLength,
                      height: fitSize.height + padding.verticalLength)
    }
    
    /// 内容尺寸
    func contentSizeThatFits(_ size: CGSize) -> CGSize {
        return .large
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
        contentView.transform = .identity
        contentView.frame = bounds
        updateStatus(animated: false)
        updateBackgroundStyle()
        updateBackgroundAlpha()
    }
        
    // MARK: - 更新样式
    private func updateBackgroundStyle() {
        let backgroundView = contentView.backgroundView
        backgroundView.cornerRadius = cornerRadius
        backgroundView.borderWidth = borderWidth
        backgroundView.borderColor = normalBorderColor
        backgroundView.backColor = normalBackgroundColor
        
        let selectedBackgroundView = contentView.selectedBackgroundView
        selectedBackgroundView.cornerRadius = cornerRadius
        selectedBackgroundView.borderWidth = borderWidth
        
        var selectedBorderColor = selectedBorderColor
        if selectedBorderColor == nil {
            selectedBorderColor = normalBorderColor?.darkerColor
        }
        
        selectedBackgroundView.borderColor = selectedBorderColor
        var selectedBackgroundColor = selectedBackgroundColor
        if selectedBackgroundColor == nil {
            selectedBackgroundColor = normalBackgroundColor?.darkerColor
        }
        
        selectedBackgroundView.backColor = selectedBackgroundColor
    }
    
    private func updateBackgroundAlpha() {
        contentView.isHighlighted = isTapped || isSelected
    }
    
    /// 更新按钮可用状态样式
    private func updateEnabledStyle() {
        let alpha = isEnabled ? 1.0 : disabledAlpha
        containerView.alpha = alpha
    }
    
    private func updateStatus(animated: Bool) {
        let scale = isTapped ? tappedScale : 1.0
        let contentAlpha = isTapped ? 0.8 : 1.0
        let animationBlock = {
            self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.contentView.alpha = contentAlpha
        }
         
        guard animated else {
            animationBlock()
            return
        }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: .beginFromCurrentState,
                       animations: animationBlock,
                       completion: nil)
    }
    
    
    // MARK: - Event Response
    @objc func didTouchDownInside() {
        isTapped = true
        updateStatus(animated: true)
    }
    
    @objc func didTouchUpInside() {
        if let impactFeedbackStyle = impactFeedbackStyle {
            TPImpactFeedback.impactWithStyle(impactFeedbackStyle)
        }
        
        isTapped = false
        updateStatus(animated: true)
        sendActions(for: .primaryActionTriggered)
        didClickHandler?()
    }

    @objc func didDragOutside() {
        isTapped = false
        updateStatus(animated: true)
    }

    @objc func didDragInside() {
        isTapped = true
        updateStatus(animated: true)
    }
    
    // MARK: - Checkable
    private var _isChecked: Bool = false
    var isChecked: Bool {
        get {
            return _isChecked
        }
        
        set {
            setChecked(newValue, animated: false)
        }
    }

    func setChecked(_ isChecked: Bool, animated: Bool = false) {
        _isChecked = isChecked
    }
    
    // MARK: - Shadow
    func setBorderShadow(color: UIColor, offset: CGSize, radius: CGFloat, roundCorners: UIRectCorner, cornerRadius: CGFloat) {
        layoutIfNeeded() /// 在设置阴影前布局
        contentView.layer.setBorderShadow(color: color,
                                          offset: offset,
                                          radius: radius,
                                          roundCorners: roundCorners,
                                          cornerRadius: cornerRadius)
    }
}

class TPButtonContentView: UIView {
    
    var isHighlighted: Bool = false {
        didSet {
            if isHighlighted != oldValue {
                updateBackgroundAlpha()
            }
        }
    }
    
    /// 正常状态背景视图
    private(set) var backgroundView = TPButtonBackgroundView()
    
    /// 选中背景视图
    private(set) var selectedBackgroundView = TPButtonBackgroundView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        isUserInteractionEnabled = false
        addSubview(backgroundView)
        addSubview(selectedBackgroundView)
        updateBackgroundAlpha()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        selectedBackgroundView.frame = bounds
    }
    
    private func updateBackgroundAlpha() {
        var backgroundAlpha = 1.0
        var selectedBackgroundAlpha = 0.0
        if isHighlighted {
            backgroundAlpha = 0.0
            selectedBackgroundAlpha = 1.0
        }
        
        backgroundView.alpha = backgroundAlpha
        selectedBackgroundView.alpha = selectedBackgroundAlpha
    }
}

class TPButtonBackgroundView: UIView {
    
    var borderWidth: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var borderColor: UIColor? {
        didSet {
            let borderColor = borderColor ?? .clear
            backLayer.strokeColor = borderColor.cgColor
        }
    }
    
    var backColor: UIColor? {
        didSet {
            let backColor = backColor ?? .clear
            backLayer.fillColor = backColor.cgColor
        }
    }
    
    var cornerRadius: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 背景图层
    private var backLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(backLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backLayer.frame = bounds
        CATransaction.commit()
        
        updateLayerPath()
    }
    
    private func updateLayerPath() {
        backLayer.lineWidth = borderWidth
        
        let borderColor = borderColor ?? .clear
        backLayer.strokeColor = borderColor.cgColor
        
        let backColor = backColor ?? .clear
        backLayer.fillColor = backColor.cgColor
      
        let dx = borderWidth / 2.0
        let roundedRect = bounds.insetBy(dx: dx, dy: dx)
        let cornerRadius = min(cornerRadius, roundedRect.boundingCornerRadius)
        let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        self.backLayer.path = path.cgPath
    }
}
