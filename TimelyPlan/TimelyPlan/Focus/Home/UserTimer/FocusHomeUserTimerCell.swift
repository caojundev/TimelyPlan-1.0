//
//  FocusHomeUserTimerCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/20.
//

import Foundation

class FocusHomeUserTimerCell: FocusUserTimerListCell {
    
    var isFocusing: Bool = false {
        didSet {
            if isFocusing {
                focusingView.startAnimation()
                focusingView.isHidden = false
            } else {
                focusingView.stopAnimation()
                focusingView.isHidden = !isFocusing
            }
        }
    }
    
    lazy var focusingView: TPWaveIndicatorView = {
        let view = TPWaveIndicatorView()
        view.size = CGSize(width: 20.0, height: 20.0)
        view.lineHeight = 16.0
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(focusingView)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        focusingView.right = moreButton.left
        focusingView.centerY = infoView.centerY
        infoView.width = infoView.width - focusingView.width
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isFocusing = false
    }
}
