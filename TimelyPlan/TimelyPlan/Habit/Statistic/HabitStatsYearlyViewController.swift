//
//  HabitStatsYearlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitStatsYearlyViewController: HabitStatsContentViewController {
  
    init(task: HabitTask, date: Date = .now) {
        super.init(task: task, type: .year, date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping ([TPCollectionBaseSectionController]) -> Void) {
        completion([])
    }
}
