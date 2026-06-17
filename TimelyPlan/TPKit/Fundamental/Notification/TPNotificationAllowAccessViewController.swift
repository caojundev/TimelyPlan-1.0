//
//  TPNotificationAllowAccessViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/15.
//

import Foundation
import UIKit

class TPNotificationAllowAccessViewController: TPViewController {
    
    let deniedView = TPPermissionDeniedView()
    
    deinit {
        removeWillEnterForegroundNotifiCation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deniedView.titleLabel.text = resGetString("Allow Notifications")
        deniedView.subtitleLabel.text = resGetString("Notifications need to be enabled to receive alerts about the task or focus session.")
        deniedView.imageView.image = resGetImage("bell_badge_fill_80")
        view.addSubview(deniedView)
        addWillEnterForegroundNotifiCation()
    }
    
    func addWillEnterForegroundNotifiCation() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: .notificationWillEnterForeground,
                                               object: nil)
    }
    
    func removeWillEnterForegroundNotifiCation() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func willEnterForeground() {
        TPNotificationService.isAuthorized{ authorized in
            if authorized {
                /// 已经获得授权
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        deniedView.width = view.width
        deniedView.sizeToFit()
        let contentSize = CGSize(width: kPopoverPreferredContentWidth,
                                 height: deniedView.height)
        setContentSize(contentSize)
    }
}
