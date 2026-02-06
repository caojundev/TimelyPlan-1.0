//
//  TPImageInfoCollectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/20.
//

import Foundation
import UIKit

class TPImageInfoCollectionCellItem: TPDefaultInfoCollectionCellItem {
    
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
        self.registerClass = TPImageInfoCollectionCell.self
    }
}

class TPImageInfoCollectionCell: TPDefaultInfoCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            let cellItem = cellItem as! TPImageInfoCollectionCellItem
            imageConfig = cellItem.imageConfig
            imageContent = cellItem.imageContent
            setNeedsLayout()
        }
    }
    
    var imageContent: TPImageContent? {
        didSet {
            guard let infoView = infoView as? TPImageInfoView else {
                return
            }
            
            infoView.imageContent = imageContent
        }
    }
    
    var imageConfig = TPImageAccessoryConfig() {
        didSet {
            guard let infoView = infoView as? TPImageInfoView else {
                return
            }
            
            infoView.imageConfig = imageConfig
            setNeedsLayout()
        }
    }
    
    override func setupInfoView() {
        self.infoView = TPImageInfoView()
    }
}
