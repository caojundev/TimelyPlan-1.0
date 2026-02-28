//
//  HabitPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation

class HabitPresenter {
    
    /// 显示设置视图控制器
    static func showSettings() {
        let vc = HabitSettingViewController(style: .insetGrouped)
        vc.showAsNavigationRoot()
    }

}
