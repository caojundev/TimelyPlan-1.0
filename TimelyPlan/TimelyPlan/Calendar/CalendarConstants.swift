//
//  CalendarConstants.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/9.
//

import Foundation
import UIKit

struct CalendarConstant {
    
    static let separatorLineWidth = 0.6
    
    static let horizontalSeparatorColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.2)
    
    static let verticalSeparatorColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.1)
    
    static let dividerColor = UIColor.lightGray
    
    static let allDayBackgroundColor = UIColor.systemGray6
    
    
    static var allDayMaxStripLinesCount = 5
    
    static var eventViewCornerRadius = 4.0
    
    /// 非全天事项最小高度
    static var minimumTimedEventViewHeight = 20.0
}


struct CalendarStyleConfig {
    
    static let separatorColor = UIColor.orangePrimary
//    Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.2)

}
