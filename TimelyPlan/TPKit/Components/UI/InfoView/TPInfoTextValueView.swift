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
            rightAccessorySize = valueConfig?.valueSize ?? .zero
            rightAccessoryMargins = valueConfig?.valueMargins ?? .zero
            valueLabel.textColor = valueConfig?.textColor ?? .secondaryLabel
            valueLabel.font = valueConfig?.valueFont
            valueLabel.update(with: valueConfig?.valueText)
            setNeedsLayout()
        }
    }

    /// 数值标签
    private lazy var valueLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = .zero
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.numberOfLines = 1
        return label
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        self.rightAccessoryView = valueLabel
        self.rightAccessorySize = .zero
    }
}
