//
//  CalendarPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation

class CalendarPresenter {
    
    /// 编辑本地待办事项
    static func editLocalEvent(_ event: CalendarEvent) {
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
    
    static func showEventList(with listOptions: CalendarEventListOptions) {
        let vc = CalendarEventListViewController(options: listOptions)
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
