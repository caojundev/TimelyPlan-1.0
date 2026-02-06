//
//  FocusFloatingTimerActionView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/25.
//

import Foundation
import UIKit

class FocusFloatingTimerActionView: FocusEventActionView {
    
    override var tintColor: UIColor! {
        didSet {
            self.buttonColor = tintColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = .zero
        self.minimumItemWidth = 30.0
        self.maximumItemWidth = 30.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    var timerInfo: FocusTimerInfo?
    
    /// 更新操作按钮
    func updateActionTypes(with timerInfo: FocusTimerInfo) {
        self.timerInfo = timerInfo
        updateActionTypes()
    }
    
    func updateActionTypes() {
        guard let timerInfo = timerInfo else {
            self.actionTypes = []
            return
        }

        var actionTypes = timerInfo.eventActionTypes()
        let isNextButtonHidden = focus.setting.getIsFloatingTimerNextButtonHidden()
        if isNextButtonHidden {
            let _ = actionTypes.remove(.next)
        }
        
        self.actionTypes = actionTypes
    }
}
