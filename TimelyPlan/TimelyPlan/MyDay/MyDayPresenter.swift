//
//  MyDayPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/17.
//

import Foundation
import UIKit

class MyDayPresenter {
    
    /// 编辑习惯事项
    static func editHabitEvent(_ event: MyDayEvent) {
        guard let task = event.sourceItem as? HabitTask else {
            return
        }
        
        let date = event.startDate
        HabitRepository.fetchPeriodItem(for: task.identifier, on: date) { periodItem in
            guard let periodItem = periodItem else {
                return
            }

            HabitDayMenuPresenter.showSheetMenu(for: periodItem, on: date)
        }
    }
        
    static func editFocusEvent(_ event: MyDayEvent) {
        guard let timer = event.sourceItem as? FocusTimer else {
            return
        }
        
        FocusPresenter.showSheetMenu(for: timer)
    }
    
    /// 编辑待办事项
    static func editTodoEvent(_ event: MyDayEvent) {
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
        
    // 显示设置
    static func showSetting() {
        guard let topVC = UIViewController.topPresented else {
            return
        }
        
        let settingVC = MyDaySettingViewController()
        let navController = UINavigationController(rootViewController: settingVC)
        
        let configure = TPSlidePresentationConfigure()
        configure.automaticallyAdjustsForKeyboard = false
        configure.maskColor = Color(0x000000, 0.4)
        configure.direction = .right
        configure.cornerRadius = 0.0
        configure.presentPosition = .right
        configure.contentSize = CGSize(width: 300.0, height: .greatestFiniteMagnitude)
        configure.roundingCorners = []
        configure.edgeInsets = .zero
        topVC.slidePresent(navController,
                           configure: configure,
                           isInteractive: true,
                           animated: true,
                           completion: nil)
    }
}
