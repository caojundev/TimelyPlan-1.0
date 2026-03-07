//
//  HabitManageListTaskCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation

class HabitManageListTaskCell: HabitTaskListDefaultInfoCell {
    
    var task: HabitTask? {
        didSet {
            updateInfo(with: task)
        }
    }
}
