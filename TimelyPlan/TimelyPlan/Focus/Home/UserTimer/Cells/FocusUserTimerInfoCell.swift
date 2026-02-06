//
//  FocusUserTimerInfoCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/30.
//

import Foundation

class FocusUserTimerInfoCell: TPDefaultInfoCollectionCell {
    
    var timer: FocusTimer? {
        didSet {
            self.updateInfo()
        }
    }
    
    let kInfoViewMargin = 10.0
    
    let kIndicatorSize = CGSize(width: 6.0, height: 36.0)
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.size = kIndicatorSize
        view.layer.cornerRadius = kIndicatorSize.width / 2.0
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentView.padding = UIEdgeInsets(top: 5.0, left: 16.0, bottom: 5.0, right: 10.0)
        contentView.addSubview(indicatorView)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        indicatorView.size = kIndicatorSize
        indicatorView.left = layoutFrame.minX
        indicatorView.alignVerticalCenter()
        
        infoView.width = layoutFrame.width - indicatorView.width - kInfoViewMargin
        infoView.height = layoutFrame.height
        infoView.left = indicatorView.right + kInfoViewMargin
        infoView.top = layoutFrame.minY
    }
    
    func updateInfo() {
        indicatorView.backgroundColor = timer?.color ?? kFocusTimerDefaultColor
        infoView.title = timer?.name ?? resGetString("Untitled")
        infoView.subtitle = timer?.timerInfo
    }
}
