//
//  TaskNotificationDispatcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/1.
//

import Foundation
import UIKit

// MARK: - 通知点击信息模型
struct NotificationClickInfo {
    let userInfo: [AnyHashable: Any]
    let actionIdentifier: String?
    let isAppLaunchedFromKilled: Bool
    
    init(userInfo: [AnyHashable: Any],
         actionIdentifier: String? = nil,
         isAppLaunchedFromKilled: Bool = false) {
        self.userInfo = userInfo
        self.actionIdentifier = actionIdentifier
        self.isAppLaunchedFromKilled = isAppLaunchedFromKilled
    }
}

// MARK: - 通知处理协议
protocol NotificationClickProcessor: AnyObject {
    func processNotificationClick(_ info: NotificationClickInfo)
}

// MARK: - 通知点击管理器
final class TaskNotificationDispatcher {
    
    static let shared = TaskNotificationDispatcher()
    
    // 外部处理器
    private let processor = TaskNotificationHandler()
    
    // 保存待处理的通知
    private var pendingNotificationInfo: NotificationClickInfo?
    // 标记主界面是否已准备好
    private var isMainViewReady = false
    
    
    private init() {}
    
    /// 标记主界面已准备好，并处理待处理的通知
    func markMainViewReady() {
        isMainViewReady = true
        processPendingNotificationIfNeeded()
    }
    
    /// 重置状态（用于退出登录等场景）
    func reset() {
        pendingNotificationInfo = nil
        isMainViewReady = false
    }
    
    /// 处理通知点击
    func handleNotificationClick(_ info: NotificationClickInfo) {
        guard isMainViewReady else {
            // 保存待处理的通知
            pendingNotificationInfo = info
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.processor.processNotificationClick(info)
        }
    }
    
    private func processPendingNotificationIfNeeded() {
        guard let info = pendingNotificationInfo else { return }
        pendingNotificationInfo = nil
        handleNotificationClick(info)
    }
}
