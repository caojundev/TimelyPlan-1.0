//
//  AppProUpgradeBannerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/6.
//

import Foundation
import UIKit

/// 会员升级横幅
class AppProUpgradeBannerView: UIView {

    private let skeleton = TPSkeletonView(frame: .zero)
    
    /// 内容视图（圆角与渐变背景作用于此，所有子视图都添加在内容视图上）
    private let contentView = UIView()
    
    private let gradientLayer = CAGradientLayer()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let badgeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14.0
        view.layer.masksToBounds = true
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 0.8, alpha: 0.8)
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private let watermarkImageView: UIImageView = {
        // 默认使用系统自带的皇冠图标
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .ultraLight)
        let image = UIImage(systemName: "crown.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor(white: 1.0, alpha: 0.08)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Properties
    
    /// 内容内间距（用于制造卡片四周的空白）
    var contentPadding: UIEdgeInsets = .zero {
        didSet {
            if contentPadding != oldValue {
                setNeedsLayout()
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    /// 卡片高度
    var cardHeight: CGFloat = 120.0 {
        didSet {
            if cardHeight != oldValue {
                setNeedsLayout()
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    /// 卡片内部间距
    private let cardPadding: CGFloat = 20.0

    private let cornerRadius = 16.0
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        /// 圆角作用在内容视图上
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        
        /// 渐变背景配置
        gradientLayer.colors = [
            UIColor(red: 0.11, green: 0.09, blue: 0.16, alpha: 1.0).cgColor,
            UIColor(red: 0.18, green: 0.18, blue: 0.24, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        addSubview(contentView)
        
        contentView.addSubview(watermarkImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(badgeContainer)
        badgeContainer.addSubview(badgeLabel)
        contentView.addSubview(subtitleLabel)
        
        skeleton.clipsToBounds = true
        skeleton.layer.cornerRadius = cornerRadius
        skeleton.alpha = 0.2
        addSubview(skeleton)
    }
    
    // MARK: - Public Configuration Method
    
    /// 配置卡片内容
    /// - Parameters:
    ///   - title: 主标题 (例如 "Timely Plan Pro")
    ///   - badgeText: 标签文字前半部分 (例如 "Limited Time Offer")
    ///   - badgeEmoji: 标签文字后面的表情 (例如 "🔥")
    ///   - badgeColor: 标签文字的颜色 (例如 橙色)
    ///   - subtitle: 副标题描述
    func configure(title: String, badgeText: String, badgeEmoji: String, badgeColor: UIColor, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        /// 使用富文本拼接标签文字，保证 Emoji 颜色不受影响
        let fullBadgeString = badgeText + badgeEmoji
        let attributedString = NSMutableAttributedString(string: fullBadgeString)
        let range = (fullBadgeString as NSString).range(of: badgeText)
        attributedString.addAttribute(.foregroundColor, value: badgeColor, range: range)
        
        badgeLabel.attributedText = attributedString
        
        /// 触发重新布局
        setNeedsLayout()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = bounds.inset(by: contentPadding)
        skeleton.frame = contentFrame
        contentView.frame = contentFrame
        gradientLayer.frame = contentView.bounds
        
        let contentBounds = contentView.bounds
        let contentWidth = max(contentBounds.width - (cardPadding * 2.0), 0.0)
        
        /// 1. 右下角水印
        let iconSize: CGFloat = 100.0
        watermarkImageView.frame = CGRect(
            x: contentBounds.width - iconSize - 10.0,
            y: contentBounds.height - iconSize + 10.0,
            width: iconSize,
            height: iconSize
        )
        
        /// 2. 主标题
        let titleSize = titleLabel.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(x: cardPadding,
                                  y: cardPadding + 4.0,
                                  width: min(titleSize.width, contentWidth),
                                  height: titleSize.height)
        
        /// 3. Badge 标签（紧贴标题右侧，且不超出卡片范围）
        guard let badgeText = badgeLabel.attributedText?.string, !badgeText.isEmpty else {
            badgeContainer.frame = .zero
            /// 继续布局下方的 subtitle
            layoutSubtitle(contentWidth: contentWidth, titleMaxY: titleLabel.frame.maxY)
            return
        }
        
        let badgeTextSize = badgeLabel.sizeThatFits(.unlimited)
        let badgeWidth = badgeTextSize.width + 20.0
        let badgeHeight: CGFloat = 28.0
        
        let badgeX = min(titleLabel.frame.maxX + 10.0, contentBounds.width - cardPadding - badgeWidth)
        let badgeY = titleLabel.frame.midY - (badgeHeight / 2.0)
        badgeContainer.frame = CGRect(x: badgeX, y: badgeY, width: badgeWidth, height: badgeHeight)
        badgeLabel.frame = badgeContainer.bounds
        
        /// 4. 副标题
        layoutSubtitle(contentWidth: contentWidth, titleMaxY: titleLabel.frame.maxY)
    }
    
    /// 布局副标题
    private func layoutSubtitle(contentWidth: CGFloat, titleMaxY: CGFloat) {
        let subtitleY = titleMaxY + 20.0
        let subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude))
        subtitleLabel.frame = CGRect(x: cardPadding,
                                     y: subtitleY,
                                     width: contentWidth,
                                     height: subtitleSize.height)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: cardHeight + contentPadding.verticalLength)
    }
}
