//
//  TPColorInfoTextValueView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/5.
//

import Foundation
import UIKit

class TPColorAccessoryConfig {
    
    /// 值文本
    var color: UIColor?

    /// 颜色尺寸
    var size: CGSize = .size(2)
    
    /// 颜色外间距
    var margins = UIEdgeInsets(left: 10.0, right: 10.0)
    
    static func withColor(_ color: UIColor?, size: CGSize?) -> TPColorAccessoryConfig {
        let config = TPColorAccessoryConfig()
        config.color = color
        config.size = size ?? .size(2)
        return config
    }
}

class TPColorInfoTextValueView: TPInfoTextValueView {
    
    /// 颜色配置
    var colorConfig: TPColorAccessoryConfig? {
        didSet {
            colorView.backgroundColor = colorConfig?.color
            leftAccessorySize = colorConfig?.size ?? .zero
            leftAccessoryMargins = colorConfig?.margins ?? .zero
            setNeedsLayout()
        }
    }
    
    /// 颜色视图
    private(set) var colorView = UIView()
    
    override func setupSubviews() {
        super.setupSubviews()
        self.leftAccessoryView = colorView
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = colorView.size.roundCornerRadius
    }
}
