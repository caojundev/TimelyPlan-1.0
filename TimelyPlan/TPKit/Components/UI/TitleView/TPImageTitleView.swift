//
//  TPImageTitleView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/12.
//

import Foundation
import UIKit

class TPImageTitleView: TPAccessoryTitleView {

    var imageName: String? {
        get {
            return imageContent?.name
        }
        
        set {
            imageContent = .withName(newValue)
        }
    }
    
    var image: UIImage? {
        get {
            return imageContent?.image
        }
        
        set {
            imageContent = .withImage(newValue)
        }
    }
    
    var imageContent: TPImageContent? {
        didSet {
            setNeedsLayout()
        }
    }
    
    var imageConfig = TPImageAccessoryConfig() {
        didSet {
            setNeedsLayout()
        }
    }
    
    let imageView = TPImageView()
    
    override var accessorySize: CGSize {
        get {
            return imageConfig.size
        }
        
        set {
            imageConfig.size = newValue
        }
    }
    
    override var accessoryMargins: UIEdgeInsets {
        get {
            return imageConfig.margins
        }
        
        set {
            imageConfig.margins = newValue
        }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        self.accessoryView = imageView
    }
    
    override func updateContent() {
        super.updateContent()
        
        imageView.isHighlighted = isHighlighted
        imageView.isSelected = isSelected
        imageView.update(content: imageContent, config: imageConfig)
    }
    
    override func fitAccessorySize() -> CGSize {
        var size = super.fitAccessorySize()
        if imageContent?.image == nil {
            size = .zero
        }
        
        return size
    }
    
    override func fitAccessoryMargins() -> UIEdgeInsets {
        var margins = super.fitAccessoryMargins()
        if imageContent?.image == nil || title == nil {
            margins = .zero
        }
        
        return margins
    }
}
