//
//  TPImageButton.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/8.
//

import Foundation
import UIKit

class TPImageButton: TPBaseButton {
    
    /// 正常状态图片
    var normalImage: UIImage? {
        didSet {
            if normalImage != oldValue {
                setNeedsLayout()
            }
        }
    }

    /// 正常状态图片颜色
    var normalImageColor: UIColor? {
        didSet {
            if normalImageColor != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 高亮图片
    var highlightedImage: UIImage? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 高亮图片颜色
    var highlightedImageColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 选中图片
    var selectedImage: UIImage? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 选中图片颜色
    var selectedImageColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    
    var imageSize: CGSize? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 当前图片
    override var currentImage: UIImage? {
        var image = normalImage
        if isTapped {
            image = highlightedImage ?? (isSelected ? selectedImage : normalImage)
        } else if isSelected {
            image = selectedImage ?? normalImage
        }
        
        return image
    }
    
    /// 当前状态图片颜色
    private var currentImageColor: UIColor? {
        var color = normalImageColor
        if isTapped {
            color = highlightedImageColor ?? (isSelected ? selectedImageColor : normalImageColor)
        } else if isSelected {
            color = selectedImageColor ?? normalImageColor
        }
        
        return color
    }
    
    /// 图片视图
    private let imgView = UIImageView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(imgView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateImage()
        
        let layoutFrame = layoutFrame()
        if let imageSize = imageSize {
            imgView.size = imageSize
        } else {
            imgView.sizeToFit()
        }
        
        imgView.center = layoutFrame.center
        imgView.updateContentMode()
    }
    
    private func updateImage() {
        imgView.image = currentImage
        if let imageColor = currentImageColor {
            imgView.updateImage(withColor: imageColor)
        }
    }
    
    override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        return imgView.sizeThatFits(size)
    }
}

