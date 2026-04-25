//
//  TodoListCounter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/18.
//

import Foundation

class TodoListCounter {
    
    private var counts: [String: Int] = [:]
    
    func count(for identifier: String) -> Int? {
        if let count = counts[identifier] {
            return count
        }
        
        return nil
    }
    
    func count(for item: IdentifiableItem) -> Int? {
        if let count = counts[item.identifier] {
            return count
        }
        
        return nil
    }
    
    func setCount(_ count: Int, for identifier: String) {
        self.counts[identifier] = count
    }
    
    func setCount(_ count: Int, for item: IdentifiableItem) {
        self.counts[item.identifier] = count
    }
    
    func clear() {
        self.counts.removeAll()
    }
    
    func invalidateCount(for item: IdentifiableItem) {
        self.counts[item.identifier] = nil
    }
    
    func invalidateCount(for items: [IdentifiableItem]) {
        for item in items {
            invalidateCount(for: item)
        }
    }
}
