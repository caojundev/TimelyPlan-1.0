//
//  FocusTimerTopbar.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/5.
//

import Foundation
import UIKit

class FocusRunningTopbar: TPToolbar {
    
    /// 点击最小化
    var didClickMinimal: (() -> Void)?
    
    /// 点击翻页时钟
    var didClickFlipClock: (() -> Void)?
    
    /// 最小化
    lazy var minimalButtonItem: TPBarButtonItem = {
        let image = resGetImage("focus_running_minimal_24")
        let item = TPBarButtonItem(image: image) {[weak self] _ in
            self?.clickMinimal()
        }
        
        return item
    }()
    
    /// 翻页时钟
    let clockView = FocusRunningDayFlipView()
    
    lazy var flipClockButtonItem: TPBarButtonItem = {
        let item = TPBarButtonItem(customView: clockView) {[weak self] _ in
            self?.clickFlipClock()
        }
        
        return item
    }()
    
    /// 屏幕常亮已打卡，点击关闭
    lazy var screenAlwaysOnEnabledButtonItem: TPBarButtonItem = {
        let image = resGetImage("focus_running_screenAlwaysOnEnabled_24")
        let item = TPBarButtonItem(image: image) {[weak self] _ in
            self?.disableScreenAlwaysOn()
        }
        
        return item
    }()
    
    /// 屏幕常亮已关闭，点击打开
    lazy var screenAlwaysOnDisabledButtonItem: TPBarButtonItem = {
        let image = resGetImage("focus_running_screenAlwaysOnDisabled_24")
        let item = TPBarButtonItem(image: image) {[weak self] _ in
            self?.enableScreenAlwaysOn()
        }
        
        return item
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.updateButtonItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateButtonItems() {
        var buttonItems = [TPBarButtonItem]()
        buttonItems.append(minimalButtonItem)
        buttonItems.append(.flexibleSpaceButtonItem)
        buttonItems.append(flipClockButtonItem)
        buttonItems.append(.flexibleSpaceButtonItem)
        let isAlwaysOn = UIApplication.shared.isIdleTimerDisabled
        if isAlwaysOn {
            buttonItems.append(screenAlwaysOnEnabledButtonItem)
        } else {
            buttonItems.append(screenAlwaysOnDisabledButtonItem)
        }
        
        self.buttonItems = buttonItems
    }
    
    // MARK: - Event Response
    @objc func clickMinimal() {
        TPImpactFeedback.impactWithSoftStyle()
        didClickMinimal?()
    }

    @objc func clickFlipClock() {
        TPImpactFeedback.impactWithSoftStyle()
        didClickFlipClock?()
    }
    
    @objc func enableScreenAlwaysOn() {
        TPImpactFeedback.impactWithSoftStyle()
        screenAlwaysOnChanged(true)
        updateButtonItems()
    }
    
    @objc func disableScreenAlwaysOn() {
        TPImpactFeedback.impactWithSoftStyle()
        screenAlwaysOnChanged(false)
        updateButtonItems()
    }
    
    private func screenAlwaysOnChanged(_ isEnabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = isEnabled
        let feedbackText: String
        if isEnabled {
            feedbackText = resGetString("Screen always on enabled")
        } else {
            feedbackText = resGetString("Screen always on disabled")
        }
        
        TPFeedbackQueue.common.postFeedback(text: feedbackText, position: .top)
    }
    
}
