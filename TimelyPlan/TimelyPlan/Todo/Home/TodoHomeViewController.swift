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
                              TPSidebarContent,
                              SettingAgentObserver {
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
        view.didClickStatistic = {
            self?.clickToolbarStatistic()
        }
        
        view.didClickAdd = {
            self?.clickToolbarAdd()
        }

        return view
    }()
    
    
    /// 智能清单区块
    let smartListViewModel = TodoSmartListViewModel(types: TodoSmartListType.typesExceptTrash)
    
    lazy var smartListSectionController: TodoSmartListSectionController = {
        let sectionController = TodoSmartListSectionController(viewModel: self.smartListViewModel)
        sectionController.identifier = TodoHomeSection.smartList.rawValue
        sectionController.didSelectList = { [weak self] smartList in
            self?.detailCoordinator.showDetail(for: smartList)
        }

        return sectionController
    }()
    
    /// 用户列表区块
    var userListHeaderSectionController: TodoHomeHeaderSectionController {
        return userListSectionController.headerSectionController
    }
    
    lazy var userListViewModel: TodoHomeUserListViewModel = {
        let expansionState = TodoHomeUserListExpansionState()
        let vm = TodoHomeUserListViewModel(expansionState: expansionState)
        return vm
    }()
    
    lazy var userListSectionController: TodoUserListHomeSectionController = {
        let sectionController = TodoUserListHomeSectionController(viewModel: self.userListViewModel)
        sectionController.identifier = TodoHomeSection.userList.rawValue
        sectionController.didSelectList = { [weak self] list in
            self?.detailCoordinator.showDetail(for: list)
        }

        return sectionController
    }()
    
    /// 标签区块
    var tagHeaderSectionController: TodoHomeHeaderSectionController {
        return tagSectionController.headerSectionController
    }
    
    let tagListViewModel = TodoHomeUserTagViewModel()
    
    lazy var tagSectionController: TodoUserTagSectionController = {
        let sectionController = TodoUserTagSectionController(viewModel: self.tagListViewModel)
        sectionController.identifier = TodoHomeSection.tag.rawValue
        sectionController.didSelectTag = { [weak self] tag in
            self?.detailCoordinator.showDetail(for: tag)
        }
        
        return sectionController
    }()
    
    /// 过滤器区块
    var filterHeaderSectionController: TodoHomeHeaderSectionController {
        return filterSectionController.headerSectionController
    }
    
    let filterListViewModel = TodoHomeFilterViewModel()
    
    lazy var filterSectionController: TodoFilterSectionController = {
        let sectionController = TodoFilterSectionController(viewModel: self.filterListViewModel)
        sectionController.identifier = TodoHomeSection.filter.rawValue
        sectionController.didSelectFilter = { [weak self] filter in
            self?.detailCoordinator.showDetail(for: filter)
        }
        
        return sectionController
    }()
    
    /// 回收站区块
    let trashListViewModel = TodoSmartListViewModel(types: [.trash])
    
    lazy var trashSectionController: TodoSmartListSectionController = {
        let sectionController = TodoSmartListSectionController(viewModel: self.trashListViewModel)
        sectionController.identifier = TodoHomeSection.trash.rawValue
        sectionController.didSelectList = { [weak self] trashList in
            self?.detailCoordinator.showDetail(for: trashList)
        }

        return sectionController
    }()
    
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
        self.wrapperView.refreshHandler = { [weak self] in
            self?.handleRefresh()
        }
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.01))
        self.tableView.tableHeaderView = headerView
        self.tableView.contentInset = .zero
        
        self.setupReorder()
        self.adapter.cellStyle.backgroundColor = .systemBackground
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.adapter.reloadData()
        self.initializeData()
        
        TodoSetting.shared.addObserver(self, forKey: .homeSectionTypes)
    }
    
    private func initializeData() {
        loadData { [weak self] in
            guard let self = self else { return }
            self.wrapperView.addRefreshControl()
            self.setupSectionControllers()
            self.adapter.reloadData()
        }
    }
    
    private func loadData(completion: @escaping() -> Void) {
        let group = DispatchGroup()
        group.enter()
        self.smartListViewModel.loadLists {
            group.leave()
        }
        
        group.enter()
        self.userListViewModel.loadTopLists {
            group.leave()
        }
        
        group.enter()
        self.tagListViewModel.loadTags {
            group.leave()
        }
        
        group.enter()
        self.filterListViewModel.loadFilters {
            group.leave()
        }

        group.enter()
        self.trashListViewModel.loadLists {
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func handleRefresh() {
        loadData { [weak self] in
            guard let self = self else { return }
            self.wrapperView.endRefreshing()
        }
    }

    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        if keyName == TodoSetting.Key.homeSectionTypes.name {
            self.setupSectionControllers()
            self.adapter.performUpdate()
        }
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
        var sectionControllers: [TPTableBaseSectionController] = [smartListSectionController]
        let sectionTypes = TodoSetting.shared.orderedHomeSectionTypes
        for sectionType in sectionTypes {
            switch sectionType {
            case .list:
                sectionControllers.append(userListHeaderSectionController)
                sectionControllers.append(userListSectionController)
            case .tag:
                sectionControllers.append(tagHeaderSectionController)
                sectionControllers.append(tagSectionController)
            case .filter:
                sectionControllers.append(filterHeaderSectionController)
                sectionControllers.append(filterSectionController)
            }
        }
        
        sectionControllers.append(trashSectionController)
        self.sectionControllers = sectionControllers
    }
    
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.dataSource = self
        reorder.isEnabled = true
        self.reorder = reorder
    }
    
    // MARK: - 事件响应
    @objc private func clickSetting() {
        TPImpactFeedback.impactWithSoftStyle()
        TodoPresenter.showSettings()
    }
        
    private func clickToolbarStatistic() {
        TodoPresenter.showStepImportViewController()
    }
    
    private func clickToolbarAdd() {
        let menuController = TodoHomeAddMenuController()
        menuController.didSelectMenuActionType = { type in
            self.performAddMenuAction(with: type)
        }

        let sourceRect = CGRect(x: toolView.frame.maxX - 10.0, y: -10.0, size: .zero)
        menuController.showMenu(from: toolView,
                                sourceRect: sourceRect,
                                isCovered: false)
    }
    
    private func performAddMenuAction(with type: TodoHomeAddType) {
        switch type {
        case .list:
            let controller = TodoUserListController()
            controller.createList()
        case .tag:
            let controller = TodoTagController()
            controller.createTag()
        case .filter:
            let controller = TodoFilterController()
            controller.createFilter()
        }
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
        case .filter:
            return filterSectionController
        default:
            return nil
        }
    }
}
