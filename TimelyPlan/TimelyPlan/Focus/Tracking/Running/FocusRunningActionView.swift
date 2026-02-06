//
//  FocusTimerActionsView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/6.
//

import Foundation
import UIKit

class FocusRunningActionView: UIView {
    
    var didSelectActionType: ((FocusEventActionType) -> Void)?
    
    /// 动作类型
    var actionTypes: [FocusEventActionType] = [] {
        didSet {
            if actionTypes != oldValue {
                setupButtons()
            }
        }
    }
    
    /// 开始按钮
    lazy var startButton: TPDefaultButton = {
        let button = button(withType: .start,
                            imageName: "timer_start_24",
                            title: resGetString("Start"))
        return button
    }()
    
    /// 暂停按钮
    lazy var pauseButton: TPDefaultButton = {
        let button = button(withType: .pause,
                            imageName: "timer_pause_24",
                            title: resGetString("Pause"))
        return button
    }()
    
    /// 继续按钮
    lazy var resumeButton: TPDefaultButton = {
        let button = button(withType: .resume,
                            imageName: "timer_start_24",
                            title: resGetString("Continue"))
        return button
    }()
    
    lazy var nextButton: TPDefaultButton = {
        let button = button(withType: .next,
                            imageName: "timer_next_24",
                            title: resGetString("Next"))
        button.normalBackgroundColor = .clear
        button.selectedBackgroundColor = .clear
        button.borderWidth = 2.5
        let color = resGetColor(.title)
        button.normalBorderColor = color
        button.titleConfig.textColor = color
        button.imageConfig.color = color
        return button
    }()
    
    private var buttons: [TPDefaultButton] = []
    private let buttonMargin = 15.0
    private let buttonSize = CGSize(width: 120.0, height: 50.0)
    private let buttonPadding = UIEdgeInsets(left: 10.0, right: 10.0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if buttons.count == 0 {
            return
        }
    
        let leftMargin = (layoutFrame().width - CGFloat(buttons.count) * (buttonSize.width + buttonMargin) + buttonMargin) / 2.0
        let layoutFrame = bounds
        var left = layoutFrame.minX + leftMargin
        for button in buttons {
            button.padding = buttonPadding
            button.size = buttonSize
            button.left = left
            button.alignVerticalCenter()
            button.cornerRadius = .greatestFiniteMagnitude
            left = button.right + buttonMargin
        }
    }
    
    private func setupButtons() {
        for button in self.buttons {
            button.removeFromSuperview()
        }
        
        var buttons = [TPDefaultButton]()
        for actionType in actionTypes {
            switch actionType {
            case .start:
                buttons.append(startButton)
            case .pause:
                buttons.append(pauseButton)
            case .resume:
                buttons.append(resumeButton)
            case .next:
                buttons.append(nextButton)
            }
        }
        
        for button in buttons {
            addSubview(button)
        }
        
        self.buttons = buttons
        setNeedsLayout()
    }
    
    private func button(withType type: FocusEventActionType,
                        imageName: String?,
                        title: String?) -> TPDefaultButton {
        let color: UIColor = Color(light: 0xFFFFFF, dark: 0x000000, alpha: 0.8)
        let button = TPDefaultButton()
        button.tag = type.rawValue
        button.normalBackgroundColor = resGetColor(.title)
        button.title = title
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.titleConfig.textColor = color
        button.imageConfig.color = color
        button.imagePosition = .left
        if let imageName = imageName {
            button.image = resGetImage(imageName)
        }
        
        button.addTarget(self,
                         action: #selector(clickButton(_:)),
                         for: .touchUpInside)
        return button
    }
    
    // MARK: - Event Response
    @objc func clickButton(_ button: UIButton) {
        guard let type = FocusEventActionType(rawValue: button.tag) else {
            return
        }
        
        TPImpactFeedback.impactWithMediumStyle()
        didSelectActionType?(type)
    }
}
