//
//  TodoTaskEditBaseSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/10.
//

import Foundation

class TodoTaskEditBaseSectionController: TPTableItemSectionController {
    
    let interactor: TodoTaskEditInteractor
    
    var task: TodoTask {
        return interactor.task
    }
    
    init(interactor: TodoTaskEditInteractor) {
        self.interactor = interactor
        super.init()
    }
}
