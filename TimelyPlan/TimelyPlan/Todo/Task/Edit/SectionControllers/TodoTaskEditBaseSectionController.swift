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
        self.setupSeparatorFooterItem()
        self.setSeparatorHidden(true)
    }
    
    func setSeparatorHidden(_ isHidden: Bool) {
        self.footerItem.height = isHidden ? 0.0 : 1.0
    }
}
