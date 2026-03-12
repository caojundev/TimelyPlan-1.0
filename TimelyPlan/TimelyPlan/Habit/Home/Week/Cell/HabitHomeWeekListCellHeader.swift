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
        button.image = resGetImage("ellipsis_circle_fill_24")
        button.imageConfig.color = Color(0xffffff, 0.8)
        return button
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        self.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        self.rightAccessoryView = moreButton
        self.rightAccessorySize = .mini
        self.rightAccessoryMargins = UIEdgeInsets(left: 5.0)
    }
}
