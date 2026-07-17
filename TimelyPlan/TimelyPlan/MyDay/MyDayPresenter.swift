//
//  MyDayPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/17.
//

import Foundation
import UIKit

class MyDayPresenter {
    
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
