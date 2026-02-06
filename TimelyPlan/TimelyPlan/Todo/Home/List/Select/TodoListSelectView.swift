//
//  TodoListSelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation

class TodoListSelectView: TPTableWrapperView,
                          TPTableSectionControllersList,
                          TPTableSectionControllerDelegate {
    
    var sectionControllers: [TPTableBaseSectionController]?
    
    /// 当前选中列表
    var list: TodoListRepresentable?

    /// 选中列表回调
    var didSelectList: ((TodoListRepresentable?) -> Void)?
    
    /// 收件箱区块控制器
    private lazy var inboxSectionController: TodoListSelectInboxSectionController = {
        let sectionController = TodoListSelectInboxSectionController()
        sectionController.delegate = self
        sectionController.didSelectInbox = { [weak self] in
            self?.selectList(nil)
        }
        
        return sectionController
    }()
    
    /// 用户列表区块控制器
    private lazy var userSectionController: TodoListSelectUserSectionController = {
        let sectionController = TodoListSelectUserSectionController()
        sectionController.delegate = self
        sectionController.didSelectList = { [weak self] list in
            self?.selectList(list)
        }
        
        return sectionController
    }()

    init() {
        super.init(frame: .zero, style: .grouped)
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.sectionControllers = [inboxSectionController, userSectionController]
        self.adapter.cellStyle.backgroundColor = Color(light: 0xFEFFFF, dark: 0x1E1F20)
        self.adapter.delegate = self
        self.adapter.dataSource = self
        self.adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 选中清单
    func selectList(_ list: TodoList?) {
        self.list = list
        adapter.updateCheckmarks()
        didSelectList?(list)
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        var list: TodoListRepresentable? = nil
        if sectionController == userSectionController {
            list = userSectionController.item(at: index) as? TodoList
        } else if sectionController is TodoListSelectInboxSectionController {
            list = TodoSmartList.inbox
        }

        return self.list?.isEqual(list) ?? false
    }
}
