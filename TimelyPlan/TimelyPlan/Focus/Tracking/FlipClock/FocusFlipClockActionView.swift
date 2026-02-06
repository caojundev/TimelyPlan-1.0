//
//  FocusFlipClockActionView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/19.
//

import Foundation

class FocusFlipClockActionView: FocusEventActionView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.minimumItemWidth = 80.0
        self.startButtonItem.image = resGetImage("timer_start_circle_fill_32")
        self.pauseButtonItem.image = resGetImage("timer_pause_circle_fill_32")
        self.resumeButtonItem.image = resGetImage("timer_start_circle_fill_32")
        self.nextButtonItem.image  = resGetImage("timer_next_circle_fill_32")
        self.buttonColor = Color(0xFFFFFF, 0.8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
