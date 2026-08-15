//
//  TPMinuteUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/6.
//

import Foundation
import UIKit

class TPMinuteUpdater {
    
    private var timer: DispatchSourceTimer?
    private var updateHandler: (() -> Void)?
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?
    
    // MARK: - Public Methods
    
    func start(updateHandler: @escaping () -> Void) {
        self.updateHandler = updateHandler
        
        // 如果已经在运行，只更新 handler 并立即调用
        if timer != nil {
            updateHandler()
            return
        }
        
        // 启动计时器
        startTimer()
        
        // 添加前后台切换监听
        setupAppStateObservers()
    }
    
    func stop() {
        stopTimer()
        removeAppStateObservers()
        updateHandler = nil
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        guard timer == nil else { return }
        
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: Date())
        let interval = TimeInterval(60 - seconds)
        
        // 立即调用一次，确保首次触发准确
        updateHandler?()
        
        // 创建 DispatchSourceTimer
        let newTimer = DispatchSource.makeTimerSource(queue: .main)
        newTimer.schedule(deadline: .now() + interval, repeating: 60)
        newTimer.setEventHandler { [weak self] in
            self?.updateHandler?()
        }
        
        timer = newTimer
        newTimer.resume()
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    // MARK: - App State Observers
    
    private func setupAppStateObservers() {
        // 移除旧的观察者，避免重复添加
        removeAppStateObservers()
        
        // 监听进入后台
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleEnterBackground()
        }
        
        // 监听回到前台
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleEnterForeground()
        }
    }
    
    private func removeAppStateObservers() {
        if let observer = backgroundObserver {
            NotificationCenter.default.removeObserver(observer)
            backgroundObserver = nil
        }
        
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
            foregroundObserver = nil
        }
    }
    
    // MARK: - App State Handlers
    
    private func handleEnterBackground() {
        // 进入后台时停止计时器
        stopTimer()
    }
    
    private func handleEnterForeground() {
        // 回到前台时，如果 updateHandler 存在，重新启动计时器
        guard updateHandler != nil else { return }
        
        // 确保计时器已停止
        if timer == nil {
            startTimer()
        }
    }
    
    // MARK: - Deinit
    
    deinit {
        stop()
    }
}
