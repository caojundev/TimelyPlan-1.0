//
//  TodoTaskSectionSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/5.
//

import Foundation
import UIKit

class TodoTaskSectionSelectViewController: TPTableSectionsViewController,
                                           TPTableSectionControllerDelegate {
    
    /// 选中列表回调
    var didSelectList: ((TodoList?) -> Void)?

    /// 选中列表
    var list: TodoListRepresentable?
    
    /// 用户列表区块控制器
    private(set) lazy var userSectionController: TodoTaskSectionSelectSectionController = {
        let sectionController = TodoTaskSectionSelectSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.wrapperView.isKeyboardAdjusterEnabled = true
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.setupSectionControllers()
        self.reloadData()
    }
    
    func setupSectionControllers() {
        sectionControllers = [userSectionController]
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        var list: TodoList? = nil
        if sectionController == userSectionController {
            list = userSectionController.item(at: index) as? TodoList
        }
        
        self.list = list
        self.adapter.updateCheckmarks()
        self.didSelectList?(list)
    }

    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        return true
//        if sectionController == userSectionController {
//            let list = userSectionController.item(at: index) as! TodoList
//            return list.identifier == self.list?.identifier
//        } else {
//            return self.list == nil
//        }
    }
}
