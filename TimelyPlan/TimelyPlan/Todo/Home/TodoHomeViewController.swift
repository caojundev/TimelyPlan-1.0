//
//  TodoHomeViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/29.
//

import Foundation
import UIKit

protocol TodoHomeViewControllerDelegate: AnyObject {

//    /// 选中智能清单
//    func homeViewController(_ viewController: TodoHomeViewController, didSelectSmartList list: TodoSmartList)
//
//    /// 选中用户清单
//    func homeViewController(_ viewController: TodoHomeViewController, didSelectUserList list: TodoList)
}

enum TodoHomeSection: String {
    case smartList
    case userList
    case tag
    case filter
    case trash
}

class TodoHomeViewController: TPTableViewController,
                              TPTableSectionControllersList,
                              TPSidebarContent,
                              TPTableDragReorderDataSource {
    /// 侧边栏控制器
    var sidebarController: SidebarController?
    
    /// 代理对象
    weak var delegate: TodoHomeViewControllerDelegate?
    
    /// 设置
    lazy var settingBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("todo_home_setting_24")
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickSetting))
        return item
    }()
    
    /// 底部工具栏
    private let toolViewHeight = 60.0
    lazy var toolView: TodoHomeToolView = { [weak self] in
        let view = TodoHomeToolView()
        view.didClickAddList = {
            self?.createList()
        }

        return view
    }()
    
    /// 用户列表区块
    lazy var userListSectionController: TodoUserListHomeSectionController = {
        let sectionController = TodoUserListHomeSectionController()
        sectionController.identifier = TodoHomeSection.userList.rawValue
//        sectionController.didSelectList = { [weak self] list in
//            self?.selectUserList(list)
//        }
//
        return sectionController
    }()
    
    private let userListController = TodoUserListController()
    
    private var reorder: TPTableDragInsertReorder?
    
    /// 列表区块控制器数组
    var sectionControllers: [TPTableBaseSectionController]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Todo")
        self.navigationItem.leftBarButtonItem = sidebarController?.newMenuButtonItem()
        self.navigationItem.rightBarButtonItem = settingBarButtonItem
        self.view.addSubview(self.toolView)
        self.tableView.contentInset = .zero
        self.setupSectionControllers()
        self.setupReorder()
        self.adapter.cellStyle.backgroundColor = .systemBackground
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.adapter.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeAreaFrame()
        toolView.width = view.width
        toolView.height = toolViewHeight
        toolView.bottom = layoutFrame.maxY
        wrapperView.height = layoutFrame.height - toolViewHeight
    }
    
    override func themeDidChange() {
        super.themeDidChange()
        toolView.backgroundColor = .systemBackground
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - 初始化
    private func setupSectionControllers() {
        self.sectionControllers = [userListSectionController]
    }
    
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.dataSource = self
        reorder.isEnabled = true
        self.reorder = reorder
    }
    
    // MARK: - 事件相应
    @objc private func clickSetting() {
        
    }
        
    private func createList() {
        userListController.createList()
    }
    
    // MARK: - TPTableDragReorderDataSource
    func tableDragReorder(_ reorder: TPTableDragReorder, delegateForRowAt indexPath: IndexPath) -> TPTableDragReorderDelegate? {
        guard let sectionControllers = self.sectionControllers,
                indexPath.section < sectionControllers.count else {
            return nil
        }

        let sectionController = sectionControllers[indexPath.section]
        guard let section = TodoHomeSection(rawValue: sectionController.identifier) else {
            return nil
        }
        
        switch section {
        case .userList:
            return userListSectionController
        default:
            return nil
        }
    }
}
