//
//  TodoDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/13.
//

import Foundation
import UIKit

class TodoDetailViewController: TPMultiColumnDetailViewController {
    
    /// 标题
    override var title: String? {
        didSet {
            /// 设置标题
            self.parent?.title = title
        }
    }
    
    /// 标题视图
    private lazy var titleView: TPInfoView = {
        let view = TPInfoView()
        view.padding = .zero
        view.titleConfig.font = BOLD_BODY_FONT
        view.titleConfig.textAlignment = .center
        view.subtitleConfig.textAlignment = .center
        return view
    }()
    
    /// 更多按钮
    private lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(horizontal: 5.0)
        button.image = resGetImage("ellipsis_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    private var moreButtonSourceRect: CGRect {
        return CGRect(x: moreButton.bounds.maxX,
                      y: moreButton.bounds.maxY,
                      size: .zero)
    }
    
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: self.moreButton)
    }()
    
    private lazy var cancelEditBarButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                         target: self,
                                         action: #selector(clickCancelEdit(_:)))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: BOLD_SYSTEM_FONT
        ]
        
        buttonItem.setTitleTextAttributes(attributes, for: .normal)
        buttonItem.setTitleTextAttributes(attributes, for: .highlighted)
        return buttonItem
    }()
    
    /// 选择全部
    private lazy var selectAllBarButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(title: resGetString("Select All"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(selectAllTasks))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: BOLD_SYSTEM_FONT
        ]
        
        buttonItem.setTitleTextAttributes(attributes, for: .normal)
        buttonItem.setTitleTextAttributes(attributes, for: .highlighted)
        return buttonItem
    }()

    /// 反选全部
    private lazy var deselectAllBarButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(title: resGetString("Deselect All"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(deselectAllTasks))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: BOLD_SYSTEM_FONT
        ]
        
        buttonItem.setTitleTextAttributes(attributes, for: .normal)
        buttonItem.setTitleTextAttributes(attributes, for: .highlighted)
        return buttonItem
    }()
    
    /// 工具栏是否正在执行动画中
    private var isToolViewAnimating: Bool = false
    
    /// 工具栏高度
    private let toolViewHeight: CGFloat = 60.0
    
    /// 实际高度
    private var fitToolViewHeight: CGFloat {
        return 60.0 + view.layoutMargins.bottom
    }
    
    /// 选择模式底部任务工具栏
    private var toolView: TPMenuToolView<TodoTaskActionType>?

    /// 列表组织器
    private let organizer: TodoListOrganizer
    
    /// 列表管理器
    private let listController = TodoListController()
    
    /// 任务管理器
    private let taskController = TodoTaskController()
    
    /// 任务条目视图控制器
    private var itemsViewController: TodoTaskItemsViewController!

    /// 是否为选择模式
    private var isSelecting: Bool {
        get {
            return itemsViewController.isSelecting
        }
        
        set {
            itemsViewController.setSelecting(newValue)
        }
    }
    
    /// 列表配置
    private var listConfiguration: TodoListConfiguration
    
    /// 列表
    let list: TodoListRepresentable
    
    init(list: TodoListRepresentable) {
        self.list = list
        self.listConfiguration = .load(for: list)
        self.organizer = TodoListOrganizer(list: list)
        super.init(nibName: nil, bundle: nil)
        setupContentViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView
        updateTitle()
        updateBarButtonItems()
        
        /// 添加列表处理更新
        todo.addUpdater(self, for: .list)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isSelecting && !isToolViewAnimating {
            /// 更新工具视图
            toolView?.width = view.width
            toolView?.height = fitToolViewHeight
            toolView?.bottom = view.height
        }
    }
    
    override func contentViewFrame() -> CGRect {
        if isSelecting {
            return CGRect(x: 0.0, y: 0.0, width: view.width, height: view.height - fitToolViewHeight)
        }
        
        return view.bounds
    }

    override func didClickMask(for containerView: TPColumnContainerView) {
        /// 点击遮罩结束选择模式
        endSelecting()
    }

    // MARK: - 更新
    private func setupContentViewController() {
        let layoutType = listConfiguration.layoutType
        if layoutType == .board {
            itemsViewController = TodoTaskBoardViewController(list: list, configuration: listConfiguration)
        } else {
            itemsViewController = TodoTaskListViewController(list: list, configuration: listConfiguration)
        }
        
        itemsViewController.delegate = self
        setContentViewController(itemsViewController)
    }
    
    // MARK: - 配置更新
    func updateListConfiguration(_ configuration: TodoListConfiguration) {
        guard listConfiguration != configuration else {
            return
        }
        
        let previousConfiguration = listConfiguration
        listConfiguration = configuration

        if previousConfiguration.layoutType != listConfiguration.layoutType {
            /// 视图类型发生变化，切换内容视图控制器
            setupContentViewController()
        } else {
            /// 更新列表配置
            itemsViewController.didUpdateListConfiguration(configuration)
        }
    }
    
    // MARK: - Update
    /// 更新标题
    private func updateTitle() {
        titleView.title = list.displayTitle()
        titleView.sizeToFit()
    }
    
    /// 更新副标题
    private func updateSubtitle() {
        if isSelecting {
            let format = resGetString("%ld selected")
            let selectedCount = itemsViewController.selectedTasksCount()
            titleView.subtitle = String(format: format, selectedCount)
        } else {
            titleView.subtitle = nil
        }
        
        titleView.sizeToFit()
    }
    
    /// 更新导航栏按钮
    func updateBarButtonItems() {
        updateLeftBarButtonItems()
        if isSelecting {
            navigationItem.rightBarButtonItems = [cancelEditBarButtonItem]
        } else {
            navigationItem.rightBarButtonItems = [moreBarButtonItem]
        }
    }
    
    override func leftBarButtonItems() -> [UIBarButtonItem]? {
        guard isSelecting else {
            return super.leftBarButtonItems()
        }
        
        /// 选择模式
        let isAllTaskSelected = itemsViewController.isAllTaskSelected()
        if isAllTaskSelected {
            return [deselectAllBarButtonItem]
        } else {
            return [selectAllBarButtonItem]
        }
    }
    
    
    // MARK: - Event Response
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        itemsViewController.endEditing(animated: true)
        let options = organizer.listOptions()
        guard options.count > 0 else {
            return
        }
        
        let menuController = TodoListOptionMenuController(options: options, configuration: listConfiguration)
        menuController.didSelectMenuActionType = { option in
            self.performListMenuAction(with: option)
        }
        
        menuController.showMenu(from: moreButton, sourceRect: moreButtonSourceRect, isCovered: false)
    }

    @objc func clickCancelEdit(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithSoftStyle()
        endSelecting()
    }
    
    /// 选中所有任务
    @objc func selectAllTasks() {
        TPImpactFeedback.impactWithSoftStyle()
        itemsViewController.selectAllTasks()
    }
    
    /// 反选所有任务
    @objc func deselectAllTasks() {
        TPImpactFeedback.impactWithSoftStyle()
        itemsViewController.deselectAllTasks()
    }
    
    // MARK: - 菜单操作
    private func performListMenuAction(with option: TodoListOption) {
        switch option {
        case .select:
            beginSelecting()
        case .showCompleted:
            toggleShowCompleted()
        case .layout:
            editLayoutType()
        case .group:
            editGroup()
        case .sort:
            editSort()
        case .edit:
            editList()
        case .delete:
            deleteList()
        case .emptyTrash:
            emptyTrash()
        }
    }
    
    /// 进入选择模式
    private func beginSelecting() {
        guard !isSelecting else {
            return
        }
        
        isSelecting = true
        updateBarButtonItems()
        updateSubtitle()
        multiColumnViewController?.setUserInteractionEnabled(false, except: self)
        showToolView()
    }
    
    /// 退出选择模式
    private func endSelecting() {
        guard isSelecting else {
            return
        }
        
        isSelecting = false
        updateBarButtonItems()
        multiColumnViewController?.setUserInteractionEnabled(true)
        updateSubtitle()
        hideToolView()
    }

    /// 切换显示已完成选项
    private func toggleShowCompleted() {
        changeShowCompleted(!listConfiguration.showCompleted)
    }
    
    /// 编辑视图布局类型
    private func editLayoutType() {
        let layoutType: TodoListLayoutType
        if listConfiguration.layoutType == .list {
            layoutType = .board
        } else {
            layoutType = .list
        }
        
        changeLayoutType(layoutType)
    }
    
    /// 编辑分组类型
    private func editGroup() {
        let types = self.organizer.allowGroupTypes()
        guard types.count > 0 else {
            return
        }
        
        let menuController = TodoGroupTypeMenuController(types: types)
        menuController.selectedMenuActionType = listConfiguration.groupType
        menuController.didSelectMenuActionType = { groupType in
            self.changeGroupType(groupType)
        }
        
        menuController.showMenu(from: moreButton,
                                sourceRect: moreButtonSourceRect,
                                isCovered: false)
    }
    
    /// 编辑顺序
    private func editSort() {
        let allowSortTypes = self.organizer.allowSortTypes()
        let allowSortOrders = self.organizer.allowSortOrders()
        guard allowSortTypes.count > 1 || allowSortOrders.count > 1 else {
            return
        }
        
        let menuListVC = TodoSortMenuViewController(sort: listConfiguration.sort)
        menuListVC.allowSortTypes = allowSortTypes
        menuListVC.allowSortOrders = allowSortOrders
        menuListVC.didChangeSort = { sort in
            self.changeSort(sort)
        }

        menuListVC.show(from: moreButton, sourceRect: moreButtonSourceRect, isCovered: false)
    }
    
    /// 编辑列表
    private func editList() {
        guard let list = self.list as? TodoList else {
            return
        }
        
        listController.editList(list)
    }
    
    /// 删除列表
    private func deleteList() {
        guard let list = list as? TodoList else {
            return
        }
        
        listController.deleteList(list)
    }
    
    private func emptyTrash() {
        listController.emptyTrash()
    }
    
    // MARK: - Configuration
    private func changeShowCompleted(_ showCompleted: Bool) {
        guard listConfiguration.showCompleted != showCompleted else {
            return
        }
        
        var config = listConfiguration
        config.showCompleted = showCompleted
        updateListConfiguration(config)
    }
    
    private func changeLayoutType(_ layoutType: TodoListLayoutType) {
        guard listConfiguration.layoutType != layoutType else {
            return
        }
        
        var config = listConfiguration
        config.layoutType = layoutType
        updateListConfiguration(config)
    }
    
    private func changeGroupType(_ groupType: TodoGroupType) {
        guard listConfiguration.groupType != groupType else {
            return
        }
        
        var config = listConfiguration
        config.groupType = groupType
        updateListConfiguration(config)
    }
    
    private func changeSort(_ sort: TodoSort) {
        guard listConfiguration.sort != sort else {
            return
        }
        
        var config = listConfiguration
        config.sort = sort
        updateListConfiguration(config)
    }

    // MARK: - 任务菜单操作
    private func performTaskMenuAction(with type: TodoTaskActionType, sourceView: UIView) {
        let tasks = itemsViewController.selectedTasks()
        guard tasks.count > 0 else {
            return
        }
        
        let taskController = TodoTaskController()
        taskController.performMenuAction(with: type, for: Array(tasks), sourceView: sourceView) { [weak self] in
            self?.endSelecting()
        }
    }
    
    // MARK: - ToolView
    /// 更新工具视图
    private func updateToolView() {
        toolView?.actionTypes = taskActionTypes()
        let selectedCount = itemsViewController.selectedTasksCount()
        if selectedCount > 0 {
            toolView?.disabledTypes = nil
        } else {
            toolView?.disabledTypes = TodoTaskActionType.allCases
        }
    }
    
    /// 当前选中任务可用的任务操作类型数组
    private func taskActionTypes() -> [TodoTaskActionType] {
        var actionTypes = [TodoTaskActionType]()
        if list.listMode == .trash {
            actionTypes.append(.restore)
            actionTypes.append(.shred)
        } else {
            let selectedTasks = itemsViewController.selectedTasks()
            var isAllDone = selectedTasks.count > 0 ? true : false
            for task in selectedTasks {
                if !task.isCompleted {
                    isAllDone = false
                }
            }
            
            if isAllDone {
                actionTypes.append(.undone)
            } else {
                actionTypes.append(.done)
            }
            
            actionTypes.append(contentsOf: [.move, .date, .priority, .trash])
        }
        
        return actionTypes
    }
    
    /// 显示工具视图
    private func showToolView() {
        if let toolView = self.toolView, toolView.isDescendant(of: self.view) {
            return
        }
        
        self.isToolViewAnimating = true
        let toolViewFrame = CGRect(x: 0.0, y: view.height, width: view.width, height: fitToolViewHeight)
        let toolView = TPMenuToolView(actionTypes: taskActionTypes())
        toolView.didSelectActionType = {[weak self] actionType, sourceView in
            self?.performTaskMenuAction(with: actionType, sourceView: sourceView)
        }
        
        toolView.preferredItemsCount = 5
        toolView.disabledTypes = TodoTaskActionType.allCases
        toolView.backgroundColor = .secondarySystemBackground
        toolView.frame = toolViewFrame
        self.view.addSubview(toolView)
        self.toolView = toolView
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut) {
            self.toolView?.bottom = self.view.height
            self.updateContentViewFrame()
        } completion: { _ in
            self.isToolViewAnimating = false
        }
    }
    
    /// 隐藏工具视图
    private func hideToolView() {
        self.isToolViewAnimating = true
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseInOut) {
            self.toolView?.top = self.view.height
            self.updateContentViewFrame()
        } completion: { _ in
            self.isToolViewAnimating = false
            self.toolView?.removeFromSuperview()
            self.toolView = nil
        }
    }
}

extension TodoDetailViewController: TodoListProcessorDelegate,
                                        TodoTaskItemsViewControllerDelegate {
    
    // MARK: - TodoListProcessorDelegate
    func didUpdateTodoList(_ list: TodoList) {
        /// 更新当前显示用户列表的标题
        if self.list.listMode == .user, self.list.identifier == list.identifier {
            updateTitle()
        }
    }
    
    // MARK: - TodoTaskItemsViewControllerDelegate
    func selectedTasksDidChange() {
        updateLeftBarButtonItems()
        updateSubtitle()
        updateToolView()
    }
}
