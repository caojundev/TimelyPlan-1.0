//
//  Quadrant.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/26.
//

import Foundation
import UIKit

// 象限枚举
enum Quadrant: String, Codable, Equatable, TPMenuRepresentable {
    case urgentImportant
    case notUrgentImportant
    case urgentNotImportant
    case notUrgentNotImportant
  
    /// 标题
    var title: String {
        switch self {
        case .urgentImportant:
            return resGetString("Urgent & Important")
        case .notUrgentImportant:
            return resGetString("Not Urgent & Important")
        case .urgentNotImportant:
            return resGetString("Urgent & Not Important")
        case .notUrgentNotImportant:
            return resGetString("Not Urgent & Not Important")
        }
    }
    
    var color: UIColor {
        switch self {
        case .urgentImportant:
            return Color(0xFF4C4C)
        case .notUrgentImportant:
            return Color(0xFFB940)
        case .urgentNotImportant:
            return Color(0x2F9CFC)
        case .notUrgentNotImportant:
            return Color(0x2FC660)
        }
    }
    
    var iconName: String? {
        switch self {
        case .urgentImportant:
            return "quadrant_circle_I"
        case .notUrgentImportant:
            return "quadrant_circle_II"
        case .urgentNotImportant:
            return "quadrant_circle_III"
        case .notUrgentNotImportant:
            return "quadrant_circle_IV"
        }
    }
    
    /// 占位图名称
    var placeholderImageName: String {
        let iconName: String
        switch self {
        case .urgentImportant:
            iconName = "quadrant_I_32"
        case .notUrgentImportant:
            iconName = "quadrant_II_32"
        case .urgentNotImportant:
            iconName = "quadrant_III_32"
        case .notUrgentNotImportant:
            iconName = "quadrant_IV_32"
        }
        
        return iconName
    }
    
    /// 象限对应的默认优先级
    var defaultPriority: TodoTaskPriority {
        let priority: TodoTaskPriority
        switch self {
        case .urgentImportant:
            priority = .high
        case .notUrgentImportant:
            priority = .medium
        case .urgentNotImportant:
            priority = .low
        case .notUrgentNotImportant:
            priority = .none
        }
        
        return priority
    }
 
}
