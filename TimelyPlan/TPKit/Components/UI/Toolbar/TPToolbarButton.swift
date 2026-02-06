//
//  TPToolbarButton.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/4.
//

import Foundation
import UIKit

class TPToolbarButton: TPDefaultButton {

    /// 按钮条目
    let buttonItem: TPBarButtonItem

    private(set) var customView: UIView?
    
    private let isEnabledKeyPath = "isEnabled"

    deinit {
        self.buttonItem.removeObserver(self, forKeyPath: isEnabledKeyPath)
    }
    
    init(frame: CGRect = .zero, buttonItem: TPBarButtonItem) {
        self.buttonItem = buttonItem
        super.init(frame: frame)
        self.padding = .zero
        
        if buttonItem.style == .normal {
            self.preferredTappedScale = 0.8
            self.isUserInteractionEnabled = true
        } else {
            self.preferredTappedScale = 1.0
            self.isUserInteractionEnabled = false
        }
        
        self.isEnabled = buttonItem.isEnabled
        self.buttonItem.addObserver(self,
                                    forKeyPath: isEnabledKeyPath,
                                    options: [.initial, .new],
                                    context: nil)
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        if let customView = buttonItem.customView {
            self.customView = customView
            contentView.addSubview(customView)
        } else if buttonItem.style == .normal {
            titleConfig.font = BOLD_SYSTEM_FONT
            title = buttonItem.title
            image = buttonItem.image
            updateButtonColor()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let customView = customView {
            customView.sizeToFit()
            if customView.size == .zero {
                customView.frame = bounds
            }

            customView.alignCenter()
        }
    }
    
    override func didTouchUpInside() {
        super.didTouchUpInside()
        if let handler = buttonItem.handler {
            TPImpactFeedback.impactWithLightStyle()
            handler(buttonItem)
        }
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == isEnabledKeyPath {
            self.isEnabled = buttonItem.isEnabled
        }
    }
    
    // MARK: - Update Style
    func updateButtonColor() {
        imageConfig.color = buttonItem.color
        titleConfig.textColor = buttonItem.color
    }
    
}
