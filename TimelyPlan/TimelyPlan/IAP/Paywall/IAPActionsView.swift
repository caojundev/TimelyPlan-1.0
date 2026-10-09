//
//  IAPActionsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/20.
//

import Foundation
import UIKit

class IAPActionsView: UIView {
    
    struct Config {
        static let padding = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        static let margin = 8.0
        static let buttonHeight = 50.0
    }
    
    // MARK: - Callbacks
    
    var onRestorePurchasesTapped: (() -> Void)?
    var onRedeemCodeTapped: (() -> Void)?
    
    // MARK: - Properties
    
    var actionButtons: [UIView] {
        didSet {
            // 移除旧的视图
            oldValue.forEach { $0.removeFromSuperview() }
            // 添加新的视图
            setupActionButtons()
            // 重新布局
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        self.actionButtons = []
        super.init(frame: frame)
        setupDefaultButtons()
    }
    
    required init?(coder: NSCoder) {
        self.actionButtons = []
        super.init(coder: coder)
        setupDefaultButtons()
    }
    
    // MARK: - Setup
    
    private func setupDefaultButtons() {
        let restoreButton = createButton(title: "Restore Purchases", action: #selector(restorePurchasesTapped))
        actionButtons = [restoreButton]
    }
    
    private func setupActionButtons() {
        actionButtons.forEach { view in
            addSubview(view)
        }
    }
    
    private func createButton(title: String, action: Selector) -> TPBaseButton {
        let button = TPDefaultButton()
        button.titleConfig.textColor = IAPColor.primary
        button.preferredTappedScale = 0.9
        button.scaleMaxLength = 8.0
        button.title = title
        button.titleConfig.font = .systemFont(ofSize: 17, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Button Actions
    
    @objc private func restorePurchasesTapped() {
        onRestorePurchasesTapped?()
    }
    
    @objc private func redeemCodeTapped() {
        onRedeemCodeTapped?()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentWidth = bounds.width - Config.padding.left - Config.padding.right
        var yOffset = Config.padding.top
        
        for actionButton in actionButtons {
            actionButton.frame = CGRect(
                x: Config.padding.left,
                y: yOffset,
                width: contentWidth,
                height: Config.buttonHeight
            )
            yOffset += Config.buttonHeight + Config.margin
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var totalHeight = Config.padding.top + Config.padding.bottom
        
        for (index, _) in actionButtons.enumerated() {
            totalHeight += Config.buttonHeight
            if index < actionButtons.count - 1 {
                totalHeight += Config.margin
            }
        }
        
        return CGSize(width: size.width, height: totalHeight)
    }
    
    override var intrinsicContentSize: CGSize {
        var totalHeight = Config.padding.top + Config.padding.bottom
        
        for (index, _) in actionButtons.enumerated() {
            totalHeight += Config.buttonHeight
            if index < actionButtons.count - 1 {
                totalHeight += Config.margin
            }
        }
        
        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }
}
