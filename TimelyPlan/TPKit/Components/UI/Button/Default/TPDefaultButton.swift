//
//  TPDefaultButton.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/28.
//

import Foundation
import UIKit

class TPDefaultButton: TPBaseButton {

    var title: TextRepresentable? {
        get {
            return imageTitleView.title
        }
        
        set {
            imageTitleView.title = newValue
            setNeedsLayout()
        }
    }
    
    var titleConfig: TPLabelConfig {
        get {
            return imageTitleView.titleConfig
        }
        
        set {
            imageTitleView.titleConfig = newValue
        }
    }
    
    var imageName: String? {
        get {
            return imageTitleView.imageName
        }
        
        set {
            imageTitleView.imageName = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return imageTitleView.image
        }
        
        set {
            imageTitleView.image = newValue
        }
    }
    
    var imageConfig: TPImageAccessoryConfig {
        get {
            return imageTitleView.imageConfig
        }
        
        set {
            imageTitleView.imageConfig = newValue
        }
    }
    
    var imagePosition: TPAccessoryPosition {
        get {
            return imageTitleView.accessoryPosition
        }
        
        set {
            imageTitleView.accessoryPosition = newValue
        }
    }
    
    /// 更新选中状态
    override var isSelected: Bool {
        didSet {
            imageTitleView.isSelected = isSelected
        }
    }
    
    /// 更新高亮状态
    override var isHighlighted: Bool {
        didSet {
            imageTitleView.isHighlighted = isHighlighted
        }
    }
    
    /// 图片标题视图
    private(set) var imageTitleView = TPImageTitleView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(imageTitleView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        let size = imageTitleView.sizeThatFits(.unlimited)
        let width = min(size.width, layoutFrame.width)
        let height = min(size.height, layoutFrame.height)
        imageTitleView.size = CGSize(width: width, height: height)
        imageTitleView.center = layoutFrame.center
    }
    
    override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        return imageTitleView.sizeThatFits(size)
    }
}

extension TPDefaultButton {
    
    static func button(with image: UIImage?) -> TPDefaultButton {
        let button = TPDefaultButton()
        button.padding = .zero
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.imageConfig.margins = .zero
        button.imageConfig.color = .grayPrimary
        button.image = image
        return button
    }
    
    /// 更多按钮
    static func moreButton() -> TPDefaultButton {
        let image = resGetImage("ellipsis_vertical_24")
        let button = TPDefaultButton.button(with: image)
        return button
    }
    
    /// 添加按钮
    static func addButton() -> TPDefaultButton {
        let image = resGetImage("plus_24")
        let button = TPDefaultButton.button(with: image)
        return button
    }
    
    static func outlineButton(withTitle title: String?,
                              textColor: UIColor?,
                              borderColor: UIColor?) -> TPDefaultButton {
        let button = TPDefaultButton()
        button.borderWidth = 2.0
        button.normalBackgroundColor = .clear
        button.selectedBackgroundColor = .clear
        button.normalBorderColor = borderColor
        button.selectedBorderColor = borderColor
        
        let textColor = textColor ?? .label
        button.titleConfig.textColor = textColor
        button.titleConfig.highlightedTextColor = textColor
        button.titleConfig.selectedTextColor = textColor
        button.title = title
        return button;
    }
}
