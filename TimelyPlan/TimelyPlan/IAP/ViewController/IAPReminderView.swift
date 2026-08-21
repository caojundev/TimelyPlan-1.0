//
//  IAPReminderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/20.
//

import Foundation
import UIKit

// MARK: - 内购订阅提醒视图（手动布局）
final class IAPReminderView: UIView {
 
    
    // MARK: - 回调
    var onTapPrivacy: (() -> Void)?
    var onTapTerms: (() -> Void)?

    // MARK: - 配置
    /// 左右内边距
    var horizontalInset: CGFloat = 16.0
    /// 文本与按钮行之间的间距
    var textToButtonGap: CGFloat = 16
    /// 两个按钮之间的间距
    var buttonSpacing: CGFloat = 24
    /// 图标与文字的间距
    var iconTitleSpacing: CGFloat = 6

    // MARK: - 子视图
    private let messageLabel = UILabel()
    private let privacyButton = TPDefaultButton()
    private let termsButton = TPDefaultButton()

    // MARK: - 文案
    private let messageText = """
The total amount for the subscription period will be charged to your iTunes account. Unless you turn off auto-renewal at least 24 hours before the end of the subscription period, the subscription will renew automatically for the same period, and your iTunes Account will be charged accordingly. You can manage the subscription and turn off automatic renewal in the Account Settings for your Apple ID at any time.
"""

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - 搭建
    private func setupUI() {
        backgroundColor = .clear

        // 说明文本
        messageLabel.text = messageText
        messageLabel.textColor = UIColor(red: 0.45, green: 0.48, blue: 0.55, alpha: 1.0)
        messageLabel.font = .systemFont(ofSize: 12.0, weight: .regular)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        addSubview(messageLabel)

        // 隐私政策按钮（图标 + 文字）
        configButton(privacyButton,
                     title: "Privacy Policy",
                     icon: UIImage(systemName: "lock.shield"))
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        addSubview(privacyButton)

        // 服务条款按钮
        configButton(termsButton,
                     title: "Terms of Service",
                     icon: UIImage(systemName: "doc.text"))
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
        addSubview(termsButton)
    }

    private func configButton(_ button: TPDefaultButton, title: String, icon: UIImage?) {
        button.preferredTappedScale = 0.9
        button.scaleMaxLength = 8.0
        button.title = title
        button.titleConfig.textColor = IAPColor.primary
        button.titleConfig.font = .systemFont(ofSize: 13.0, weight: .medium)
        button.imageConfig.color = IAPColor.primary
        button.imageConfig.size = .size(4)
        button.imageConfig.margins = UIEdgeInsets(right: 2.0)
        button.image = icon
    }

    // MARK: - 手动布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let width = bounds.width
        let contentWidth = width - horizontalInset * 2

        // 1. 说明文本
        let messageHeight = messageTextHeight(for: contentWidth)
        messageLabel.frame = CGRect(x: horizontalInset,
                                     y: 0,
                                     width: contentWidth,
                                     height: messageHeight)

        // 2. 计算两个按钮尺寸（sizeToFit 后取其大小）
        privacyButton.sizeToFit()
        termsButton.sizeToFit()
        let privacySize = privacyButton.bounds.size
        let termsSize = termsButton.bounds.size

        // 3. 两个按钮一行居中
        let totalButtonsWidth = privacySize.width + buttonSpacing + termsSize.width
        let startX = (width - totalButtonsWidth) / 2
        let buttonY = messageLabel.frame.maxY + textToButtonGap
        let buttonHeight = max(privacySize.height, termsSize.height)

        privacyButton.frame = CGRect(x: startX,
                                      y: buttonY,
                                      width: privacySize.width,
                                      height: buttonHeight)
        termsButton.frame = CGRect(x: privacyButton.frame.maxX + buttonSpacing,
                                    y: buttonY,
                                    width: termsSize.width,
                                    height: buttonHeight)
    }

    // MARK: - 自适应高度
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let contentWidth = size.width - horizontalInset * 2
        let messageHeight = messageTextHeight(for: contentWidth)

        privacyButton.sizeToFit()
        termsButton.sizeToFit()
        let buttonHeight = max(privacyButton.bounds.height, termsButton.bounds.height)

        let totalHeight = messageHeight + textToButtonGap + buttonHeight
        return CGSize(width: size.width, height: totalHeight)
    }

    override var intrinsicContentSize: CGSize {
        // 给一个默认宽度下的高度；外部若用手动布局，建议用 sizeThatFits
        return sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude))
    }

    // MARK: - 工具
    private func messageTextHeight(for width: CGFloat) -> CGFloat {
        let font = messageLabel.font ?? .systemFont(ofSize: 14)
        let rect = (messageText as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(rect.height)
    }

    // MARK: - 事件
    @objc private func privacyTapped() { onTapPrivacy?() }
    @objc private func termsTapped() { onTapTerms?() }
}
