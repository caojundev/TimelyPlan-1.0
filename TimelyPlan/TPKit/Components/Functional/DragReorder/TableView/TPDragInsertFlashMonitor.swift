//
//  TPDragInsertFlashMonitor.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/28.
//

import Foundation

class TPDragInsertFlashMonitor {
    
    /// 回调
    var completion: ((IndexPath) -> Void)?
    
    /// 时间间隔
    var interval = 0.8
    
    /// 计时器
    private var timer: Timer?
    
    /// 当前计时器对应的索引
    private(set) var indexPath: IndexPath?
    
    func start(at indexPath: IndexPath) {
        guard self.indexPath != indexPath else {
            return
        }
        
        self.stop()
        self.indexPath = indexPath
        self.timer = Timer.scheduledTimer(withTimeInterval: interval,
                                     repeats: false,
                                     block: { [weak self] (_) in
            self?.timerHandler()
        })
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        stop()
        indexPath = nil
    }
    
    func resetIfNeeded(at touchIndexPath: IndexPath) {
        guard indexPath != touchIndexPath else {
            return
        }
        
        reset()
    }
    
    private func timerHandler() {
        self.timer = nil
        if let indexPath = indexPath {
            completion?(indexPath)
        }
    }
}
