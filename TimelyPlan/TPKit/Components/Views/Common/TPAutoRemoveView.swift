//
//  TPAutoRemoveView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/22.
//

import Foundation
import UIKit

class TPAutoRemoveView: UIView {
    
    private var timer: Timer?
    private var autoRemoveDuration: TimeInterval = 3.0
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: autoRemoveDuration,
                                     repeats: false,
                                     block: { [weak self] (_) in
            guard let self = self else {
                return
            }
            
            self.removeFromSuperview()
            self.superview?.animateLayout(withDuration: 0.2)
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func restartTimer() {
        timer?.invalidate()
        startTimer()
    }
    
    /// 特定时长后自动移除
    func autoRemove(withDuration duration: TimeInterval) {
        stopTimer()
        autoRemoveDuration = duration
        startTimer()
    }
    
    /// 从父视图移除移除
    func remove() {
        self.stopTimer()
        self.removeFromSuperview()
    }
    
}
