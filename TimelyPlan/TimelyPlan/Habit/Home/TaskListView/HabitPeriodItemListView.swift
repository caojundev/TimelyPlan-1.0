//
//  HabitPeriodItemListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation
import UIKit

class HabitPeriodItemListView: TPGroupCollectionView {
    
    func revealTask(_ task: HabitTask, autoScroll: Bool = true) {
        let indexPath = adapter.findIndexPath { item in
            guard let item = item as? HabitPeriodItem else {
                return false
            }
            
            return task.identifier == item.habitTask.identifier
        }
        
        if let indexPath = indexPath {
            let periodItem = adapter.item(at: indexPath)
            revealItem(periodItem, autoScroll: autoScroll)
        }
    }
    
}
