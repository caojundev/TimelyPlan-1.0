//
//  TodoParentListSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation
import UIKit

class TodoParentListSelectViewController: TodoBaseListSelectViewController {

    /// 无父清单区块控制器
    private lazy var noParentSectionController: TodoParentListNoneSectionController = {
        let sectionController = TodoParentListNoneSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    override func setupSectionControllers() {
        self.sectionControllers = [self.noParentSectionController,
                                   self.userSectionController]
    }
}
