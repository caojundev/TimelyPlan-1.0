//
//  TPIconInfoTextValueView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/6.
//

import Foundation
import UIKit

class TPIconInfoTextValueView: TPInfoTextValueView {
    
    /// 颜色配置
    var iconConfig: TPIconAccessoryConfig? {
        didSet {
            iconView.icon = iconConfig?.icon
            iconView.foreColor = iconConfig?.foreColor
            leftAccessorySize = iconConfig?.size ?? .zero
            leftAccessoryMargins = iconConfig?.margins ?? .zero
            setNeedsLayout()
        }
    }
    
    /// 图标视图
    private(set)var iconView = TPIconView()
    
    override func setupSubviews() {
        super.setupSubviews()
        self.leftAccessoryView = iconView
        self.leftAccessorySize = .size(8)
    }
}
