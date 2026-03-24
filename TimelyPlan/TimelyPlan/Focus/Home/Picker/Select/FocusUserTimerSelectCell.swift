//
//  FocusUserTimerSelectCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/30.
//

import Foundation
import UIKit

class FocusUserTimerSelectCell: FocusUserTimerInfoCell {
    
    lazy var checkmarkImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = resGetImage("checkmark_24")
        imageView.updateImage(withColor: .primary)
        return imageView
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        infoView.rightAccessoryView = checkmarkImageView
        infoView.rightAccessorySize = .mini
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        self.checkmarkImageView.isHidden = !checked
    }
    
}
