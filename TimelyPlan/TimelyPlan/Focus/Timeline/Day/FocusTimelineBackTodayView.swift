//
//  FocusTimelineBackTodayView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//

import Foundation
import UIKit

class FocusTimelineBackTodayView: TPFlipAnimateContainerView {
    
    private let shadowRadius: CGFloat = 8.0

    lazy var todayButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.cornerRadius = .greatestFiniteMagnitude
        return button
    }()
    
    lazy var leftBackButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("arrow_up_right_fill_36")
        button.normalImageColor = .white
        button.normalBackgroundColor = Color(0xFF9500)
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self, action: #selector(clickBack(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var rightBackButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("arrow_up_backward_fill_36")
        button.normalImageColor = .white
        button.normalBackgroundColor = Color(0xFF9500)
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self,
                         action: #selector(clickBack(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    var didClickBack: ((UIButton) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        self.views = buttons()
        setActiveView(todayButton, animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        self.views = buttons()
        setActiveView(todayButton, animated: false)
    }
    
    func setupSubviews() {
        self.clipsToBounds = false
        addSubview(todayButton)
        addSubview(leftBackButton)
        addSubview(rightBackButton)
    }
    
    func buttons() -> [UIButton] {
        return [todayButton, leftBackButton, rightBackButton]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.setLayerShadow(color: Color(0x000000, 0.25),
                             offset: .zero,
                             radius: shadowRadius)
    }
    
    func showTodayButton() {
        setActiveView(todayButton, animated: true)
    }

    @objc func clickBack(_ button: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        didClickBack?(button)
    }
    
    func isTodayButtonActive() -> Bool {
        return activeView == todayButton
    }
    
    func isBackButtonActive() -> Bool {
        return activeView == leftBackButton || activeView == rightBackButton
    }
    
    func showRightBackButton() {
        setActiveView(rightBackButton, animated: true)
    }
    
    func showLeftBackButton() {
        setActiveView(leftBackButton, animated: true)
    }
}
