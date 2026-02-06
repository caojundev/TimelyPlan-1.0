//
//  TPPeriodicCountingView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/7.
//

import Foundation

class TPPeriodicCountingView: UIView {

    /// 开始计数
    var didStartCounting: (() -> Void)?
    
    /// 结束计时
    var didStopCounting: ((_ isCompleted: Bool) -> Void)?
    
    /// 重复处理回调
    var repeatHandler: ((_ interval: TimeInterval) -> Void)?
    
    /// 重复间隔
    var repeatInterval: TimeInterval = 0.01
    
    /// 目标时长
    var targetInterval: TimeInterval = 1.0
    
    /// 是否正在计数中
    private(set) var isCounting: Bool = false
    
    private var timer: Timer?
    
    private var startDate: Date?
    
    
    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startCounting()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopCounting()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopCounting()
    }
    
    private func startCounting() {
        if isCounting {
            return
        }
    
        TPImpactFeedback.impactWithLightStyle()
        isCounting = true
        startDate = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01,
                                     repeats: true,
                                     block: { [weak self] (_) in
            self?.handleTimer()
        })
        
        didStartCounting?()
    }
    
    func stopCounting() {
        guard isCounting, let date = self.startDate else {
            return
        }
        
        timer?.invalidate()
        timer = nil
        isCounting = false
        startDate = nil
        
        let elapsedInterval = Date().timeIntervalSince(date)
        let isCompleted = elapsedInterval >= targetInterval
        didStopCounting?(isCompleted)
    }
    
    private func handleTimer() {
        guard let date = startDate else {
            repeatHandler?(0.0)
            return
        }
        
        let elapsedInterval = Date().timeIntervalSince(date)
        repeatHandler?(elapsedInterval)
        
        if elapsedInterval >= targetInterval {
            stopCounting()
        }
    }

}
