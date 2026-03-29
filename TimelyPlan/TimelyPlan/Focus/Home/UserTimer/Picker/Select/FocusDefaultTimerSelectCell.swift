//
//  FocusDefaultTimerSelectCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/29.
//

import Foundation
import UIKit

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
        contentView.padding = UIEdgeInsets(top: 5.0, left: 8.0, bottom: 5.0, right: 10.0)
        infoView.rightAccessoryView = checkmarkImageView
        infoView.rightAccessorySize = .mini
        infoView.titleConfig.textAlignment = .left
        infoView.subtitleConfig.textAlignment = .left
        infoView.subtitleConfig.font = .systemFont(ofSize: 12.0)
        
        let imageConfig = TPImageAccessoryConfig()
        imageConfig.shouldRenderImageWithColor = false
        imageConfig.size = .size(8)
        self.imageConfig = imageConfig
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkImageView.isHidden = !checked
    }

    func updateInfo() {
        var iconName: String?
        if let timerType = timer?.timerType {
            switch timerType {
            case .pomodoro:
                iconName = "focus_timer_bind_pomodoro_32"
            case .countdown:
                iconName = "focus_timer_bind_countdown_32"
            case .stopwatch:
                iconName = "focus_timer_bind_stopwatch_32"
            case .stepped:
                iconName = nil
            }
        }

        imageContent = .withName(iconName)
        infoView.title = timer?.timerType.title
        infoView.subtitle = timer?.timerDescription
    }
}
