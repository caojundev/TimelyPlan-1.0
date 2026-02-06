//
//  TPImageCollectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/23.
//

import Foundation

class TPImageCollectionCellItem: TPCollectionCellItem {
    
    var imageName: String? {
        get {
            return imageContent?.value as? String
        }
        
        set {
            imageContent = .withName(newValue)
        }
    }
    
    var imageContent: TPImageContent?
    
    var imageConfig = TPImageAccessoryConfig()
    
    override init() {
        super.init()
        self.registerClass = TPImageCollectionCell.self
    }
}

class TPImageCollectionCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPImageCollectionCellItem else {
                imageContent = nil
                return
            }
            
            imageContent = cellItem.imageContent
            imageConfig = cellItem.imageConfig
            setNeedsLayout()
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
    
    private let imageView = TPImageView()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        imageView.size = imageConfig.size
        imageView.center = layoutFrame.center
        imageView.update(content: imageContent, config: imageConfig)
    }
}
