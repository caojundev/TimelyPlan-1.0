//
//  FocusFloatingTrackingView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/17.
//

import Foundation
import UIKit

class FocusFloatingTrackingView: TPAnimatedContainerView,
                                      FocusTrackerDelegate {

    var state: FocusTrackerState?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Color(0x232323)
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 8
        
        self.updateContentView(animated: true)
        FocusTracker.shared.addDelegate(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 更新内容视图
    func updateContentView(animated: Bool) {
        let state = FocusTracker.shared.state
        updateContentView(with: state, animated: animated)
    }
    
    func updateContentView(with state: FocusTrackerState, animated: Bool) {
        guard self.state != state else {
            return
        }
        
        self.state = state
        let view: UIView
        switch state {
        case .waiting:
            view = UIView()
        case .running:
            let timerType = FocusTracker.shared.eventTimerType
            view = FocusFloatingTimerView.timerView(with: timerType)
        case .ended:
            view = FocusFloatingEndView()
        }
        
        setContentView(view, animateStyle: .none)
    }
    
    // MARK: - FocusTrackerDelegate
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState) {
        updateContentView(animated: true)
    }
}
