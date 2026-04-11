//
//  TPImageInfoButton.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/11.
//

import Foundation
import UIKit

class TPImageInfoButton: TPBaseButton {
    
    /// 更新选中状态
    override var isSelected: Bool {
        didSet {
            imageInfoView.isSelected = isSelected
        }
    }
    
    /// 更新高亮状态
    override var isHighlighted: Bool {
        didSet {
            imageInfoView.isHighlighted = isHighlighted
        }
    }
    
    let imageInfoView = TPImageInfoView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(imageInfoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageInfoView.frame = layoutFrame()
    }
    
    override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        return imageInfoView.sizeThatFits(size)
    }
}
