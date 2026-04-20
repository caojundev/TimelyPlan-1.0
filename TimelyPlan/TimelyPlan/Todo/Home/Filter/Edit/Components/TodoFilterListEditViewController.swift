//
//  TodoFilterListEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/24.
//

import Foundation
import UIKit

class TodoFilterListEditViewController: TodoBaseListSelectViewController {

    var didEndEditing: ((TodoListFilterValue?) -> Void)?

    private var selectedUserLists: [TodoList]
    
    private(set) var filterValue: TodoListFilterValue
    
    /// 收件箱区块控制器
    private lazy var inboxSectionController: TodoListSelectInboxSectionController = {
        let sectionController = TodoListSelectInboxSectionController()
        sectionController.footerItem.height = 15.0
        sectionController.delegate = self
        return sectionController
    }()
    
    init(filterValue: TodoListFilterValue?) {
        self.filterValue = filterValue ?? TodoListFilterValue()
        self.selectedUserLists = filterValue?.lists ?? []
        super.init(list: nil, allowMaxDepth: Int.max)
        
        /// 更新选中列表标识
        if self.selectedUserLists.count != self.filterValue.identifiers?.count {
            self.updateListIdentifiers()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("List")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.setupActionsBar(actions: [self.doneAction])
        self.actionsBar?.backgroundColor = .secondarySystemGroupedBackground
    }
    
    override func setupSectionControllers() {
        self.sectionControllers = [self.inboxSectionController,
                                   self.userSectionController]
    }
    
    override func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        if sectionController == userSectionController {
            if let list = userSectionController.item(at: index) as? TodoList {
                self.selectUserList(list)
            }
        } else {
            self.selectInbox()
        }

        self.adapter.updateCheckmarks()
    }
    
    override func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        if sectionController == userSectionController {
            if let list = userSectionController.item(at: index) as? TodoList {
                return self.selectedUserLists.contains(list)
            }
        } else if sectionController is TodoListSelectInboxSectionController {
            if let includeInbox = self.filterValue.includeInbox, includeInbox {
                return true
            }
        }

        return false
    }
    
    // MARK: -
    override func clickDone() {
        super.clickDone()
        if self.filterValue.isEmpty {
            self.didEndEditing?(nil)
        } else {
            self.didEndEditing?(self.filterValue)
        }
    }
    
    func selectInbox() {
        if let includeInbox = self.filterValue.includeInbox, includeInbox {
            self.filterValue.includeInbox = nil
        } else {
            self.filterValue.includeInbox = true
        }
    }
    
    func selectUserList(_ list: TodoList) {
        if selectedUserLists.contains(list) {
            selectedUserLists.remove(list)
        } else {
            selectedUserLists.append(list)
        }
        
        self.updateListIdentifiers()
    }
    
    func updateListIdentifiers() {
        let identifiers = selectedUserLists.map { $0.identifier }
        if identifiers.count > 0 {
            filterValue.identifiers = identifiers
        } else {
            filterValue.identifiers = nil
        }
    }
}
