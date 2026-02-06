//
//  FocusStatsOverallViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/4.
//

import Foundation

class FocusStatsOverallViewController: FocusStatsBaseViewController {
    
    init(type: StatsType = .week, allowTypes: [StatsType] = StatsType.allCases, date: Date = .now) {
        super.init(type: type, allowTypes: allowTypes, date: date)
        self.canSelectDetailGroupType = true
        self.allowDetailGroupTypes = FocusStatsDetailGroupType.allCases
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
