//
//  TodoTagHeaderSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/13.
//

import Foundation

class TodoTagHeaderSectionController: TodoHomeExpandableSectionController {
    
    override init() {
        super.init()
        self.cellItem.imageName = "todo_home_tag_24"
        self.cellItem.title = resGetString("Tags")
    }
}
