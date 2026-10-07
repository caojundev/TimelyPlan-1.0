//
//  CalendarPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation
import EventKit

class CalendarPresenter {
    
    /// 编辑习惯事项
    static func editHabitEvent(_ event: CalendarEvent) {
        guard let task = event.sourceItem as? HabitTask else {
            return
        }
        
        let date = event.startDate
        let periodItem = HabitRepository.getPeriodItem(for: task, on: date)
        HabitDayMenuPresenter.showSheetMenu(for: periodItem, on: date)
    }
    
    /// 编辑目标事项
    static func editGoalEvent(_ event: CalendarEvent) {
        guard let task = event.sourceItem as? GoalTask else {
            return
        }
        
        GoalPresenter.showActionViewController(for: task)
    }
    
    /// 显示倒数日事项
    static func showCountdownEvent(_ event: CalendarEvent) {
        guard let countdownEvent = event.sourceItem as? CountdownEvent else {
            return
        }
        
        CountdownPresenter.showDetail(for: countdownEvent)
    }
    
    /// 编辑待办事项
    static func editTodoEvent(_ event: CalendarEvent) {
        guard let task = event.sourceItem as? TodoTask else {
            return
        }
        
        let editVC = TodoTaskEditViewController(task: task)
        let navController = UINavigationController(rootViewController: editVC)
        if let sheet = navController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        navController.show()
    }
    
    static func previewEvent(_ event: CalendarEvent) {
        let vc = CalendarEventPreviewViewController(event: event)
        let navController = UINavigationController(rootViewController: vc)
        if let sheet = navController.sheetPresentationController {
            // 设置展示模式为自动，允许在不同高度间切换
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium()] // 半屏
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        navController.show()
    }
    
    /// 显示事项列表
    /// - Parameters:
    ///   - listOptions: 列表配置
    ///   - completion: 点击添加按钮的回调（列表已关闭）
    static func showEventList(with listOptions: CalendarEventListOptions,
                              completion: (() -> Void)? = nil) {
        let vc = CalendarEventListViewController(options: listOptions)
        vc.didClickAdd = completion
        if let sheet = vc.sheetPresentationController {
            // 设置展示模式为自动，允许在不同高度间切换
            sheet.prefersGrabberVisible = true // 显示顶部的小横条抓手
            sheet.detents = [.medium(), .large()] // medium是半屏，large是全屏幕
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true // 滚动到底部/顶部时自动展开/收起
        }
        
        vc.show()
    }
    
    static func showSetting() {
        let settingVC = CalendarSettingViewController()
        settingVC.showAsNavigationRoot()
    }
    
    static func showMoreViewController(mode: CalendarMode,
                                       selectModeHandler: @escaping(CalendarMode) -> Void) {
        guard let topVC = UIViewController.topPresented else {
            return
        }
        
        let moreVC = CalendarMoreViewController(mode: mode)
        moreVC.didSelectMode = selectModeHandler
        let navController = UINavigationController(rootViewController: moreVC)
        
        let configure = TPSlidePresentationConfigure()
        configure.automaticallyAdjustsForKeyboard = false
        configure.maskColor = Color(0x000000, 0.4)
        configure.direction = .right
        configure.cornerRadius = 0.0
        configure.presentPosition = .right
        configure.contentSize = CGSize(width: 280.0, height: .greatestFiniteMagnitude)
        configure.roundingCorners = []
        configure.edgeInsets = .zero
        topVC.slidePresent(navController,
                           configure: configure,
                           isInteractive: true,
                           animated: true,
                           completion: nil)
    }
}
