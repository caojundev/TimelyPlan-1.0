//
//  CalendarPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation

class CalendarPresenter {
    
    static func showEventSheet() {
        let controller = CalendarEventListViewController()
        var options = SheetOptions()
        options.transitionDuration = 0.4
        options.transitionAnimationOptions = [.curveEaseInOut]
        options.shrinkPresentingViewController = false

        let sheetController = SheetViewController(controller: controller,
                                                  sizes: [.percent(0.4), .fullscreen],
                                                  options: options)
        sheetController.cornerCurve = .continuous
        sheetController.cornerRadius = 20
        sheetController.show()
    }
    
    static func showSetting() {
        let settingVC = CalendarSettingViewController(style: .insetGrouped)
        settingVC.showAsNavigationRoot()
    }
    
}
