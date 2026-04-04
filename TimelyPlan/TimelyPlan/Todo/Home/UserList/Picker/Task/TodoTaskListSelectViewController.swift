//
//  TodoTaskListSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/4.
//

import Foundation
import UIKit

class TodoTaskListSelectViewController: TodoBaseListSelectViewController {

    /// 收件箱区块控制器
    private lazy var inboxSectionController: TodoListSelectInboxSectionController = {
        let sectionController = TodoListSelectInboxSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    override func setupSectionControllers() {
        self.sectionControllers = [self.inboxSectionController,
                                   self.userSectionController]
    }
    
    override func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        var list: TodoListRepresentable? = nil
        if sectionController == userSectionController {
            list = userSectionController.item(at: index) as? TodoList
        } else if sectionController is TodoListSelectInboxSectionController {
            list = TodoSmartList.inbox
        }

        return self.list?.isEqual(list) ?? false
    }
}
