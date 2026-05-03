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
    
    // MARK: - Initialization
    
    init(interactor: TodoListInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let selectedCount = getSelectedTasksCount()
        return String(format: format, selectedCount)
    }
    
    var navigationLeftBarButtonItems: [UIBarButtonItem]? {
        guard isSelecting else {
            return nil
        }
        
        return createNavigationLeftBarButtonItems()
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
    
    /// 子类需要重写此方法以获取选中的任务数量
    func getSelectedTasksCount() -> Int {
        return 0
    }
    
    /// 子类需要重写此方法来设置选择状态
    func setSelecting(_ isSelecting: Bool) {
        // 默认实现为空
        selectionDelegate?.todoTaskListDidUpdateSelectionMode(to: isSelecting)
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
    
    /// 子类可以重写此方法来提供左侧导航栏按钮项
    func createNavigationLeftBarButtonItems() -> [UIBarButtonItem]? {
        return nil
    }
    
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
