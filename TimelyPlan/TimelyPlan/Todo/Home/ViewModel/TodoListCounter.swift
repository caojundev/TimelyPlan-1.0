//
//  TodoListCounter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/18.
//

import Foundation

class TodoListCounter {
    
    private var counts: [String: Int] = [:]
    
    func count(for item: IdentifiableItem) -> Int? {
        if let count = counts[item.identifier] {
            return count
        }
        
        return nil
    }
    
    func invalidateCount(for item: IdentifiableItem) {
        self.counts[item.identifier] = nil
    }
    
    func setCount(_ count: Int, for item: IdentifiableItem) {
        self.counts[item.identifier] = count
    }
}
