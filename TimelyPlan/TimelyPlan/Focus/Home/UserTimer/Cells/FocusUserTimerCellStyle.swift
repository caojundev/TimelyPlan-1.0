//
//  TPCollectionCellStyle+Focus.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/3.
//

import Foundation

class FocusUserTimerCellStyle: TPCollectionCellStyle {
    
    override init() {
        super.init()
        self.backgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundColor = .tertiarySystemGroupedBackground
        self.cornerRadius = 12.0
    }
    
}
