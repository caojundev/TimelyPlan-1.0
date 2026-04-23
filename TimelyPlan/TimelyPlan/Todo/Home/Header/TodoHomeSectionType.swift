//
//  TodoHomeSectionType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/23.
//

import Foundation

enum TodoHomeSectionType: String, Codable, TPMenuRepresentable {
    case list
    case tag
    case filter
    
    var title: String {
        switch self {
        case .list:
            return resGetString("List")
        case .tag:
            return resGetString("Tag")
        case .filter:
            return resGetString("Filter")
        }
    }
    
    var iconName: String? {
        switch self {
        case .list:
            return "todo_list_24"
        case .tag:
            return "todo_home_tag_24"
        case .filter:
            return "todo_home_filter_24"
        }
    }
    
    var iconColor: UIColor {
        switch self {
        case .list:
            return .primary
        case .tag:
            return .orangePrimary
        case .filter:
            return .purplePrimary
        }
    }
}
