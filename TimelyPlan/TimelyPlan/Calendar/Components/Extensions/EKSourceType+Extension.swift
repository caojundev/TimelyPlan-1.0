//
//  EKSourceType+Extension.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation
import EventKit

extension EKSourceType {
    
    /// 面向用户的友好显示名称
    var displayName: String? {
        switch self {
        case .local:
            return resGetString("Local Calendar")
        case .exchange:
            return resGetString("Exchange Calendar")
        case .calDAV:
            return resGetString("iCloud")
        case .subscribed:
            return resGetString("Subscribed Calendar")
        case .birthdays:
            return resGetString("Birthdays Calendar")
        default:
            return nil
        }
    }
}
