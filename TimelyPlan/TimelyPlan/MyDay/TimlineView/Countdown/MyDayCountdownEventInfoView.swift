//
//  MyDayCountdownEventInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/23.
//

import Foundation
import UIKit

class MyDayCountdownEventInfoView: TPInfoView {
    
    override func setupSubviews() {
        super.setupSubviews()
        self.padding = .zero
        self.titleConfig.font = MyDayTimelineConfig.titleFont
        self.titleConfig.textAlignment = .left
        self.titleConfig.numberOfLines = 1
        self.subtitleConfig.font = MyDayTimelineConfig.subtitleFont
        self.subtitleConfig.textAlignment = .left
        self.subtitleConfig.numberOfLines = 1
        self.subtitleLabel.alpha = 0.6
    }
    
}
