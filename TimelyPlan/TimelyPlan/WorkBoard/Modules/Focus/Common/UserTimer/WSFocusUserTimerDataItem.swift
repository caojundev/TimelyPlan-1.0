//
//  WSFocusUserTimerDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 用户计时器组件中的单个计时器数据。
class WSFocusUserTimerDataItem: NSObject {
    
    /// 计时器唯一标识。交互时据此读取最新的计时器，避免持有过期快照
    let timerIdentifier: String
    
    /// 计时器名称
    let title: String
    
    /// 计时器描述，展示配置信息
    let subtitle: String?
    
    /// 计时器颜色
    let color: UIColor
    
    /// 计时器类型
    let timerType: FocusTimerType
    
    init(timerIdentifier: String,
         title: String,
         subtitle: String?,
         color: UIColor,
         timerType: FocusTimerType) {
        self.timerIdentifier = timerIdentifier
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.timerType = timerType
        super.init()
    }
    
    /// 由用户计时器生成展示数据
    convenience init(timer: FocusTimer) {
        let timerType = timer.timerType
        var subtitleComponents = [String]()
        if timerType == .stopwatch || timerType == .stepped {
            subtitleComponents.append(timerType.title)
        }
        
        if let detail = timer.config.detail {
            subtitleComponents.append(detail)
        }
        
        let subtitle = subtitleComponents.joined(separator: "•")
        self.init(timerIdentifier: timer.identifier,
                  title: timer.displayName,
                  subtitle: subtitle,
                  color: timer.color,
                  timerType: timerType)
    }
}

// MARK: - 列表数据条目

/// 用户计时器组件的列表数据。
class WSFocusUserTimersDataItem: NSObject, WSPluginDataItem {
    
    /// 待展示的计时器，按展示顺序排列
    let items: [WSFocusUserTimerDataItem]
    
    init(items: [WSFocusUserTimerDataItem]) {
        self.items = items
        super.init()
    }
    
    /// 由用户计时器列表生成展示数据
    convenience init(timers: [FocusTimer]) {
        self.init(items: timers.map { WSFocusUserTimerDataItem(timer: $0) })
    }
}
