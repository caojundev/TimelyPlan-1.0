//
//  TPInfoTextValueView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/5.
//

import Foundation

class TPInfoTextValueView: TPInfoView {
    
    /// 值配置信息
    var valueConfig: TPTextAccessoryConfig? {
        didSet {
            valueLabel.text = valueConfig?.valueText
            valueLabel.font = valueConfig?.valueFont
            valueLabel.textColor = valueConfig?.textColor ?? .secondaryLabel
            rightAccessorySize = valueConfig?.valueSize ?? .zero
            rightAccessoryMargins = valueConfig?.valueMargins ?? .zero
            setNeedsLayout()
        }
    }

    /// 数值标签
    private lazy var valueLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = .zero
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        self.rightAccessoryView = valueLabel
        self.rightAccessorySize = .zero
    }
}
