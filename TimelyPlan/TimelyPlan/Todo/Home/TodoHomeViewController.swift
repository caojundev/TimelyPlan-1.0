//
//  TodoHomeViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/29.
//

import Foundation
import UIKit

protocol TodoHomeViewControllerDelegate: AnyObject {

    /// 选中智能清单
    func homeViewController(_ viewController: TodoHomeViewController, didSelectSmartList list: TodoSmartList)
    
    /// 选中用户清单
    func homeViewController(_ viewController: TodoHomeViewController, didSelectUserList list: TodoList)
}

enum TodoHomeSection: String {
    case smartList
    case folderList
    case tagHeader
    case tag
    case filterHeader
    case filter
    case trash
}

class TodoHomeViewController: TPTableViewController,
                                TPTableSectionControllersList,
                                TFSidebarContent,
                                TPTableDragReorderDataSource {
    
    /// 代理对象
    weak var delegate: TodoHomeViewControllerDelegate?
    
    /// 侧边栏控制器
    var sidebarController: SidebarController?
    
    lazy var settingBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("todo_home_setting_24")
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickSetting))
        return item
    }()
    
    /// 底部工具栏
    lazy var toolView: TodoHomeToolView = { [weak self] in
        let view = TodoHomeToolView()
        view.didClickAddList = {
            self?.addList()
        }
        
        view.didClickAddFolder = {
            self?.addFolder()
        }
        
        return view
    }()

    var reorder: TPTableDragInsertReorder?
    
    /// 列表区块控制器数组
    var sectionControllers: [TPTableBaseSectionController]?

    /// 智能清单区块
    lazy var smartListSectionController: TodoSmartListSectionController = {
        let types = TodoSmartListType.typesExceptTrash
        let sectionController = TodoSmartListSectionController(types: types)
        sectionController.identifier = TodoHomeSection.smartList.rawValue
        return sectionController
    }()
    
    /// 回收站区块
    lazy var trashSectionController: TodoSmartListSectionController = {
        let sectionController = TodoSmartListSectionController(types: [.trash])
        sectionController.identifier = TodoHomeSection.trash.rawValue
        return sectionController
    }()
    
    /// 目录列表区块
    lazy var folderListSectionController: TodoFolderListSectionController = {
        let sectionController = TodoFolderListSectionController()
        sectionController.identifier = TodoHomeSection.folderList.rawValue
        sectionController.didSelectList = { [weak self] list in
            self?.selectUserList(list)
        }
        
        return sectionController
    }()
    
    /// 标签区块
    lazy var tagHeaderSectionController: TodoHomeExpandableSectionController = { [weak self] in
        let sectionController = TodoTagHeaderSectionController()
        sectionController.identifier = TodoHomeSection.tagHeader.rawValue
        sectionController.isExpanded = true
        sectionController.didToggleExpand = { isExpanded in
            self?.didToggleTagExpand(isExpanded)
        }
        
        sectionController.didClickAdd = { _ in
            self?.addTag()
        }
        
        return sectionController
    }()
    
    lazy var tagListSectionController: TodoTagListSectionController = {
        let sectionController = TodoTagListSectionController()
        sectionController.identifier = TodoHomeSection.tag.rawValue
        return sectionController
    }()
    
    /// 过滤器区块
    lazy var filterHeaderSectionController: TodoFilterHeaderSectionController = { [weak self] in
        let sectionController = TodoFilterHeaderSectionController()
        sectionController.identifier = TodoHomeSection.filterHeader.rawValue
        sectionController.isExpanded = true
        sectionController.didToggleExpand = { isExpanded in
            self?.didToggleFilterExpand(isExpanded)
        }
        
        sectionController.didClickAdd = { _ in
            self?.addFilter()
        }
        
        return sectionController
    }()
    
    lazy var filterListSectionController: TodoFilterListSectionController = {
        let sectionController = TodoFilterListSectionController()
        sectionController.identifier = TodoHomeSection.filter.rawValue
        return sectionController
    }()
    
    /// 目录管理器
    var folderController = TodoFolderController()
    
    /// 列表管理器
    var listController = TodoListController()
    
    /// 标签管理器
    var tagController = TodoTagController()
    
    var filterController = TodoFilterController()
    
    /// 底部工具栏高度
    private let toolViewHeight = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todo.addUpdater(self)
        setupSectionControllers()
        setupReorder()
        
        title = resGetString("Todo")
        navigationItem.leftBarButtonItem = sidebarController?.newMenuButtonItem()
        navigationItem.rightBarButtonItem = settingBarButtonItem
        view.addSubview(self.toolView)
        tableView.contentInset = .zero
        adapter.dataSource = self
        adapter.delegate = self
        adapter.cellStyle.backgroundColor = .systemBackground
        adapter.reloadData()
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
                                  TPSeparatorSectionController(),
                                  folderListSectionController,
                                  TPSeparatorSectionController(),
                                  tagHeaderSectionController,
                                  tagListSectionController,
                                  TPSeparatorSectionController(),
                                  filterHeaderSectionController,
                                  filterListSectionController,
                                  TPSeparatorSectionController(),
                                  trashSectionController]
        self.sectionControllers = sectionControllers
    }
    
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.dataSource = self
        reorder.isEnabled = true
        self.reorder = reorder
    }
    
    
    // MARK: - 事件相应
    @objc private func clickSetting() {
        let vc = TodoSettingViewController(style: .insetGrouped)
        vc.showAsNavigationRoot()
    }
    
    // MARK: - 选中行
    private func selectSmartList(_ list: TodoSmartList) {
        delegate?.homeViewController(self, didSelectSmartList: list)
    }
    
    private func selectUserList(_ list: TodoList) {
        delegate?.homeViewController(self, didSelectUserList: list)
    }
    
    private func addFolder() {
        folderController.createNewFolder()
    }
    
    private func addList() {
        listController.createNewList(in: nil)
    }
    
    private func addTag() {
        tagController.createTag()
    }
    
    private func addFilter() {
        filterController.createFilter()
    }
    
    private func didToggleTagExpand(_ isExpanded: Bool) {
        tagListSectionController.isExpanded = isExpanded
        adapter.performSectionUpdate(forSectionObject: tagListSectionController, rowAnimation: .top)
    }
    
    private func didToggleFilterExpand(_ isExpanded: Bool) {
        filterListSectionController.isExpanded = isExpanded
        adapter.performSectionUpdate(forSectionObject: filterListSectionController, rowAnimation: .top)
    }
    
    // MARK: - TPTableDragReorderDataSource
    func tableDragReorder(_ reorder: TPTableDragReorder, delegateForRowAt indexPath: IndexPath) -> TPTableDragReorderDelegate? {
        guard let sectionControllers = sectionControllers, indexPath.section < sectionControllers.count else {
            return nil
        }

        let sectionController = sectionControllers[indexPath.section]
        guard let section = TodoHomeSection(rawValue: sectionController.identifier) else {
            return nil
        }
        
        switch section {
        case .folderList:
            return folderListSectionController
        case .tag:
            return tagListSectionController
        case .filter:
            return filterListSectionController
        default:
            return nil
        }
    }
}

extension TodoHomeViewController: TodoFolderProcessorDelegate,
                                  TodoListProcessorDelegate {
    
    // MARK: - TodoFolderProcessorDelegate
    func didCreateTodoFolder(_ folder: TodoFolder) {
        let sectionObject = folderListSectionController
        adapter.performSectionUpdate(forSectionObject: sectionObject) { _ in
            self.adapter.scrollToItem(folder, inSection: sectionObject) { _ in
                self.adapter.commitFocusAnimation(for: folder)
            }
        }
    }
    
    /// 更新目录信息通知
    func didUpdateTodoFolder(_ folder: TodoFolder) {
        adapter.reloadCell(forItems: [folder],
                           inSection: folderListSectionController,
                           rowAnimation: .automatic,
                           animateFocus: true)
    }
    
    /// 删除目录时通知
    func didDeleteTodoFolder(_ folder: TodoFolder) {
        adapter.performSectionUpdate(forSectionObject: folderListSectionController)
    }
    
    /// 取消分组
    func didUngroupTodoFolder(_ folder: TodoFolder, with lists: [TodoList]) {
        adapter.performSectionUpdate(forSectionObject: folderListSectionController)
    }
    
    // MARK: - TodoListProcessorDelegate
        func didCreateTodoList(_ list: TodoList) {
            let sectionObject = folderListSectionController
            adapter.performSectionUpdate(forSectionObject: sectionObject) { _ in
                self.adapter.scrollToItem(list, inSection: sectionObject) { _ in
                    self.adapter.commitFocusAnimation(for: list)
                }
            }
        }
        
        func didUpdateTodoList(_ list: TodoList) {
            adapter.reloadCell(forItems: [list],
                               inSection: folderListSectionController,
                               rowAnimation: .automatic,
                               animateFocus: true)
        }
        
        func didMoveTodoList(_ list: TodoList, from folder: TodoFolder?) {
            var items: [ListDiffable] = [list]
            if let folder = folder {
                items.append(folder)
            }
            
            if let currentFolder = list.folder {
                items.append(currentFolder)
            }
            
            adapter.performSectionUpdate(forSectionObject: folderListSectionController)
            adapter.reloadCell(forItems: items, with: .none)
        }
        
        func didDeleteTodoList(_ list: TodoList, from folder: TodoFolder?) {
            adapter.performSectionUpdate(forSectionObject: folderListSectionController)
            
            var items: [ListDiffable] = [TodoSmartList.trash]
            if let folder = folder {
                items.append(folder)
            }
            
            adapter.reloadCell(forItems: items, with: .none)
        }
        
        func didReorderTodoList(_ list: TodoList) {
            
        }
}

// MARK: - TodoTaskProcessorDelegate
extension TodoHomeViewController: TodoTaskProcessorDelegate {
    
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask]) {
        refreshItemsForUpdatedTasks(tasks)
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask]) {
        refreshItemsForCreatedTasks(repeatTasks)
    }
    
    func didCreateTodoTask(_ task: TodoTask, in list: TodoList?) {
        refreshItemsForCreatedTasks([task])
    }

    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        refreshItemsForUpdatedTasks(tasks)
    }

    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        refreshItemsForUpdatedTasks(tasks)
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        /// 刷新废纸篓
        adapter.reloadCell(forItems: [TodoSmartList.trash], with: .none)
    }
    
    func didUpdateTodoTask(with infos: [TodoTaskChangeInfo]) {
        refreshItemsForUpdatedTasks(with: infos)
    }
    
    func didMoveTodoTasks(with infos: [TodoTaskChangeInfo]) {
        refreshItemsForMoveInfos(infos)
    }
    
    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int) {
        
    }
}

// MARK: - Refresh
extension TodoHomeViewController {
    
    /// 刷新新创建任务对应的单元格
    func refreshItemsForCreatedTasks(_ tasks: [TodoTask]) {
        let itemsToUpdate = itemsToUpdateForCreatedTasks(tasks)
        adapter.reloadCell(forItems: itemsToUpdate, with: .none, focusAnimated: true)
    }
    
    func refreshItemsForUpdatedTasks(_ tasks: [TodoTask]) {
        let itemsToUpdate = itemsToUpdateForUpdatedTasks(tasks)
        adapter.reloadCell(forItems: itemsToUpdate, with: .none, focusAnimated: true)
    }
    
    func refreshItemsForUpdatedTasks(with infos: [TodoTaskChangeInfo]) {
        let itemsToUpdate = itemsToUpdateForUpdatedTasks(with: infos)
        adapter.reloadCell(forItems: itemsToUpdate, with: .none, focusAnimated: true)
    }
    
    func refreshItemsForMoveInfos(_ infos: [TodoTaskChangeInfo]) {
        let itemsToUpdate = itemsToUpdateForMoveInfos(infos)
        adapter.reloadCell(forItems: itemsToUpdate, with: .none, focusAnimated: true)
    }
    
    private func itemsToUpdateForCreatedTasks(_ tasks: [TodoTask]) -> [ListDiffable] {
        /// 更新列表
        var listsToUpdate = Set<NSObject>()
        for task in tasks {
            if let list = task.list {
                /// 任务清单
                listsToUpdate.insert(list)
            } else {
                /// 收件箱
                listsToUpdate.insert(TodoSmartList.inbox)
            }
        }

        let tagsToUpdate = tasks.allTags()
        let itemsToUpdate = listsToUpdate.union(tagsToUpdate)
        return Array(itemsToUpdate)
    }
   
    private func itemsToUpdateForUpdatedTasks(with infos: [TodoTaskChangeInfo]) -> [ListDiffable] {
        var userLists = Set<NSObject>()
        var tags = Set<TodoTag>()
        for info in infos {
            let task = info.task
            if let list = task.list {
                userLists.insert(list)
            }
            
            if case let .tag(oldValue, newValue) = info.change {
                if let oldValue = oldValue {
                    tags.formUnion(oldValue)
                }
                
                if let newValue = newValue {
                    tags.formUnion(newValue)
                }
            }
        }
        
        let smartLists = TodoSmartList.allLists
        let items = userLists.union(smartLists).union(tags)
        return Array(items)
    }
    
    /// 获取更新任务对应的需要更新的列表数组
    private func itemsToUpdateForUpdatedTasks(_ tasks: [TodoTask]) -> [ListDiffable] {
        var userLists = Set<NSObject>()
        for task in tasks {
            if let list = task.list {
                userLists.insert(list)
            }
        }

        let smartLists = TodoSmartList.allLists
        let tags = tasks.allTags()
        let items = userLists.union(smartLists).union(tags)
        return Array(items)
    }
    
    private func itemsToUpdateForMoveInfos(_ infos: [TodoTaskChangeInfo]) -> [ListDiffable] {
        var lists = Set<NSObject>()
        for info in infos {
            if case let .list(oldList, newList) = info.change {
                if let fromList = oldList {
                    lists.insert(fromList)
                } else {
                    lists.insert(TodoSmartList.inbox)
                }
                
                if let toList = newList {
                    lists.insert(toList)
                } else {
                    lists.insert(TodoSmartList.inbox)
                }
            }
        }
        
        return Array(lists)
    }
}
