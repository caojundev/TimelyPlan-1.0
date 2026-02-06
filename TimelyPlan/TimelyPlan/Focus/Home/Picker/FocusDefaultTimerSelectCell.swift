//
//  FocusDefaultTimerSelectCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/3.
//

import Foundation

class FocusDefaultTimerSelectCell: TPImageInfoCollectionCell {
    
    var timer: FocusSystemTimer? {
        didSet {
            self.updateInfo()
        }
    }
    
    lazy var checkmarkImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = resGetImage("checkmark_24")
        imageView.updateImage(withColor: .primary)
        return imageView
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.padding = UIEdgeInsets(top: 5.0, left: 16.0, bottom: 5.0, right: 10.0)
        infoView.rightAccessoryView = checkmarkImageView
        infoView.rightAccessorySize = .mini
        infoView.titleConfig.textAlignment = .left
        infoView.subtitleConfig.textAlignment = .left
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkImageView.isHidden = !checked
    }
    
//    override func updateCellStyle() {
//        super.updateCellStyle()
//        backgroundView?.backgroundColor = cellStyle?.backgroundColor
//    }
    
    func updateInfo() {
        imageContent = .withName(timer?.timerType.iconName)
        infoView.title = timer?.timerType.title
        infoView.subtitle = timer?.timerInfo
    }
}
