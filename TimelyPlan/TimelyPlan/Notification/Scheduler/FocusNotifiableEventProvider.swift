//
//  FocusNotifiableEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/27.
//

import Foundation
import Foundation

class FocusNotifiableEventProvider: LocalNotifiableTaskProvider {
    
    weak var delegate: LocalNotifiableTaskChangeDelegate?

    init() {
        FocusTracker.shared.scheduleNotificationHandler = { [weak self] in
            self?.delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func fetchNotifiableTasks(completion: @escaping ([LocalNotifiable]) -> Void) {
        if let event = FocusTracker.shared.event {
            completion([event])
            return
        }
        
        completion([])
    }
}
