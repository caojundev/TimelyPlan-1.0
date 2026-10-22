//
//  WSDashboardManageViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/18.
//

import Foundation
import UIKit

/// 面板管理视图控制器。
///
/// 用于管理全部面板：新建、重命名、删除以及拖动排序。
class WSDashboardManageViewController: TPTableSectionsViewController {
    
    /// 新建面板动作
    lazy var addDashboardAction: TPButtonAction = {
        let action = TPButtonAction(title: resGetString("Add Dashboard")) { [weak self] action in
            self?.clickAddDashboard()
        }
        
        return action
    }()
    
    /// 选中面板回调。选中后由外部切换工作台展示的面板
    var didSelectDashboard: ((WSDashboard) -> Void)?
    
    /// 排序管理器
    private var reorder: TPTableDragInsertReorder?
    
    /// 数据视图模型
    private let viewModel: WSDashboardManageViewModel
    
    /// 面板列表区块控制器
    private lazy var sectionController = WSDashboardManageSectionController(viewModel: viewModel)
    
    init(currentDashboardIdentifier: String?) {
        self.viewModel = WSDashboardManageViewModel(currentDashboardIdentifier: currentDashboardIdentifier)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        title = resGetString("Dashboard")
        wrapperView.placeholderProvider = viewModel.placeholderProvider
        setupReorder()
        setupActionsBar(actions: [addDashboardAction])
        sectionControllers = [sectionController]
        reloadData()
        sectionController.didSelectDashboard = { [weak self] dashboard in
            self?.selectDashboard(dashboard)
        }
        viewModel.onDashboardsChanged = { [weak self] change in
            self?.dashboardsChanged(with: change)
        }
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - Private Methods
    private func dashboardsChanged(with change: WSDashboardManageChange?) {
        DispatchQueue.main.async {
            self.sectionController.dashboards = self.viewModel.dashboards
            self.wrapperView.performUpdate(with: .top)
            
            guard let change = change else {
                return
            }
            
            var animateDashboard: WSDashboard?
            switch change {
            case .create(let dashboard), .update(let dashboard):
                animateDashboard = dashboard
            }
            
            if let animateDashboard = animateDashboard {
                self.wrapperView.revealItem(animateDashboard, at: .middle, autoScroll: true)
            }
        }
    }
    
    /// 选中面板。回调外部切换展示后关闭当前界面
    private func selectDashboard(_ dashboard: WSDashboard) {
        TPImpactFeedback.impactWithSoftStyle()
        didSelectDashboard?(dashboard)
        dismiss(animated: true, completion: nil)
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = true
        reorder.delegate = sectionController
        self.reorder = reorder
    }
    
    // MARK: - 新建面板
    private func clickAddDashboard() {
        sectionController.createNewDashboard()
    }
}

// MARK: - 显示
extension WSDashboardManageViewController {
    
    /// 显示面板管理界面
    /// - Parameters:
    ///   - currentDashboard: 工作台当前展示的面板，用于标记选中状态
    ///   - didSelect: 选中面板回调，用于切换工作台展示的面板
    static func show(currentDashboard: WSDashboard?,
                     didSelect: ((WSDashboard) -> Void)? = nil) {
        let viewController = WSDashboardManageViewController(currentDashboardIdentifier: currentDashboard?.identifier)
        viewController.didSelectDashboard = didSelect
        let navController = UINavigationController(rootViewController: viewController)
        if let sheet = navController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        navController.show()
    }
}

// MARK: - 面板变化
/// 面板列表变化类型
enum WSDashboardManageChange {
    
    /// 新建面板
    case create(WSDashboard)
    
    /// 更新面板
    case update(WSDashboard)
}

/// 面板管理数据视图模型
class WSDashboardManageViewModel: WorkspaceDashboardProcessorDelegate {
    
    /// 面板列表改变
    var onDashboardsChanged: ((WSDashboardManageChange?) -> Void)?
    
    /// 占位视图
    private(set) lazy var placeholderProvider: TPDefaultPlaceholderProvider = {
        let provider = TPDefaultPlaceholderProvider()
        provider.emptyTitle = resGetString("No Dashboard")
        return provider
    }()
    
    /// 所有面板
    private(set) var dashboards: [WSDashboard] = []
    
    /// 工作台当前展示的面板标识，用于标记选中状态
    private(set) var currentDashboardIdentifier: String?
    
    init(currentDashboardIdentifier: String?) {
        self.currentDashboardIdentifier = currentDashboardIdentifier
        updateDashboards()
        WorkspaceRepository.addUpdater(self, for: [.dashboard])
    }
    
    deinit {
        WorkspaceRepository.removeUpdater(self)
    }
    
    // MARK: - 处理面板
    /// 创建面板
    func createDashboard(with name: String) {
        WorkspaceRepository.createDashboard(name: name)
    }
    
    /// 更新面板名称
    func updateDashboard(_ dashboard: WSDashboard, with name: String) {
        WorkspaceRepository.updateDashboard(dashboard, name: name)
    }
    
    /// 删除面板
    func deleteDashboard(_ dashboard: WSDashboard) {
        WorkspaceRepository.deleteDashboard(dashboard)
    }
    
    /// 排序面板
    func reorderDashboard(fromIndex: Int, toIndex: Int) -> Bool {
        guard dashboards.moveObject(fromIndex: fromIndex, toIndex: toIndex) else {
            return false
        }
        
        WorkspaceRepository.didEndReorderDashboards(with: dashboards)
        return true
    }
    
    private func updateDashboards() {
        dashboards = WorkspaceRepository.getDashboards()
    }
    
    /// 当前面板已被删除时，工作台会回落到首个面板，此处同步选中状态
    private func updateCurrentDashboardIdentifierIfNeeded() {
        guard let identifier = currentDashboardIdentifier,
              !dashboards.contains(where: { $0.identifier == identifier }) else {
            return
        }
        
        currentDashboardIdentifier = dashboards.first?.identifier
    }
    
    // MARK: - WorkspaceDashboardProcessorDelegate
    func didChangeRemoteWorkspaceDashbaord() {
        updateDashboards()
        updateCurrentDashboardIdentifierIfNeeded()
        onDashboardsChanged?(nil)
    }
    
    func didCreateWorkspaceDashbaord(_ board: WSDashboard) {
        updateDashboards()
        onDashboardsChanged?(.create(board))
    }
    
    func didDeleteWorkspaceDashbaord(_ board: WSDashboard) {
        updateDashboards()
        updateCurrentDashboardIdentifierIfNeeded()
        onDashboardsChanged?(nil)
    }
    
    func didUpdateWorkspaceDashbaord(_ board: WSDashboard,
                                     with change: WorkspaceDashboardChange) {
        updateDashboards()
        onDashboardsChanged?(.update(board))
    }
}

// MARK: - 面板列表区块
class WSDashboardManageSectionController: TPTableBaseSectionController,
                                          TPTableDragInsertReorderDelegate {
    
    /// 面板列表
    var dashboards: [WSDashboard]?
    
    /// 选中面板回调
    var didSelectDashboard: ((WSDashboard) -> Void)?
    
    let viewModel: WSDashboardManageViewModel
    
    let cellStyle = TPTableCellStyle()
    
    init(viewModel: WSDashboardManageViewModel) {
        self.viewModel = viewModel
        super.init()
        self.dashboards = viewModel.dashboards
        self.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.cellStyle.selectedBackgroundColor = .tertiarySystemFill
    }
    
    override var items: [ListDiffable]? {
        return dashboards
    }
    
    override func heightForHeader() -> CGFloat {
        return 15.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 60.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return WSDashboardManageCell.self
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        guard let dashboard = item(at: index) as? WSDashboard else {
            return false
        }
        
        /// 选中状态标识工作台当前展示的面板
        return dashboard.identifier == viewModel.currentDashboardIdentifier
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        guard let cell = cell as? WSDashboardManageCell,
              let dashboard = item(at: index) as? WSDashboard else {
            return
        }
        
        cell.style = cellStyle
        cell.dashboard = dashboard
        cell.isChecked = shouldShowCheckmarkForRow(at: index)
    }
    
    override func didSelectRow(at index: Int) {
        guard let dashboard = item(at: index) as? WSDashboard else {
            return
        }
        
        /// 点击面板表示选中，由外部切换工作台展示的面板
        didSelectDashboard?(dashboard)
    }
    
    override func trailingSwipeActionsConfigurationForRow(at index: Int) -> UISwipeActionsConfiguration? {
        guard let dashboard = item(at: index) as? WSDashboard else {
            return nil
        }
        
        ///< 编辑
        let editAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.editDashboard(dashboard)
            completion(true)
        }
        
        editAction.backgroundColor = Color(0x0091FF)
        editAction.image = resGetImage("edit_24", color: .white)
        
        ///< 删除。仅剩一个面板时不允许删除，避免工作台面板全部消失
        guard let dashboards = dashboards, dashboards.count > 1 else {
            return UISwipeActionsConfiguration(actions: [editAction])
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.deleteDashboard(dashboard)
            completion(true)
        }
        
        deleteAction.image = resGetImage("trash_24", color: .white)
        
        let actions = [deleteAction, editAction]
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    // MARK: - 新建 / 编辑 / 删除
    func createNewDashboard() {
        let title = resGetString("New Dashboard")
        let vc = TPTextFieldAlertController(title: title) { name in
            if let name = name, name.count > 0 {
                self.viewModel.createDashboard(with: name)
            }
        }
        
        vc.selectAllAtBeginning = false
        vc.textField.textAlignment = .left
        vc.textField.font = BOLD_SYSTEM_FONT
        vc.textField.textColor = .label
        vc.show()
    }
    
    func editDashboard(_ dashboard: WSDashboard) {
        let title = resGetString("Edit Dashboard")
        let vc = TPTextFieldAlertController(title: title) { name in
            if let name = name, name.count > 0 {
                self.viewModel.updateDashboard(dashboard, with: name)
            }
        }
        
        vc.text = dashboard.name
        vc.selectAllAtBeginning = false
        vc.textField.textAlignment = .left
        vc.textField.font = BOLD_SYSTEM_FONT
        vc.textField.textColor = .label
        vc.show()
    }
    
    func deleteDashboard(_ dashboard: WSDashboard) {
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            self.viewModel.deleteDashboard(dashboard)
        }
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let format = resGetString("\"%@\" will be permanently deleted.")
        let dashboardName = dashboard.name ?? WSDashboard.defaultName
        let message = String(format: format, dashboardName)
        let alertController = TPAlertController(title: resGetString("Delete Dashboard"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    // MARK: - TPTableDragInsertReorderDelegate
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        reorder.tableView.setEditing(false, animated: false)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                canInsertRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard targetIndexPath.row != sourceIndexPath.row else {
            return nil
        }
        
        if viewModel.reorderDashboard(fromIndex: sourceIndexPath.row,
                                      toIndex: targetIndexPath.row) {
            adapter?.moveRow(at: sourceIndexPath, to: targetIndexPath)
            return targetIndexPath
        }
        
        return sourceIndexPath
    }
}

// MARK: - 面板单元格
/// 面板单元格。左侧为圆形选中框，表示工作台当前展示的面板
class WSDashboardManageCell: TPCircularCheckboxInfoTableCell {
    
    var dashboard: WSDashboard? {
        didSet {
            self.title = dashboard?.name ?? WSDashboard.defaultName
        }
    }
}
