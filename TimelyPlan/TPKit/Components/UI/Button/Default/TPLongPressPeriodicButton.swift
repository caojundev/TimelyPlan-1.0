//
//  TFLongPressButton.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/22.
//

import Foundation

class TPLongPressPeriodicButton: TPDefaultButton {
    
    /// 长按开始回调
    var longPressDidBegan: (() -> Void)?
    
    /// 长按结束回调
    var longPressDidEnded: (() -> Void)?
    
    /// 长按重复回调
    var longPressRepeatHandler: (() -> Void)?
    
    /// 重复时长
    var repeatDuration: TimeInterval = 0.04
    
    private var timer: Timer?
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.padding = .zero
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPress(_:)))
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let state = gesture.state
        if state == .began {
            TPImpactFeedback.impactWithSoftStyle()
            self.longPressDidBegan?()
            self.startTimer()
        } else if state == .ended || state == .cancelled {
            TPImpactFeedback.impactWithSoftStyle()
            self.longPressDidEnded?()
            self.stopTimer()
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: repeatDuration,
                                     repeats: true,
                                     block: { [weak self] (_) in
            self?.longPressRepeatHandler?()
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

