//
//  CalendarPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation

class CalendarPresenter {
    
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
    
    static func showMoreViewController() {
        guard let topVC = UIViewController.topPresented else {
            return
        }
        
        let moreVC = CalendarMoreViewController(style: .grouped)
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
