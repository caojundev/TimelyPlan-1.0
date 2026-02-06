//
//  TPImageView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/11.
//

import Foundation

class TPImageView: UIImageView {
    
    /// 是否为选中状态
    var isSelected: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    func update(content: TPImageContent?, config: TPImageAccessoryConfig) {
        self.image = content?.image
        
        var imageColor: UIColor?
        if config.shouldRenderImageWithColor {
            /// 根据状态获取当前文本颜色
            if isHighlighted {
                imageColor = config.highlightedColor
            } else if isSelected {
                imageColor = config.selectedColor
            }
            
            if imageColor == nil {
                imageColor = config.color
            }
        }
        
        updateImage(withColor: imageColor)
        updateContentMode()
    }
}
