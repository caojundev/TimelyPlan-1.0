//
//  LocalNotifiableTaskFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/25.
//

import Foundation
import UserNotifications

// MARK: - 通知任务提供者协议
protocol LocalNotifiableTaskProvider: AnyObject {

    /// 异步获取任务，通过 completion 返回
    /// - Parameter completion: 任务数组的回调（在主线程或任意线程调用均可）
    func fetchNotifiableTasks(completion: @escaping ([LocalNotifiable]) -> Void)
}

protocol LocalNotifiableTaskChangeDelegate: AnyObject {
    
    /// 通知任务发生改变时触发
    func localNotifiableTaskDidChange()
}

class LocalNotifiableTaskFetcher: LocalNotifiableTaskProvider,
                                  LocalNotifiableTaskChangeDelegate{
    
    /// 通知任务发生改变
    var onTaskChanged: (() -> Void)?
    
    // 可动态注册多个 Provider
    private var providers: [LocalNotifiableTaskProvider] = []
    
    private var todoTaskProvider = TodoNotifiableTaskProvider()
    
    private var habitTaskProvider = HabitNotifiableTaskProvider()
    
    init() {
        self.todoTaskProvider.delegate = self
        self.habitTaskProvider.delegate = self
        self.providers = [self.todoTaskProvider,
                          self.habitTaskProvider]
    }
    
    func fetchNotifiableTasks(completion: @escaping([LocalNotifiable]) -> Void) {
        var results = [LocalNotifiable]()
        let group = DispatchGroup()
        for provider in providers {
            group.enter()
            provider.fetchNotifiableTasks { tasks in
                results.append(contentsOf: tasks)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
    
    // MARK: - LocalNotifiableTaskChangeDelegate
    func localNotifiableTaskDidChange() {
        onTaskChanged?()
    }
}

