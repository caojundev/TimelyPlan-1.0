//
//  WeekdayPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation

/// 星期选择器控制器
class WeekdayPickerController {
    
    /**
     * 显示星期选择菜单
     *
     * - Parameters:
     *   - currentWeekday: 当前选中的星期
     *   - allowWeekdays: 允许选择的星期列表，默认为周日和周一
     *   - sourceView: 弹出菜单的源视图
     *   - popoverPosition: 弹出菜单位置，默认为.bottomLeft
     *   - permittedPositions: 允许的弹出位置列表，默认包含底部左右两个位置
     *   - isSourceViewCovered: 源视图是否被覆盖，默认为false
     *   - animated: 是否使用动画，默认为true
     *   - completion: 选择完成后的回调闭包
     */
    static func show(currentWeekday: Weekday,
                     allowWeekdays: [Weekday] = [.sunday, .monday],
                     from sourceView: UIView,
                     popoverPosition: TPPopoverPosition = .bottomLeft,
                     permittedPositions: [TPPopoverPosition] = [.bottomLeft, .topLeft],
                     isSourceViewCovered: Bool = false,
                     animated: Bool = true,
                     completion: ((Weekday) -> Void)? = nil) {
        let menuVC = TPMenuListViewController()
        let menuItem = TPMenuItem.item(with: allowWeekdays,
                                       updater: { weekday, menuAction in
            menuAction.handleBeforeDismiss = true
            menuAction.isChecked = currentWeekday == weekday
        })
        
        menuVC.menuItems = [menuItem]
        menuVC.didSelectMenuAction = { menuAction in
            guard let weekday: Weekday = menuAction.actionType(), allowWeekdays.contains(weekday) else {
                return
            }
            
            completion?(weekday)
        }
        
        menuVC.popoverShow(from: sourceView,
                           sourceRect: sourceView.bounds,
                           isSourceViewCovered: isSourceViewCovered,
                           preferredPosition: popoverPosition,
                           permittedPositions: permittedPositions,
                           animated: animated,
                           completion: nil)
    }
}
