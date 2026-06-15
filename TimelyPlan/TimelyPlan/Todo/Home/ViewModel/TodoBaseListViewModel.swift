//
//  TodoBaseListViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/18.
//

import Foundation

class TodoBaseListViewModel {

    let counter = TodoListCounter()
    
    func fetchUncompletedTaskCount(for item: IdentifiableItem, completion: @escaping(Int?) -> Void) {
        if let count = counter.count(for: item) {
            completion(count)
            return
        }
        
        TodoRepository.fetchUncompletedTaskCount(for: item) { count in
            self.counter.setCount(count, for: item)
            completion(count)
        }
    }
}
