//
//  TPImageInfoTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/28.
//

import Foundation
import UIKit

class TPImageInfoTableCellItem: TPDefaultInfoTableCellItem {
  
    var imageName: String? {
        get {
            return imageContent?.value as? String
        }
        
        set {
            imageContent = .withName(newValue)
        }
    }
    
    var imageContent: TPImageContent?
    
    var imageColor: UIColor? {
        get {
            return imageConfig.color
        }
        
        set {
            imageConfig.color = newValue
        }
    }
    
    var imageConfig = TPImageAccessoryConfig()

    override init() {
        super.init()
        self.registerClass = TPImageInfoTableCell.self
    }
    
    override func getLayout() -> TPBaseTableCellLayout {
        let layout = super.getLayout() as! TPDefaultInfoTableCellLayout
        layout.leftAccessorySize = imageContent?.fitSize(with: imageConfig) ?? .zero
        layout.leftAccessoryMargins = imageContent?.fitMargins(with: imageConfig) ?? .zero
        return layout
    }
}

class TPImageInfoTableCell: TPDefaultInfoTableCell {
   
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPImageInfoTableCellItem else {
                return
            }
            
            imageConfig = cellItem.imageConfig
            imageContent = cellItem.imageContent
            setNeedsLayout()
        }
    }
    
    var imageContent: TPImageContent? {
        didSet {
            imageInfoView.imageContent = imageContent
        }
    }
    
    var imageConfig: TPImageAccessoryConfig {
        get {
            return imageInfoView.imageConfig
        }
        
        set {
            imageInfoView.imageConfig = newValue
            setNeedsLayout()
        }
    }
    
    var imageInfoView: TPImageInfoView {
        return infoView as! TPImageInfoView
    }
    
    override func setupInfoView() {
        self.infoView = TPImageInfoView()
    }
}
