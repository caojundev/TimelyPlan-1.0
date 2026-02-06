//
//  TPNotificationAllowAccessViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/15.
//

import Foundation
import UIKit

class TPNotificationAllowAccessViewController: TPViewController {
    
    lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2).withBold()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = resGetString("Allow Notifications")
        return label
    }()
    
    lazy var subtitleLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SYSTEM_FONT
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = resGetString("Notifications need to be enabled to receive alerts about the task or focus session.")
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("bell_badge_fill_80")
        return view
    }()
    
    lazy var allowAccessAction: TPButtonAction = {
        let action = TPButtonAction(title:  resGetString("Enable in Settings")) {  [weak self] action in
            self?.clickAllowAccess()
        }
        
        action.titleFont = BOLD_BODY_FONT
        return action
    }()
    
    deinit {
        removeWillEnterForegroundNotifiCation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addWillEnterForegroundNotifiCation()
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(imageView)
        setupActionsBar(actions: [allowAccessAction])
        let actionsView = actionsBar?.actionsView
        actionsView?.itemCornerRadius = .greatestFiniteMagnitude
        actionsView?.itemHeight = 64.0
    }
    
    func addWillEnterForegroundNotifiCation() {
        let name = AppNotificationName.willEnterForeground.name
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: name,
                                               object: nil)
    }
    
    func removeWillEnterForegroundNotifiCation() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func willEnterForeground() {
        TPNotificationService.requestAuthorization { granted in
            if granted {
                /// 已经获得授权
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let margin = 20.0
        view.padding = UIEdgeInsets(top: 30.0, left: margin, bottom: margin, right: margin)
        let layoutFrame = view.layoutFrame()
        
        titleLabel.width = layoutFrame.width
        titleLabel.sizeToFit()
        titleLabel.top = layoutFrame.minY
        titleLabel.alignHorizontalCenter()
        
        subtitleLabel.width = layoutFrame.width
        subtitleLabel.sizeToFit()
        subtitleLabel.top = titleLabel.bottom + margin
        subtitleLabel.alignHorizontalCenter()
        
        imageView.sizeToFit()
        imageView.alignHorizontalCenter()
        imageView.top = subtitleLabel.bottom + margin
        imageView.updateImage(withColor: .label)
    
        var contentHeight = view.padding.verticalLength
        contentHeight += titleLabel.height + margin
        contentHeight += subtitleLabel.height + margin
        contentHeight += imageView.height
        contentHeight += actionsBarHeight
        setContentSize(CGSize(width: kPopoverPreferredContentWidth,
                              height: contentHeight))
    }
    
    @objc func clickAllowAccess() {
        TPImpactFeedback.impactWithLightStyle()
        if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettingsURL) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}
