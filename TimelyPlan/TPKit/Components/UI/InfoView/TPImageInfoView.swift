//
//  TPImageInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/8.
//

import Foundation
import UIKit

class TPImageInfoView: TPInfoView {
    
    var imageName: String? {
        get {
            return imageContent?.value as? String
        }
        
        set {
            imageContent = .withName(newValue)
        }
    }
    
    /// 图片内容
    var imageContent: TPImageContent? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 颜色配置
    var imageConfig = TPImageAccessoryConfig() {
        didSet {
            setNeedsLayout()
        }
    }

    /// 图标视图
    private(set)var imageView = TPImageView()

    override func setupSubviews() {
        super.setupSubviews()
        self.leftAccessoryView = imageView
        self.leftAccessorySize = .mini
        self.leftAccessoryMargins = UIEdgeInsets(right: 10.0)
    }

    override func layoutAccessoryView() {
        let accessorySize = imageContent?.fitSize(with: imageConfig) ?? .zero
        let accessoryMargins = imageContent?.fitMargins(with: imageConfig) ?? .zero
        /// 图片为左视图
        if leftAccessoryView != nil {
            leftAccessorySize = accessorySize
            leftAccessoryMargins = accessoryMargins
        }
        
        /// 图片为右视图
        if rightAccessoryView != nil {
            rightAccessorySize = accessorySize
            rightAccessoryMargins = accessoryMargins
        }
        
        super.layoutAccessoryView()
        
        imageView.isSelected = isSelected
        imageView.update(content: imageContent, config: imageConfig)
        imageView.updateContentMode()
    }
}


class TPRightImageInfoView: TPImageInfoView {
    
    override func setupSubviews() {
        super.setupSubviews()
        
        self.leftAccessoryView = nil
        self.leftAccessorySize = .zero
        self.leftAccessoryMargins = .zero
        
        self.rightAccessoryView = imageView
        self.rightAccessorySize = .mini
        self.rightAccessoryMargins = .zero
    }
}
