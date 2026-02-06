//
//  TPImageTitleCollectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/18.
//

import Foundation
import UIKit

class TPImageTitleCollectionCell: TPCollectionCell {
    
    lazy var imageTitleView: TPImageTitleView = {
        var view = TPImageTitleView()
        view.accessoryPosition = .left
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(imageTitleView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        imageTitleView.sizeToFit()
        imageTitleView.width = min(layoutFrame.width, imageTitleView.width)
        imageTitleView.height = min(layoutFrame.height, imageTitleView.height)
        imageTitleView.center = layoutFrame.center
        
        /// 更新状态
        imageTitleView.isHighlighted = isHighlighted
        imageTitleView.isSelected = isSelected || isChecked
    }
}
