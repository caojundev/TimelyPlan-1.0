//
//  UIColor+Habit.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/27.
//

import Foundation
import UIKit

extension UIColor {

    /// 随机习惯任务色
    static var randomHabitTaskColor: UIColor {
        guard let color = HabitConstant.taskColors.randomElement() else {
            return .primary
        }
        
        return color
    }
}
