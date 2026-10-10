//
//  IAPContinueView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit

class IAPContinueView: UIView {
    
    struct Config {
        static let padding = UIEdgeInsets(top: 0.0,
                                          left: 20.0,
                                          bottom: 8.0,
                                          right: 20.0)
        static let transitionHeight = 20.0
        static let noteLabelTopMargin = 4.0
        static let noteLabelHeight = 40.0
        static let buttonHeight = 50.0
        static let buttonTopMargin = 8.0
        static let noteLabelMaxLines = 2
    }
    
    // MARK: - 回调
    
    /// 继续按钮点击回调
    var onContinueTapped: (() -> Void)?
    
    // MARK: - 属性定义
    
    /// 背景颜色（可自定义）
    var backgroundColorValue: UIColor = .systemBackground {
        didSet {
            updateGradientColors()
        }
    }
    
    /// 过渡高度（默认 20pt）
    var transitionHeight: CGFloat = Config.transitionHeight {
        didSet {
            updateGradientColors()
            setNeedsLayout()
        }
    }
    
    /// 提示标签
    let noteLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.numberOfLines = Config.noteLabelMaxLines
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    /// 继续按钮
    private let continueButton: IAPContinueButton = {
        return IAPContinueButton()
    }()
    
    /// 过渡渐变层
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - 设置视图
    
    private func setupView() {
        backgroundColor = .clear
        
        // 添加渐变层
        layer.addSublayer(gradientLayer)
        
        // 添加子视图
        addSubview(noteLabel)
        addSubview(continueButton)
        
        // 点击回调
        continueButton.didClickHandler = { [weak self] in
            self?.onContinueTapped?()
        }
        
        // 初始布局
        updateGradientColors()
        updateGradientFrame()
    }
    
    // MARK: - 更新渐变颜色和位置
    
    private func updateGradientColors() {
        // 计算过渡位置（transitionHeight 占视图总高度的比例）
        let transitionLocation = calculateTransitionLocation()
        
        gradientLayer.colors = [
            backgroundColorValue.withAlphaComponent(0).cgColor,  // 顶部透明
            backgroundColorValue.cgColor,                        // 过渡结束位置的不透明色
            backgroundColorValue.cgColor                         // 底部不透明色
        ]
        
        gradientLayer.locations = [
            0.0,                    // 顶部开始
            transitionLocation,     // 过渡结束位置
            1.0                     // 底部结束
        ]
    }
    
    // MARK: - 计算过渡位置
    
    private func calculateTransitionLocation() -> NSNumber {
        guard bounds.height > 0 else { return 0 }
        
        let location = min(transitionHeight / bounds.height, 1.0)
        return NSNumber(value: Float(location))
    }
    
    // MARK: - 更新渐变框架
    
    private func updateGradientFrame() {
        // gradientLayer 覆盖整个视图
        gradientLayer.frame = bounds
    }
    
    // MARK: - 计算布局
    
    private func contentLayoutFrame() -> CGRect {
        var padding = Config.padding
        padding.bottom = max(padding.bottom, layoutMargins.bottom)
        
        return CGRect(
            x: padding.left,
            y: padding.top,
            width: bounds.width - padding.left - padding.right,
            height: bounds.height - padding.top - padding.bottom
        )
    }
    
    // MARK: - sizeThatFits
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var padding = Config.padding
        padding.bottom = max(padding.bottom, layoutMargins.bottom)
        
        let totalHeight = transitionHeight +
                         Config.noteLabelTopMargin +
                         Config.noteLabelHeight +
                         Config.buttonTopMargin +
                         Config.buttonHeight +
                         padding.bottom
        
        return CGSize(width: size.width, height: totalHeight)
    }
    
    // MARK: - 布局子视图
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentLayoutFrame()
        
        // 更新渐变层框架
        updateGradientFrame()
        
        // 更新渐变颜色位置（因为视图高度可能改变）
        updateGradientColors()
        
        // noteLabel 布局 - 距离顶部为过渡高度（高度固定，continueButton 位置不随行数变化）
        noteLabel.frame = CGRect(
            x: layoutFrame.minX,
            y: transitionHeight + Config.noteLabelTopMargin,
            width: layoutFrame.width,
            height: Config.noteLabelHeight
        )
        
        // continueButton 布局
        continueButton.frame = CGRect(
            x: layoutFrame.minX,
            y: noteLabel.bottom + Config.buttonTopMargin,
            width: layoutFrame.width,
            height: Config.buttonHeight
        )
    }
    
    // MARK: - 公共方法
    
    /// 设置提示文本
    func setNoteText(_ text: String) {
        noteLabel.text = text
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    /// 设置 noteLabel 最大行数
    func setNoteLabelMaxLines(_ lines: Int) {
        noteLabel.numberOfLines = lines
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    /// 设置继续按钮标题
    func setTitle(_ title: String?) {
        continueButton.title = title
        continueButton.setNeedsLayout()
    }
    
    /// 设置继续按钮可用状态
    func setEnabled(_ enabled: Bool) {
        continueButton.isEnabled = enabled
    }
    
    /// 设置继续按钮加载态（加载中隐藏骨架与标题，居中显示三点指示器，并且不可点击）
    func setLoading(_ loading: Bool) {
        continueButton.isLoading = loading
    }
    
    // MARK: - intrinsicContentSize
    
    override var intrinsicContentSize: CGSize {
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        return sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    }
}


private final class IAPContinueButton: TPDefaultButton {
    
    private let skeleton = TPSkeletonView(frame: .zero)
    /// 加载态指示器（三点依次闪烁）
    private let dotIndicator = TPDotLoadingIndicatorView()
    
    /// 是否处于加载态：隐藏骨架与标题，居中显示圆点指示器，并且不可点击
    var isLoading: Bool = false {
        didSet {
            guard isLoading != oldValue else { return }
            updateLoadingState()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        skeleton.clipsToBounds = true
        contentView.addSubview(skeleton)
        
        dotIndicator.isHidden = true
        contentView.addSubview(dotIndicator)
        
        self.preferredTappedScale = 0.9
        self.scaleMaxLength = 8.0
        self.title = resGetString("Continue")
        self.titleConfig.textColor = .white
        self.titleConfig.font = .systemFont(ofSize: 17, weight: .semibold)
        self.cornerRadius = .greatestFiniteMagnitude
        self.normalBackgroundColor = IAPColor.primary
    }
    
    private func updateLoadingState() {
        imageTitleView.isHidden = isLoading
        skeleton.isHidden = isLoading
        // 加载中禁止点击（用 isUserInteractionEnabled 而非 isEnabled，避免整体变透明）
        isUserInteractionEnabled = !isLoading
        
        if isLoading {
            dotIndicator.startAnimating()
        } else {
            dotIndicator.stopAnimating()
        }
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        skeleton.frame = contentView.bounds
        skeleton.layer.cornerRadius = contentView.halfHeight
        
        // 圆点指示器居中
        let dotSize = dotIndicator.intrinsicContentSize
        dotIndicator.frame = CGRect(x: (contentView.bounds.width - dotSize.width) / 2,
                                    y: (contentView.bounds.height - dotSize.height) / 2,
                                    width: dotSize.width,
                                    height: dotSize.height)
    }
    
}

