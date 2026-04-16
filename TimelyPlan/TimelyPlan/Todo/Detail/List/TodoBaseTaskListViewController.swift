//
//  TodoBaseTaskListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

class TodoBaseTaskListViewController: UIViewController,
                                      TodoDetailContent,
                                      TodoTaskListViewDelegate {
 
    weak var selectionDelegate: TodoTaskListSelectionDelegate?

    /// 更多按钮
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: self.moreButton)
    }()
    
    private lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(horizontal: 5.0)
        button.image = resGetImage("ellipsis_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
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
    
    /// 选择模式底部任务工具栏
    private var toolView: TPMenuToolView<TodoTaskActionType>?

    /// 工具栏高度
    private var toolViewHeight: CGFloat {
        return 60.0 + view.layoutMargins.bottom
    }
    
    private var expansionState = TodoTaskGroupExpansionState()
    
    /// 列表视图
    private lazy var listView: TodoTaskListView = {
        let view = TodoTaskListView(frame: view.bounds, style: .insetGrouped)
        view.expansionState = self.expansionState
        view.delegate = self
        return view
    }()
    
    /// 添加视图按钮
    private let addViewSize = CGSize(width: 50.0, height: 50.0)
    
    /// 添加视图边界间距
    private let addViewMargins = UIEdgeInsets(top: 0.0,
                                              left: 0.0,
                                              bottom: 10.0,
                                              right: 20.0)
    /// 添加视图
    private var addView: TPAddView?
    
    /// 任务快速添加控制器
    private lazy var quickAddManager: TodoTaskQuickAddManager = {
        return TodoTaskQuickAddManager(containerViewController: self)
    }()
    
    
    private var reorder: TPTableDragInsertReorder?
    
    let taskController = TodoTaskController()
    
    let interactor: TodoListInteractor
    
    init(interactor: TodoListInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        self.setupAddView()
        self.setupReorder()
        self.listView.reloadData()
        self.interactor.didChangeGroups = { [weak self] in
            self?.listView.performUpdate()
        }
    }

    private(set) var isFirstAppearance = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppearance {
            isFirstAppearance = false
            self.interactor.loadGroups()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateListViewFrame()
        
        let layoutFrame = view.safeAreaFrame()
        if let addView = addView {
            addView.size = addViewSize
            addView.bottom = layoutFrame.maxY - addViewMargins.bottom
            addView.right = layoutFrame.maxX - addViewMargins.right
        }
        
        self.updateAddView()
        
        if let toolView = toolView {
            /// 更新工具视图
            toolView.width = view.width
            toolView.height = toolViewHeight
            toolView.bottom = view.height
        }
    }
    
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: self.listView.tableView)
        reorder.delegate = self
        reorder.isEnabled = true
        self.reorder = reorder
    }
    
    func updateListViewFrame() {
        self.listView.frame = listViewFrame()
    }
    
    func listViewFrame() -> CGRect {
        if let toolView = toolView {
            return CGRect(x: 0.0,
                          y: 0.0,
                          width: view.width,
                          height: view.height - toolView.height)
        }

        return view.bounds
    }


    // MARK: - TodoDetailContent
    var navigationTitle: TextRepresentable? {
        return self.interactor.title()
    }
    
    var navigationSubtitle: TextRepresentable? {
        guard isSelecting else {
            return nil
        }
        
        let format = resGetString("%ld selected")
        let selectedCount = listView.selectedTasks.count
        return String(format: format, selectedCount)
    }
    
    var navigationLeftBarButtonItems: [UIBarButtonItem]? {
        guard isSelecting else {
            return nil
        }
        
        if listView.isAllTasksSelected() {
            return [deselectAllBarButtonItem]
        } else {
            return [selectAllBarButtonItem]
        }
    }
    
    var navigationRightBarButtonItems: [UIBarButtonItem]? {
        if isSelecting {
            return [cancelEditBarButtonItem]
        } else {
            return [moreBarButtonItem]
        }
    }
    
    
    // MARK: - AddView
    private func setupAddView() {
        let configuration = self.interactor.configuration
        if configuration.canAddTask() {
            let addView = TPAddView()
            addView.normalBackgroundColor = configuration.addButtonBackColor()
            addView.didClickAdd = { [weak self] _ in
                self?.clickAdd()
            }
           
            self.addView = addView
            self.view.addSubview(addView)
        }
    }
    
    private func updateAddView() {
        guard let addView = addView else {
            return
        }

        addView.isHidden = listView.isSelecting
    }
    
    // MARK: - 列表选项
    func selectListOption(_ option: TodoListOption) {
        switch option {
        case .select:
            self.setSelecting(true)
        case .layout:
            self.toggleLayout()
        case .showCompleted:
            self.interactor.toggleShowCompleted()
        default:
            break
        }
    }
    
    /// 切换布局
    private func toggleLayout() {
        var layoutType = self.interactor.layoutType()
        if layoutType == .list {
            layoutType = .board
        }
        
        self.interactor.setLayoutType(layoutType)
    }

    private func selectGroupType(_ groupType: TodoGroupType) {
        self.interactor.setGroupType(groupType)
    }
    
    private func selectSortType(_ sortType: TodoSortType) {
        self.interactor.setSortType(sortType)
    }
    
    private func selectSortOrder(_ sortOrder: TodoSortOrder) {
        self.interactor.setSortOrder(sortOrder)
    }
    
    // MARK: - Event Response
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        self.endEditing(animated: true)
        guard let config = self.interactor.listOptionConfig() else {
            return
        }

        let optionMenuController = TodoListOptionMenuController(config: config)
        optionMenuController.didSelectListOption = { option in
            self.selectListOption(option)
        }
        
        optionMenuController.didSelectGroupType = { groupType in
            self.selectGroupType(groupType)
        }
        
        optionMenuController.didSelectSortType = { sortType in
            self.selectSortType(sortType)
        }
        
        optionMenuController.didSelectSortOrder = { sortOrder in
            self.selectSortOrder(sortOrder)
        }
        
        let menuItems = optionMenuController.menuItems()
        let menuController = TPLevelMenuViewController(menuItems: menuItems)
        let sourceRect = CGRect(x: moreButton.bounds.maxX,
                                y: moreButton.bounds.maxY,
                                size: .zero)
        menuController.show(from: moreButton, sourceRect: sourceRect, isCovered: false)
    }
    
    /// 点击添加
    func clickAdd() {
        TPImpactFeedback.impactWithLightStyle()
        let task = self.interactor.configuration.quickAddTask()
        quickAddManager.show(with: task)
    }
    
    @objc func clickCancelEdit(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithSoftStyle()
        setSelecting(false)
    }
    
    /// 选中所有任务
    @objc func selectAllTasks() {
        TPImpactFeedback.impactWithSoftStyle()
        listView.selectAllTasks()
    }
    
    /// 反选所有任务
    @objc func deselectAllTasks() {
        TPImpactFeedback.impactWithSoftStyle()
        listView.deselectAllTasks()
    }
    
    // MARK: - Editing & Selecting
    func endEditing(animated: Bool) {
        listView.endEditing(animated: animated)
    }
    
    var isSelecting: Bool {
        return listView.isSelecting
    }
    
    func endSelecting() {
        setSelecting(false)
    }
    
    private func setSelecting(_ isSelecting: Bool) {
        guard listView.isSelecting != isSelecting else {
            return
        }
        
        listView.setSelecting(isSelecting)
        updateAddView()
        if isSelecting {
            showToolView()
        } else {
            hideToolView()
        }
        
        selectionDelegate?.todoTaskListDidUpdateSelectionMode(to: isSelecting)
    }
    
    // MARK: - ToolView
    
    /// 显示工具视图
    private func showToolView() {
        if let toolView = self.toolView, toolView.isDescendant(of: self.view) {
            return
        }
        
        let toolView = createToolView()
        toolView.frame = CGRect(x: 0.0, y: view.height, width: view.width, height: toolViewHeight)
        self.view.addSubview(toolView)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut) {
            toolView.bottom = self.view.height
        } completion: { _ in
            self.toolView = toolView
            self.updateListViewFrame()
        }
    }
    
    /// 隐藏工具视图
    private func hideToolView() {
        guard let toolView = self.toolView else {
            return
        }
        
        self.toolView = nil
        updateListViewFrame()
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut) {
            toolView.top = self.view.height
        } completion: { _ in
            toolView.removeFromSuperview()
        }
    }
    
    /// 更新工具视图
    private func updateToolView() {
        guard let toolView = toolView else {
            return
        }

        let selectedTasks = self.listView.selectedTasks
        toolView.actionTypes = self.interactor.taskActionTypes(for: selectedTasks)
        if selectedTasks.count > 0 {
            toolView.disabledTypes = nil
        } else {
            toolView.disabledTypes = TodoTaskActionType.allCases
        }
    }
    
    private func createToolView() -> TPMenuToolView<TodoTaskActionType> {
        let selectedTasks = self.listView.selectedTasks
        let actionTypes = self.interactor.taskActionTypes(for: selectedTasks)
        let toolView = TPMenuToolView(actionTypes: actionTypes)
        toolView.backgroundColor = .secondarySystemGroupedBackground
        toolView.preferredItemsCount = 4
        toolView.disabledTypes = TodoTaskActionType.allCases
        toolView.addSeparator(position: .top)
        toolView.didSelectActionType = {[weak self] actionType, sourceView in
            self?.performTaskMenuAction(with: actionType, sourceView: sourceView)
        }
        
        return toolView
    }
    
    // MARK: - 任务菜单操作
    private func performTaskMenuAction(with type: TodoTaskActionType, sourceView: UIView) {
        let tasks = self.listView.selectedTasks
        guard tasks.count > 0 else {
            return
        }
    
        self.taskController.performMenuAction(with: type,
                                              for: Array(tasks),
                                              sourceView: sourceView) { [weak self] in
            self?.endSelecting()
        }
    }
    
    // MARK: - TodoTaskListViewDelegate
    
    func todoGroupsForTaskListView(_ listView: TodoTaskListView) -> [TodoGroup]? {
        return self.interactor.groups
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didSelectTask task: TodoTask) {
        taskController.editTask(task)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didClickCheckboxForTask task: TodoTask) {
        taskController.clickCheckbox(for: task) {isCompleted, execution in
            listView.setCompleted(isCompleted, for: task) { _ in
                execution?()
            }
        } progressHandler: { progress, execution in
            listView.setProgress(progress, for: task) {  _ in
                execution?()
            }
        }
    }
    
    func todoTaskListViewDidChangeSelectedTasks(_ listView: TodoTaskListView) {
        self.selectionDelegate?.todoTaskListDidUpdateSelectedTasks(to: listView.selectedTasks)
        self.updateToolView()
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, leadingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        /// 我的一天
        let myDayAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            self.taskController.setAddToMyDay(!task.isAddedToMyDay, for: task)
            completion(true)
        }
        
        var myDayImage: UIImage?
        if task.isAddedToMyDay {
            myDayImage = resGetImage("todo_task_action_removeFromMyDay_24@2x")
            myDayAction.backgroundColor = Color(0x757575)
        } else {
            myDayImage = resGetImage("todo_task_action_addToMyDay_24@2x")
            myDayAction.backgroundColor = .greenPrimary
        }
        
        myDayAction.image = myDayImage?.withTintColor(.white)
        actions.append(myDayAction)
        
        /// 专注
        let focusAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            self.taskController.quickStartFocus(for: task)
            completion(true)
        }
        
        focusAction.backgroundColor = Color(0x5856D6)
        focusAction.image = resGetImage("focus_24")?.withTintColor(.white)
        actions.append(focusAction)
        
        /// 移动
        let moveAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            self.taskController.moveTask(task)
            completion(true)
        }
        
        moveAction.backgroundColor = Color(0xFF9B00)
        moveAction.image = resGetImage("todo_task_action_move_24")?.withTintColor(.white)
        actions.append(moveAction)
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, trailingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        
        /// 计划
        let scheduleAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            self.taskController.editSchedule(for: task)
            completion(true)
        }

        scheduleAction.backgroundColor = .primary
        scheduleAction.image = resGetImage("todo_task_action_date_24")?.withTintColor(.white)
        
        /// 废纸篓
        let trashAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.taskController.moveTaskToTrash(task)
            completion(true)
        }
                            
        trashAction.image = resGetImage("todo_task_action_trash_24")?.withTintColor(.white)
        actions = [trashAction, scheduleAction]
        return UISwipeActionsConfiguration(actions: actions)
    }
}

// MARK: - 任务排序
extension TodoBaseTaskListViewController: TPTableDragInsertReorderDelegate {
    
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard interactor is TodoUserListInteractor || interactor is TodoInboxListInteractor else {
            return false
        }
        
        return self.interactor.sort.type == .manually
    }

    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canInsertRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        return true
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard targetIndexPath.row != sourceIndexPath.row,
                let sourceTask = listView.task(at: sourceIndexPath),
                let targetTask = listView.task(at: targetIndexPath) else {
            return nil
        }
    
        var insertPosition: TodoTaskInsertPosition = .after
        if sourceIndexPath.row > targetIndexPath.row {
            insertPosition = .before
        }
        
        var list: TodoList?
        if let userListInteractor = self.interactor as? TodoUserListInteractor {
            list = userListInteractor.list
        }
        
        listView.moveRow(at: sourceIndexPath, to: targetIndexPath)
        todo.reorderTask(sourceTask, postion: insertPosition, targetTask: targetTask, in: list)
        return targetIndexPath
    }
}


