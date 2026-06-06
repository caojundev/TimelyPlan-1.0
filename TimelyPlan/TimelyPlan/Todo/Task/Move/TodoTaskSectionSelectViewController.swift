//
//  TodoTaskSectionSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/5.
//

import Foundation
import UIKit

class TodoTaskSectionSelectViewController: TPTableSectionsViewController {
    
    var didSelectSection: ((TodoSection) -> Void)? {
        didSet {
            selection.didSelectSection = didSelectSection
        }
    }
    
    /// 收集箱区块控制器
    private(set) lazy var inboxSectionController: TodoTaskInboxSectionSelectSectionController = {
        let controller = TodoTaskInboxSectionSelectSectionController(selection: selection)
        controller.headerItem.height = 5.0
        controller.footerItem.height = 15.0
        return controller
    }()
    
    /// 用户列表区块控制器
    private(set) lazy var userSectionController: TodoTaskUserSectionSelectSectionController = {
        let controller = TodoTaskUserSectionSelectSectionController(selection: selection)
        return controller
    }()
    
    private let selection = TodoTaskSectionSelection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tintColor = .primary
        wrapperView.isKeyboardAdjusterEnabled = true
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        sectionControllers = [inboxSectionController, userSectionController]
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}
