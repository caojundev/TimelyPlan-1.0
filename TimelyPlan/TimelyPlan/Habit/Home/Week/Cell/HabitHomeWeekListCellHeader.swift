//
//  TaskCellHeader.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/5.
//

import Foundation
import UIKit

class HabitHomeWeekListCellHeader: TPImageInfoView {

    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = Color(0xffffff, 0.8)
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        self.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        self.rightAccessoryView = moreButton
        self.rightAccessorySize = .mini
        self.rightAccessoryMargins = UIEdgeInsets(horizontal: 5.0)
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {

    }
}
