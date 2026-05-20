//
//  CalendarDateButton.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/1.
//

import Foundation

class CalendarDateButton: TPDefaultButton {
    
    override var title: TextRepresentable? {
        didSet {
            sizeToFit()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.padding = .zero
        self.titleConfig.font = BOLD_BODY_FONT
        self.titleConfig.textAlignment = .center
        self.image = resGetImage("triangle_down", size: .size(3))
        self.imageConfig.size = .size(3)
        self.imagePosition = .right
    }
}

