//
//  UIColor+Habit.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/27.
//

import Foundation
import UIKit

extension UIColor {
    
    /// 习惯颜色
    static var habitTaskColors: [UIColor] {
        return kHabitTaskColorHexValues.colors
    }

    /// 随机习惯任务色
    static var randomHabitTaskColor: UIColor {
        guard let value = kHabitTaskColorHexValues.randomElement() else {
            return .primary
        }
        
        return Color(value)
    }
}
