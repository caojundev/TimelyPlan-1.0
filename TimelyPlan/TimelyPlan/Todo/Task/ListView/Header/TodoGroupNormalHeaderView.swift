//
//  TodoGroupNormalHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/14.
//

import Foundation
import UIKit

class TodoGroupNormalHeaderView: TodoGroupBaseHeaderView {
    
    var count: Int = 0 {
        didSet {
            if count != oldValue {
                countLabel.text = "\(count)"
                setNeedsLayout()
            }
        }
    }
    
    private(set) lazy var countLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 10.0, vertical: 8.0)
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textColor = resGetColor(.title)
        label.text = "\(count)"
        return label
    }()
    
    override func setupContentSubViews() {
        super.setupContentSubViews()
        contentView.addSubview(countLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        countLabel.layer.backgroundColor = expandButton.normalBackgroundColor?.cgColor
        countLabel.layer.cornerRadius = 8.0
        countLabel.sizeToFit()
        countLabel.centerY = layoutFrame.midY
        countLabel.right = layoutFrame.maxX
        let expandButtonMaxWidth = countLabel.left - layoutFrame.minX - 5.0
        if expandButton.width > expandButtonMaxWidth {
            expandButton.width = expandButtonMaxWidth
        }
    }
}
