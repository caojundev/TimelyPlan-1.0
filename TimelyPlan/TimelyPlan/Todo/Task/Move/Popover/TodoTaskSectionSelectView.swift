//
//  TodoTaskSectionSelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/6.
//

import Foundation
import UIKit

class TodoTaskSectionSelectView: TPTableWrapperView,
                                 TPTableSectionControllersList,
                                 TPTableSectionControllerDelegate {
    
    var didSelectSection: ((TodoSection) -> Void)? {
        didSet {
            selection.didSelectSection = didSelectSection
        }
    }
    
    /// 收集箱区块控制器
    private(set) lazy var inboxSectionController: TodoTaskInboxSectionSelectSectionController = {
        let controller = TodoTaskInboxSectionSelectSectionController(selection: selection)
        controller.setupSeparatorFooterItem()
        return controller
    }()
    
    /// 用户列表区块控制器
    private(set) lazy var userSectionController: TodoTaskUserSectionSelectSectionController = {
        let controller = TodoTaskUserSectionSelectSectionController(selection: selection)
        return controller
    }()
    
    private let selection = TodoTaskSectionSelection()
    
    var sectionControllers: [TPTableBaseSectionController]?
    
    init() {
        super.init(frame: .zero, style: .grouped)
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.sectionControllers = [inboxSectionController,
                                   userSectionController]
        self.adapter.cellStyle.backgroundColor = Color(light: 0xFEFFFF, dark: 0x1E1F20)
        self.adapter.delegate = self
        self.adapter.dataSource = self
        self.adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
