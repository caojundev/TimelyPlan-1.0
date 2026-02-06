//
//  NotificationMacro.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/15.
//

import Foundation

enum AppNotificationName: String {
    
    /// 应用将要进入前台
    case willEnterForeground
    
    /// window尺寸发生变化
    case mainViewSizeDidChange
    
    var name: Notification.Name {
        let name = Notification.Name(rawValue: self.rawValue)
        return name
    }
}

