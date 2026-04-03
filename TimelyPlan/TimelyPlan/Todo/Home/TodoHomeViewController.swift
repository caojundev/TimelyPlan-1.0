//
//  TodoHomeViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/29.
//

import Foundation
import UIKit

enum TodoHomeSection: String {
    case smartList
    case userList
    case tag
    case filter
    case trash
}

class TodoHomeViewController: TPTableViewController,
                              TPTableSectionControllersList,
                              TPSidebarContent {
    /// 侧边栏控制器
    var sidebarController: SidebarController?
    
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
    
    
    /// 智能清单区块
    lazy var smartListSectionController: TodoSmartListSectionController = {
        let types = TodoSmartListType.typesExceptTrash
        let sectionController = TodoSmartListSectionController(types: types)
        sectionController.identifier = TodoHomeSection.smartList.rawValue
        sectionController.didSelectList = { [weak self] smartList in
            self?.detailCoordinator.showDetail(for: smartList)
        }

        return sectionController
    }()
    
    /// 回收站区块
    lazy var trashSectionController: TodoSmartListSectionController = {
        let sectionController = TodoSmartListSectionController(types: [.trash])
        sectionController.identifier = TodoHomeSection.trash.rawValue
        sectionController.didSelectList = { [weak self] trashList in
            self?.detailCoordinator.showDetail(for: trashList)
        }

        return sectionController
    }()
    
    /// 用户列表区块
    lazy var userListSectionController: TodoUserListHomeSectionController = {
        let sectionController = TodoUserListHomeSectionController()
        sectionController.identifier = TodoHomeSection.userList.rawValue
        sectionController.didSelectList = { [weak self] list in
            self?.detailCoordinator.showDetail(for: list)
        }

        return sectionController
    }()
    
    /// 标签区块
    lazy var tagSectionController: TodoUserTagSectionController = {
        let sectionController = TodoUserTagSectionController()
        sectionController.identifier = TodoHomeSection.tag.rawValue
        sectionController.didSelectTag = { [weak self] tag in
            self?.detailCoordinator.showDetail(for: tag)
        }
        
        return sectionController
    }()
    
    private let userListController = TodoUserListController()
    
    private var reorder: TPTableDragInsertReorder?
    
    let detailCoordinator: TodoDetailCoordinator
    
    /// 列表区块控制器数组
    var sectionControllers: [TPTableBaseSectionController]?
    
    init(detailCoordinator: TodoDetailCoordinator) {
        self.detailCoordinator = detailCoordinator
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let sectionControllers = [smartListSectionController,
                                  userListSectionController,
                                  tagSectionController,
                                  trashSectionController]
        var displaySectionControllers = [TPTableBaseSectionController]()
        for (section, sectionController) in sectionControllers.enumerated() {
            displaySectionControllers.append(sectionController)
            if section < sectionControllers.count - 1 {
                displaySectionControllers.append(TPSeparatorSectionController())
            }
        }
        
        self.sectionControllers = displaySectionControllers
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
    
}


extension TodoHomeViewController: TPTableDragReorderDataSource {
    
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
        case .tag:
            return tagSectionController
        default:
            return nil
        }
    }
}
