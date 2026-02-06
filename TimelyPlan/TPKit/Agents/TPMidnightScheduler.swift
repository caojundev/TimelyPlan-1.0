//
//  TPMidnightScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/8.
//

import Foundation

protocol TPMidnightUpdatable: AnyObject {
    /// 处理零点更新的方法
    func updateAtMidnight()
}

class TPMidnightScheduler: WeakDelegates {
    
    static let shared = TPMidnightScheduler()
    
    /// 触发日期
    private var triggerDate: Date
    
    internal var weakDelegates = NSHashTable<AnyObject>.weakObjects()
    
    private init() {
        self.triggerDate = .now
        // 在需要监听的地方注册通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(significantTimeDidChange),
                                               name: UIApplication.significantTimeChangeNotification,
                                               object: nil)
    }
    
    deinit {
        // 在不再需要监听的地方取消注册通知
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.significantTimeChangeNotification,
                                                  object: nil)
    }
    
    // 定义事件处理函数
    @objc func appDidEnterForeground() {
        self.significantTimeDidChange() /// 手动检查一次
    }
                                        
    @objc private func significantTimeDidChange() {
        guard !triggerDate.isInSameDayAs(.now) else {
            return
        }
        
        /// 触发日期与当前日期非一天
        self.triggerDate = .now
        notifyDelegates { (updater: TPMidnightUpdatable) in
            updater.updateAtMidnight()
        }
    }
    
    // MARK: - 添加和移除更新器
    public func addUpdater(_ updater: TPMidnightUpdatable) {
        addDelegate(updater)
    }
    
    public func removeUpdater(_ updater: TPMidnightUpdatable) {
        removeDelegate(updater)
    }
}
