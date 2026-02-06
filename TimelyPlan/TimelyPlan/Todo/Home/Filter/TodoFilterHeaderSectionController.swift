//
//  TodoFilterHeaderSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation

class TodoFilterHeaderSectionController: TodoHomeExpandableSectionController {
    
    override init() {
        super.init()
        self.cellItem.imageName = "todo_home_filter_24"
        self.cellItem.title = resGetString("Filters")
    }
}
