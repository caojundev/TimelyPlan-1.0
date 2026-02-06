//
//  TPMultiColumnDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/24.
//

import Foundation

class TPMultiColumnDetailViewController: TPContainerViewController,
                                         TPMultiColumnProtocol {
    
    // MARK: - MTMultiColumnProtocol
    var multiColumnStatus: TPMultiColumnStatus = .hidden {
        didSet {
            updateLeftBarButtonItems()
        }
    }
    
    /// 进入全屏
    lazy var enterFullScreenButtonItem: UIBarButtonItem = {
        let image = resGetImage("fullscreen_enter_24")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .done,
                                         target: self,
                                         action: #selector(clickEnterFullScreen(_:)))
        return buttonItem
    }()
    
    /// 退出全屏
    lazy var exitFullScreenButtonItem: UIBarButtonItem = {
        let image = resGetImage("fullscreen_exit_24")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .done,
                                         target: self,
                                         action: #selector(clickExitFullScreen(_:)))
        return buttonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateLeftBarButtonItems()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateLeftBarButtonItems()
    }
    
    func updateLeftBarButtonItems() {
        self.navigationItem.leftBarButtonItems = leftBarButtonItems()
    }
    
    func leftBarButtonItems() -> [UIBarButtonItem]? {
        if UITraitCollection.isCompactMode() {
            return [self.backButtonItem]
        } else {
            let isFullScreen = multiColumnViewController?.isFullScreen ?? false
            return isFullScreen ? [exitFullScreenButtonItem] : [enterFullScreenButtonItem]
        }
    }
    
    func didClickMask(for containerView: TPColumnContainerView) {
        
    }
    
    // MARK: - Event Response
    /// 点击后退
    override func clickBack(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithLightStyle()
        multiColumnViewController?.showFirstColumn()
    }
    
    /// 详细页进入全屏
    @objc func clickEnterFullScreen(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithLightStyle()
        multiColumnViewController?.enterFullScreen()
    }

    /// 详细页退出全屏
    @objc func clickExitFullScreen(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithLightStyle()
        multiColumnViewController?.exitFullScreen()
    }
}
