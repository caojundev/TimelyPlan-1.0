//
//  TodoDetailContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/3.
//

import Foundation

class TodoDetailContentViewController: UIViewController, TodoDetailContent {
    
    // MARK: - Properties
    
    weak var selectionDelegate: TodoTaskListSelectionDelegate?
    
    let taskController = TodoTaskController()
    
    let interactor: TodoListInteractor
    
    // MARK: - ToolView Properties
    
    /// 选择模式底部任务工具栏
    var toolView: TPMenuToolView<TodoTaskActionType>?

    /// 工具栏高度
    let toolViewContentHeight = 60.0
    var toolViewFitHeight: CGFloat {
        return toolViewContentHeight + view.layoutMargins.bottom
    }
    
    
    // MARK: - Initialization
    
    init(interactor: TodoListInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateListViewFrame()
//        self.updateContentInset()
        
        let layoutFrame = view.safeAreaFrame()
//        if let addView = addView {
//            addView.size = addViewSize
//            addView.bottom = layoutFrame.maxY - addViewMargins.bottom
//            addView.right = layoutFrame.maxX - addViewMargins.right
//        }
//
//        self.updateAddView()
        
        if let toolView = toolView {
            /// 更新工具视图
            toolView.width = view.width
            toolView.height = toolViewFitHeight
            toolView.bottom = view.height
        }
    }
    
    /// 子类可以重写此方法以更新列表视图框架
    func updateListViewFrame() {
        
    }
    
    /// 列表视图当前 frame
    func listViewFrame() -> CGRect {
        if let toolView = toolView {
            return CGRect(x: 0.0, y: 0.0, width: view.width, height: view.height - toolView.height)
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
        let selectedCount = getSelectedTasks().count
        return String(format: format, selectedCount)
    }
    
    var navigationLeftBarButtonItems: [UIBarButtonItem]? {
        guard isSelecting else {
            return nil
        }
        
        if isAllTasksSelected() {
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
    
    func endSelecting() {
        setSelecting(false)
    }
    
    // MARK: - Selection Management
    
    var isSelecting: Bool {
        return getIsSelecting()
    }
    
    func endEditing(animated: Bool = true) {
        performEndEditing(animated: animated)
    }
    
    /// 子类需要重写此方法以提供实际的选择状态
    func getIsSelecting() -> Bool {
        return false
    }
    
    /// 子类需要重写此方法以执行实际的结束编辑操作
    func performEndEditing(animated: Bool) {
        // 默认实现为空
    }
    
    /// 子类需要重写此方法来设置选择状态
    func setSelecting(_ isSelecting: Bool) {
//        updateAddView()
        if isSelecting {
            showToolView()
        } else {
            hideToolView()
        }
        
        selectionDelegate?.todoTaskListDidUpdateSelectionMode(to: isSelecting)
    }
    
    // MARK: - ToolView Management
    
    /// 显示工具视图
    func showToolView() {
        if let toolView = self.toolView, toolView.isDescendant(of: self.view) {
            return
        }
        
        let toolView = createToolView()
        toolView.frame = CGRect(x: 0.0, y: view.height, width: view.width, height: toolViewFitHeight)
        self.view.addSubview(toolView)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut) {
            toolView.bottom = self.view.height
        } completion: { _ in
            self.toolView = toolView
            self.updateListViewFrame()
        }
    }
    
    /// 隐藏工具视图
    func hideToolView() {
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
    func updateToolView() {
        guard let toolView = toolView else {
            return
        }

        let selectedTasks = getSelectedTasks()
        toolView.actionTypes = self.interactor.taskActionTypes(for: selectedTasks)
        if selectedTasks.count > 0 {
            toolView.disabledTypes = nil
        } else {
            toolView.disabledTypes = TodoTaskActionType.allCases
        }
    }
    
    /// 创建工具视图
    func createToolView() -> TPMenuToolView<TodoTaskActionType> {
        let selectedTasks = getSelectedTasks()
        let actionTypes = self.interactor.taskActionTypes(for: selectedTasks)
        let toolView = TPMenuToolView(actionTypes: actionTypes)
        toolView.backgroundColor = .secondarySystemGroupedBackground
        toolView.preferredItemsCount = 5
        toolView.disabledTypes = TodoTaskActionType.allCases
        toolView.addSeparator(position: .top)
        toolView.didSelectActionType = {[weak self] actionType, sourceView in
            self?.performTaskMenuAction(with: actionType, sourceView: sourceView)
        }
        
        return toolView
    }
    
    /// 执行任务菜单操作
    func performTaskMenuAction(with type: TodoTaskActionType, sourceView: UIView) {
        let tasks = getSelectedTasks()
        guard tasks.count > 0 else {
            return
        }
    
        self.taskController.performMenuAction(with: type,
                                              for: Array(tasks),
                                              sourceView: sourceView) { [weak self] in
            self?.endSelecting()
        }
    }
    
    // MARK: - Navigation Bar Button Items
    
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

    // MARK: - Event Response
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        self.endEditing(animated: true)
        guard let config = self.interactor.listOptionConfig() else {
            return
        }

        let optionMenuController = TodoListOptionMenuController(config: config)
        optionMenuController.didSelectListOption = { [weak self] option in
            self?.selectListOption(option)
        }
        
        optionMenuController.didSelectGroupType = { [weak self] groupType in
            self?.selectGroupType(groupType)
        }
        
        optionMenuController.didSelectSortType = { [weak self] sortType in
            self?.selectSortType(sortType)
        }
        
        optionMenuController.didSelectSortOrder = { [weak self] sortOrder in
            self?.selectSortOrder(sortOrder)
        }
        
        let menuItems = optionMenuController.menuItems()
        let menuController = TPLevelMenuViewController(menuItems: menuItems)
        let sourceRect = CGRect(x: moreButton.bounds.maxX,
                                y: moreButton.bounds.maxY,
                                size: .zero)
        menuController.show(from: moreButton, sourceRect: sourceRect, isCovered: false)
    }
    
    @objc func clickCancelEdit(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithSoftStyle()
        setSelecting(false)
    }
    
    func didChangeSelectedTasks() {
        selectionDelegate?.todoTaskListDidUpdateSelectedTasks(to: getSelectedTasks())
        updateToolView()
    }
    
    /// 选中所有任务
    @objc func selectAllTasks() {
        TPImpactFeedback.impactWithSoftStyle()
        performSelectAllTasks()
    }
    
    /// 反选所有任务
    @objc func deselectAllTasks() {
        TPImpactFeedback.impactWithSoftStyle()
        performDeselectAllTasks()
    }
    
    /// 子类需要重写此方法以执行全选操作
    func performSelectAllTasks() {
        // 默认实现为空
    }
    
    /// 子类需要重写此方法以执行反选操作
    func performDeselectAllTasks() {
        // 默认实现为空
    }
    
    /// 子类需要重写此方法以获取选中的任务列表
    func getSelectedTasks() -> Set<TodoTask> {
        return []
    }
    
    /// 子类重写此方法获取是否所有任务都被选中
    func isAllTasksSelected() -> Bool {
        return false
    }
    
    /// 子类需要重写此方法以执行编辑列表操作
    func editList() {
        // 默认实现为空
    }
    
    // MARK: - List Options
    
    func selectListOption(_ option: TodoListOption) {
        switch option {
        case .select:
            self.setSelecting(true)
        case .layout:
            self.toggleLayout()
        case .showCompleted:
            self.interactor.toggleShowCompleted()
        case .showDetail:
            self.toggleShowDetail()
        case .edit:
            self.editList()
        default:
            break
        }
    }
    
    private func toggleShowDetail() {
        self.interactor.toggleShowDetail()
        // 子类可以重写以更新UI
    }
    
    /// 切换布局
    private func toggleLayout() {
        var layoutType = self.interactor.layoutType()
        if layoutType == .list {
            layoutType = .board
        } else {
            layoutType = .list
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
}
