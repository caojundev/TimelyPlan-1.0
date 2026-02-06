//
//  FocusUserTimerListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/28.
//

import Foundation
import UIKit

protocol FocusUserTimerListCellDelegate: AnyObject {
    /// 点击更多
    func focusUserTimerListCellDidClickMore(_ cell: FocusUserTimerListCell)
}

class FocusUserTimerListCell: FocusUserTimerInfoCell {
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(moreButton)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        moreButton.sizeToFit()
        moreButton.right = layoutFrame.maxX
        moreButton.alignVerticalCenter()
        infoView.width = infoView.width - moreButton.width
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? FocusUserTimerListCellDelegate {
            delegate.focusUserTimerListCellDidClickMore(self)
        }
    }
    
}
