//
//  TPMinuteUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/6.
//

import Foundation

class TPMinuteUpdater {
    
    private var timer: DispatchSourceTimer?
    private var updateHandler: (() -> Void)?
    
    func start(updateHandler: @escaping () -> Void) {
        self.updateHandler = updateHandler
        
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: Date())
        let interval = TimeInterval(60 - seconds)
        
        // 立即调用一次，确保首次触发准确
        updateHandler()
        
        // 创建 DispatchSourceTimer
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now() + interval, repeating: 60)
        timer?.setEventHandler { [weak self] in
            self?.updateHandler?()
        }
        
        timer?.resume()
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        updateHandler = nil
    }
    
    deinit {
        stop()
    }
}
