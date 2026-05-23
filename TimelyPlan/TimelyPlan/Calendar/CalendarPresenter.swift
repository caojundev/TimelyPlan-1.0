//
//  CalendarPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation

class CalendarPresenter {
    
    static func showSetting() {
        let settingVC = CalendarSettingViewController(style: .insetGrouped)
        settingVC.showAsNavigationRoot()
    }
    
}
