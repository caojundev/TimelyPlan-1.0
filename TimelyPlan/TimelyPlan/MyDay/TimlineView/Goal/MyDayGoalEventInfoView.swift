//
//  MyDayGoalEventInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/12.
//

import Foundation

class MyDayGoalEventInfoView: GoalTaskCheckInfoView {
    
    override func setupSubviews() {
        super.setupSubviews()
        self.leftView = nil
        self.leftViewSize = .zero
        self.leftViewMargins = .zero
        self.rightView = checkbox
        self.rightViewSize = checkboxSize
        self.rightViewMargins = UIEdgeInsets(left: 12.0)
        self.nameLabel.font = MyDayTimelineConfig.titleFont
        self.detailLabel.font = MyDayTimelineConfig.todoDetailFont
        self.detailLabel.numberOfLines = 2
        self.detailTopMargin = 2.0
        self.detailHeight = 24.0
        self.progressTopMargin = 6.0
        self.progressHeight = 4.0
    }
    
}
