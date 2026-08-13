//
//  TPPermissionDeniedView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/17.
//

import Foundation
import UIKit
import FluentDarkModeKit

class TPPermissionDeniedView: UIView {
    
    struct Constants {
        static let margin = 15.0
        static let padding = UIEdgeInsets(horizontal: 16.0, vertical: 24.0)
        static let numberOfTitleLines = 2
        static let numberOfSubtitleLines = 0
        static let accessButtonHeight = 50.0
        static let accessButtonFont = BOLD_SYSTEM_FONT
    }
    
    lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.alpha = 0.9
        label.font = .boldSystemFont(ofSize: 16.0)
        label.textColor = .label
        label.numberOfLines = Constants.numberOfTitleLines
        label.textAlignment = .center
        return label
    }()
    
    lazy var subtitleLabel: TPLabel = {
        let label = TPLabel()
        label.alpha = 0.8
        label.font = .systemFont(ofSize: 13.0)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = Constants.numberOfSubtitleLines
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.alpha = 0.6
        return view
    }()
    
    lazy var allowAccessButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.title = resGetString("Enable in Settings")
        button.cornerRadius = .greatestFiniteMagnitude
        button.normalBackgroundColor = .primary
        button.selectedBackgroundColor = .primary.darkerColor
        button.titleConfig.font = Constants.accessButtonFont
        button.titleConfig.textColor = .white
        button.scaleMaxLength = 4.0
        button.addTarget(self, action: #selector(clickAllowAccess), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(imageView)
        addSubview(allowAccessButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        padding = Constants.padding
        let layoutFrame = layoutFrame()
        titleLabel.width = layoutFrame.width
        subtitleLabel.width = layoutFrame.width
        titleLabel.sizeToFit()
        subtitleLabel.sizeToFit()
        imageView.sizeToFit()
        let topMargin = (layoutFrame.height - titleLabel.height - subtitleLabel.height - imageView.height - Constants.accessButtonHeight - 3 * Constants.margin) / 2.0
        titleLabel.top = layoutFrame.minY + topMargin
        titleLabel.alignHorizontalCenter()
        
        subtitleLabel.top = titleLabel.bottom + Constants.margin
        subtitleLabel.alignHorizontalCenter()
        
        imageView.alignHorizontalCenter()
        imageView.top = subtitleLabel.bottom + Constants.margin
        imageView.updateImage(withColor: .label)
        
        allowAccessButton.width = layoutFrame.width
        allowAccessButton.height = Constants.accessButtonHeight
        allowAccessButton.left = layoutFrame.minX
        allowAccessButton.top = imageView.bottom + Constants.margin
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let contentWidth = size.width - Constants.padding.horizontalLength
        let constraintSize = CGSize(width: contentWidth, height: size.height)
        
        var contentHeight = Constants.padding.verticalLength
        contentHeight += titleLabel.sizeThatFits(constraintSize).height + Constants.margin
        contentHeight += subtitleLabel.sizeThatFits(constraintSize).height + Constants.margin
        if let image = imageView.image {
            contentHeight += image.size.height + Constants.margin
        }
        
        contentHeight += Constants.accessButtonHeight
        return CGSize(width: size.width, height: contentHeight)
    }
    
    @objc func clickAllowAccess() {
        TPImpactFeedback.impactWithLightStyle()
        AppSettingUtil.openSettings()
    }
}
