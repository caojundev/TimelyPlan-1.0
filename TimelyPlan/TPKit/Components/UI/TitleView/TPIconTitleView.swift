//
//  TPIconTitleView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/12.
//

import Foundation
import UIKit

class TPIconTitleView: TPAccessoryTitleView {

    var icon: TPIcon? {
        get {
            return iconConfig.icon
        }
        
        set {
            iconConfig.icon = newValue
            setNeedsLayout()
        }
    }
    
    var foreColor: UIColor? {
        get {
            return iconConfig.foreColor
        }
        
        set {
            iconConfig.foreColor = newValue
            setNeedsLayout()
        }
    }
    
    var iconConfig = TPIconAccessoryConfig() {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 图标视图
    let iconView = TPIconView()
    
    override var accessorySize: CGSize {
        get {
            return iconConfig.size
        }
        
        set {
            iconConfig.size = newValue
        }
    }
    
    override var accessoryMargins: UIEdgeInsets {
        get {
            return iconConfig.margins
        }
        
        set {
            iconConfig.margins = newValue
        }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        self.accessoryView = iconView
    }
    
    override func updateContent() {
        super.updateContent()
        iconView.icon = iconConfig.icon
        iconView.foreColor = iconConfig.foreColor
        iconView.backColor = iconConfig.backColor
        iconView.placeholderImage = iconConfig.placeholderImage
    }
    
    override func fitAccessorySize() -> CGSize {
        var size = super.fitAccessorySize()
        if icon == nil {
            size = .zero
        }
        
        return size
    }
    
    override func fitAccessoryMargins() -> UIEdgeInsets {
        var margins = super.fitAccessoryMargins()
        if icon == nil || title == nil {
            margins = .zero
        }
        
        return margins
    }
}
