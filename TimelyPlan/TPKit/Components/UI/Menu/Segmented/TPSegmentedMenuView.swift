//
//  TPSegmentedMenuView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation
import UIKit

class TPSegmentedMenuView: UIView, TPPageMenuRepresentable {
    
    var preferredTappedScale = 0.85

    var inactiveBttonAlpha = 0.4
    
    var cornerRadius: CGFloat = .greatestFiniteMagnitude {
        didSet {
            setNeedsLayout()
        }
    }
    
    var margin: CGFloat = 10.0
    var buttonEdgeInsets: UIEdgeInsets = UIEdgeInsets(horizontal: 10.0)
    var maxButtonWidth: CGFloat = .greatestFiniteMagnitude
    var minButtonWidth: CGFloat = 0.0
    var buttonHeight: CGFloat = 50.0
    
    var titleConfig: TPLabelConfig = .titleConfig {
        didSet {
            setNeedsLayout()
        }
    }
    
    var imagePosition: TPAccessoryPosition = .left {
        didSet {
            setNeedsLayout()
        }
    }
    
    var imageConfig = TPImageAccessoryConfig() {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 菜单背景色
    var normalBackgroundColor: UIColor? = Color(0x476AFF, 0.1)
    var selectedBackgroundColor: UIColor? = .primary
    
    /// 按钮背景色
    var buttonNormalBackgroundColor: UIColor = .clear
    var buttonHighlightedBackgroundColor: UIColor = .clear
    
    /// 菜单条目数组
    var menuItems: [TPSegmentedMenuItem] = [] {
        didSet {
            setupButtons()
        }
    }
    
    /// 选中菜单回调
    var didSelectMenuItem: ((TPSegmentedMenuItem) -> Void)?

    /// 选中菜单标签
    var selectedMenuTag: Int? {
        return activeButton?.tag
    }

    private var menuButtons: [TPDefaultButton] = []
    private var activeButton: TPDefaultButton?
    private let activeLayer: CALayer = CALayer()
    
    private var containerView = UIView()
    private var contentView = UIScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        padding = UIEdgeInsets(value: 8.0)
        titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        titleConfig.selectedTextColor = .white
        titleConfig.textAlignment = .center
        imageConfig.selectedColor = .white
        
        addSubview(containerView)
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.layer.addSublayer(activeLayer)
        containerView.clipsToBounds = true
        containerView.addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let outerRadius = min(cornerRadius, halfHeight)
        let innerRadius = self.innerRadius
        self.layer.cornerRadius = outerRadius
        self.containerView.layer.cornerRadius = innerRadius
        self.containerView.frame = self.layoutFrame()
        
        self.contentView.frame = self.containerView.bounds
        self.layoutButtons()
        if let activeButton = activeButton {
            self.activeLayer.frame = activeButton.frame
            self.activeLayer.cornerRadius = innerRadius
            self.activeLayer.position = activeButton.center
        }

        layer.backgroundColor = normalBackgroundColor?.cgColor
        activeLayer.backgroundColor = selectedBackgroundColor?.cgColor
        CATransaction.commit()
    }
    
    var innerRadius: CGFloat {
        let outerRadius = min(cornerRadius, halfHeight)
        var radius = outerRadius - padding.left
        if radius <= 0 {
            radius = outerRadius
        }
        
        return radius
    }
    
    private func layoutButtons() {
        let layoutFrame = self.layoutFrame()
        let cornerRadius = innerRadius
        
        var contentWidth = 0.0
        var buttonLayouts = [(button: TPDefaultButton, width: CGFloat)]()
        for (index, button) in menuButtons.enumerated() {
            let buttonSize = fitSizeOf(button: button)
            buttonLayouts.append((button, buttonSize.width))
            contentWidth += buttonSize.width
            if index + 1 < menuButtons.count {
                contentWidth += margin
            }
        }
        
        var buttonAdjustWidth: CGFloat = 0.0
        if contentWidth < containerView.width, menuButtons.count > 0 {
            buttonAdjustWidth = (containerView.width - contentWidth) / CGFloat(menuButtons.count)
            contentWidth = containerView.width
        }
        
        var left = 0.0
        for (button, width) in buttonLayouts {
            let buttonWidth = width + buttonAdjustWidth
            button.padding = buttonEdgeInsets
            button.preferredTappedScale = preferredTappedScale
            button.scaleMaxLength = 12.0
            button.imagePosition = imagePosition
            button.imageConfig = imageConfig
            button.titleConfig = titleConfig
            button.frame = CGRect(x: left, y: 0.0, width: buttonWidth, height: layoutFrame.height)
            button.cornerRadius = cornerRadius
            left += buttonWidth + margin
        }
        
        contentView.contentSize = CGSize(width: contentWidth, height: contentView.height)
    }
    
    private func fitSizeOf(button: TPDefaultButton) -> CGSize {
        let fitSize = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                 height: buttonHeight))
        let width = min(max(fitSize.width, minButtonWidth), maxButtonWidth)
        return CGSize(width: width, height: buttonHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var contentWidth = padding.left
        for button in menuButtons {
            button.padding = buttonEdgeInsets
            let width = fitSizeOf(button: button).width
            contentWidth += width
            contentWidth += margin
        }
        
        contentWidth -= margin
        contentWidth += padding.right
        let contentHeight = buttonHeight + padding.top + padding.bottom
        
        return CGSize(width: contentWidth, height: contentHeight)
    }

    // 选择菜单
    func selectMenu(at index: Int, animated: Bool = true) {
        guard index < menuButtons.count else {
            return
        }
        
        let button = menuButtons[index]
        setActiveButton(button, animated: animated)
    }

    func selectMenu(withTag tag: Int, animated: Bool = true) {
        var activeButton: TPDefaultButton? = nil
        for button in menuButtons {
            if button.tag == tag {
                activeButton = button
                break
            }
        }
        
        if let activeButton = activeButton {
            setActiveButton(activeButton, animated: animated)
        }
    }

    // 初始化按钮
    func setupButtons() {
        menuButtons.forEach { button in
            button.removeFromSuperview()
        }
        
        menuButtons.removeAll()
        for menuItem in menuItems {
            let button = buttonWithMenuItem(menuItem)
            button.tag = menuItem.tag
            button.alpha = inactiveBttonAlpha
            menuButtons.append(button)
            contentView.addSubview(button)
        }
        
        if let button = menuButtons.first {
            setActiveButton(button, animated: false)
        }
        
        setNeedsLayout()
    }
    
    func buttonWithMenuItem(_ menuItem: TPSegmentedMenuItem) -> TPDefaultButton {
        let button = TPDefaultButton()
        button.padding = .zero
        button.normalBackgroundColor = buttonNormalBackgroundColor
        button.selectedBackgroundColor = buttonHighlightedBackgroundColor
        button.imageConfig = imageConfig
        button.imageName = menuItem.iconName
        button.titleConfig = titleConfig
        button.title = menuItem.title
        button.addTarget(self,
                         action: #selector(clickMenuButton(_:)),
                         for: .touchUpInside)
        return button
    }

    // MARK: - Event Response
    @objc func clickMenuButton(_ button: TPDefaultButton) {
        if activeButton != button {
            TPImpactFeedback.impactWithLightStyle()
            setActiveButton(button, animated: true)
            if let index = menuButtons.firstIndex(of: button) {
                let menuItem = menuItems[index]
                didSelectMenuItem?(menuItem)
            }
        }
    }

    var preferredAnimateScaleValues = [1.0, 0.85, 1.2, 0.95, 1.05, 1.0]
    func animateScaleValues(for button: UIButton) -> [Double] {
        let longSideLength = button.bounds.longSideLength
        let maxScaleLength = 15.0
        if longSideLength > 0.0, longSideLength * (1 - preferredTappedScale) > maxScaleLength {
            let factor = maxScaleLength / longSideLength
            return [1.0,
                    1.0 - factor,
                    1.0 + factor / 2.0,
                    1.0 - factor / 4.0,
                    1.0 + factor / 8.0,
                    1.0]
        }
        
        return preferredAnimateScaleValues
    }

    func setActiveButton(_ activeButton: TPDefaultButton, animated: Bool = false) {
        if self.activeButton != activeButton {
            self.activeButton?.normalBackgroundColor = buttonNormalBackgroundColor
            self.activeButton?.selectedBackgroundColor = buttonHighlightedBackgroundColor
            activeButton.normalBackgroundColor = .clear
            activeButton.selectedBackgroundColor = .clear
            let prevActiveButton = self.activeButton
            let currActiveButton = activeButton
            self.activeButton = activeButton
            
            prevActiveButton?.isSelected = false
            currActiveButton.isSelected = true
            prevActiveButton?.alpha = self.inactiveBttonAlpha
            
            let handler = {
                currActiveButton.alpha = 1.0
                self.activeLayer.frame = currActiveButton.frame
                self.contentView.scrollRectToVisibleCenter(currActiveButton.frame, animated: false)
            }
            
            guard animated else {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                handler()
                CATransaction.commit()
                return
            }
            
            scaleAnimateButton(activeButton)
            UIView.animate(withDuration: 0.4, delay: 0, options: .beginFromCurrentState, animations: {
                handler()
            }, completion: nil)
        }
    }
    
    private func scaleAnimateButton(_ button: TPDefaultButton) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = animateScaleValues(for: button)
        animation.duration = 0.4
        animation.calculationMode = .cubic
        button.layer.add(animation, forKey: nil)
    }
    
    // MTPageMenuProtocol
    func selectItem(at index: Int, animated: Bool) {
        selectMenu(at: index)
    }
}
