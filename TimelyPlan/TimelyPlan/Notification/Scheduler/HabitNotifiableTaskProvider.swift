//
//  HabitNotifiableTaskProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/25.
//

import Foundation

class HabitNotifiableTaskProvider: LocalNotifiableTaskProvider {
    
    /// 通知任务改变代理
    weak var delegate: LocalNotifiableTaskChangeDelegate?

    func fetchNotifiableTasks(completion: @escaping ([LocalNotifiable]) -> Void) {
        completion([])
    }
    
}
