//
//  TodoBaseListSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/4.
//

import Foundation
import UIKit

class TodoBaseListSelectViewController: TPTableSectionsViewController,
                                        TPTableSectionControllerDelegate {
    
    /// 选中列表回调
    var didSelectList: ((TodoList?) -> Void)?

    /// 允许最大深度
    let allowMaxDepth: Int
    
    /// 选中列表
    var list: TodoListRepresentable?
    
    /// 禁止选择的列表
    var disabledLists: [TodoList]? {
        get {
            return userSectionController.disabledLists
        }
        
        set {
            userSectionController.disabledLists = newValue
        }
    }
    
    /// 用户列表区块控制器
    private(set) lazy var userSectionController: TodoUserListSelectSectionController = {
        let sectionController = TodoUserListSelectSectionController(allowMaxDepth: self.allowMaxDepth)
        sectionController.delegate = self
        return sectionController
    }()
    
    init(list: TodoListRepresentable?, allowMaxDepth: Int) {
        self.list = list
        self.allowMaxDepth = allowMaxDepth
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.wrapperView.isKeyboardAdjusterEnabled = true
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.setupSectionControllers()
        self.adapter.reloadData()
    }
    
    func setupSectionControllers() {
        
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
        if sectionController == userSectionController {
            let list = userSectionController.item(at: index) as! TodoList
            return list.identifier == self.list?.identifier
        } else {
            return self.list == nil
        }
    }
}
