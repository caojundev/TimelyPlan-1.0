//
//  TodoParentListSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation

class TodoParentListSelectViewController: TPTableSectionsViewController,
                                            TPTableSectionControllerDelegate {
    
    /// 选中列表回调
    var didSelectList: ((TodoList?) -> Void)?

    /// 允许最大深度
    let allowMaxDepth: Int
    
    /// 选中列表
    var list: TodoList?
    
    /// 禁止选择的列表
    var disabledLists: [TodoList]? {
        get {
            return userSectionController.disabledLists
        }
        
        set {
            userSectionController.disabledLists = newValue
        }
    }
    
    /// 当前显示的顶层列表
    var topLists: [TodoList] {
        return userSectionController.lists.topLists
    }
    
    /// 无父清单区块控制器
    private lazy var noParentSectionController: TodoParentListNoneSectionController = {
        let sectionController = TodoParentListNoneSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    /// 用户列表区块控制器
    private lazy var userSectionController: TodoUserListSelectSectionController = {
        let sectionController = TodoUserListSelectSectionController(allowMaxDepth: self.allowMaxDepth)
        sectionController.delegate = self
        return sectionController
    }()
    
    init(list: TodoList?, allowMaxDepth: Int) {
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
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.sectionControllers = [noParentSectionController,
                                   userSectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.reloadData()
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
            return self.list?.isEqual(list) ?? false
        } else {
            /// 无父列表
            return self.list == nil
        }
    }
}
