//
//  TodoImportTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/30.
//

import Foundation

struct TodoImportTask {
    
    let name: String
    
    let isCompleted: Bool
    
    let steps: [TodoStep]?
    
    init(step: TodoStep) {
        self.name = step.content
        self.isCompleted = step.isCompleted
        self.steps = step.subSteps
    }
}
