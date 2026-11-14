//
//  WSActionItemEditContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 动作编辑内容

/// 单个动作的编辑内容。
///
/// 颜色与动作方式各占一个区块；动作方式决定下方展示添加类型区块还是跳转类型区块，
/// 两个类型区块各自独立构建与选中，互不影响。
class WSActionItemEditContentViewController: TPTableSectionsViewController {

    /// 布局尺寸
    private enum Metrics {

        /// 首个区块顶部间距
        static let firstSectionHeaderHeight = 5.0

        /// 其余区块顶部间距
        static let sectionHeaderHeight = 10.0

        /// 单元格高度
        static let cellHeight = 55.0

        /// 颜色圆的尺寸
        static let colorCircleSize = CGSize(width: 36.0, height: 36.0)
    }

    /// 当前编辑的动作
    private(set) var actionItem: WSActionItem

    init(actionItem: WSActionItem) {
        self.actionItem = actionItem
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 颜色
    lazy var colorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Metrics.firstSectionHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [colorCellItem]
        return sectionController
    }()

    lazy var colorCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.colors = WSActionItem.colors
        cellItem.circleSize = Metrics.colorCircleSize
        cellItem.updater = {
            self?.colorCellItem.selectedColor = self?.actionItem.color
        }

        cellItem.didSelectColor = { [weak self] color in
            self?.selectColor(color)
        }

        return cellItem
    }()

    // MARK: - 动作方式
    lazy var modeSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Metrics.sectionHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [modeCellItem]
        return sectionController
    }()

    lazy var modeCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.backgroundColor = .clear
        cellItem.cornerRadius = AppLayout.Cell.segmentedMenuCornerRadius
        cellItem.menuItems = WSActionMode.segmentedMenuItems(style: .title)
        cellItem.updater = {
            self?.modeCellItem.selectedMenuTag = self?.actionItem.mode.tag ?? 0
        }

        cellItem.didSelectMenuItem = { [weak self] menuItem in
            guard let mode: WSActionMode = menuItem.actionType() else {
                return
            }

            self?.selectMode(mode)
        }

        return cellItem
    }()

    // MARK: - 添加类型
    /// 添加类型区块，待办、目标与其它各一个
    lazy var addTypeSectionControllers: [TPTableItemSectionController] = {
        return WSActionAddGroup.allCases.compactMap { group in
            return self.makeAddTypeSectionController(for: group)
        }
    }()

    /// 添加类型可选项，顺序与 `WSActionAddType` 声明顺序一致
    lazy var addTypeCellItems: [TPCheckmarkTableCellItem] = {
        return WSActionAddType.allCases.map { addType in
            let cellItem = TPCheckmarkTableCellItem()
            cellItem.dataItem = addType
            cellItem.title = addType.title
            cellItem.height = Metrics.cellHeight
            cellItem.didSelectHandler = { [weak self] in
                self?.selectAddType(addType)
            }

            return cellItem
        }
    }()

    /// 创建分组对应的添加类型区块
    private func makeAddTypeSectionController(for group: WSActionAddGroup) -> TPTableItemSectionController? {
        let cellItems = addTypeCellItems.filter { ($0.dataItem as? WSActionAddType)?.group == group }
        guard !cellItems.isEmpty else {
            return nil
        }

        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Metrics.sectionHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = cellItems
        return sectionController
    }

    // MARK: - 跳转类型
    lazy var navigateTypeSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Metrics.sectionHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = navigateTypeCellItems
        return sectionController
    }()

    /// 跳转类型可选项，顺序与 `SideMenuType.actionTargets` 一致
    lazy var navigateTypeCellItems: [TPCheckmarkTableCellItem] = {
        return SideMenuType.actionTargets.map { menuType in
            let cellItem = TPCheckmarkTableCellItem()
            cellItem.dataItem = menuType
            cellItem.title = menuType.title
            /// 左侧展示模块图标，与侧边栏保持一致
            cellItem.imageName = menuType.iconName
            cellItem.imageConfig.size = .default
            cellItem.imageConfig.shouldRenderImageWithColor = false
            cellItem.height = Metrics.cellHeight
            cellItem.didSelectHandler = { [weak self] in
                self?.selectNavigateType(menuType)
            }

            return cellItem
        }
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.cellStyle.selectedBackgroundColor = .tertiarySystemFill
        updateSectionControllers()
        reloadData()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    // MARK: - 区块
    /// 按当前动作方式组合区块：颜色与方式固定展示，类型区块二选一
    private func updateSectionControllers() {
        syncAddTypeCheckmarks()
        syncNavigateTypeCheckmarks()

        var controllers: [TPTableBaseSectionController] = [colorSectionController,
                                                           modeSectionController]
        switch actionItem.mode {
        case .add:
            controllers.append(contentsOf: addTypeSectionControllers)
        case .navigate:
            controllers.append(navigateTypeSectionController)
        }

        sectionControllers = controllers
    }

    // MARK: - 颜色
    private func selectColor(_ color: UIColor) {
        actionItem.colorHex = color.hexString
        colorCellItem.selectedColor = color
    }

    // MARK: - 动作方式
    /// 切换动作方式，补齐缺失的类型选择后重新组合区块
    private func selectMode(_ mode: WSActionMode) {
        guard actionItem.mode != mode else {
            return
        }

        actionItem.mode = mode
        fillMissingTypeIfNeeded()
        updateSectionControllers()
        adapter.performUpdate(with: .fade, updateVisibleItems: false)
    }

    /// 当前方式没有类型选择时补上第一项，保证动作可执行
    private func fillMissingTypeIfNeeded() {
        switch actionItem.mode {
        case .add:
            if actionItem.addType == nil {
                actionItem.addType = WSActionAddType.allCases.first
            }
        case .navigate:
            if actionItem.sideMenuType == nil {
                actionItem.sideMenuType = SideMenuType.actionTargets.first
            }
        }
    }

    // MARK: - 添加类型
    private func selectAddType(_ addType: WSActionAddType) {
        guard actionItem.addType != addType else {
            return
        }

        actionItem.addType = addType
        syncAddTypeCheckmarks()
        adapter.updateCheckmarks()
    }

    private func syncAddTypeCheckmarks() {
        for cellItem in addTypeCellItems {
            cellItem.isChecked = (cellItem.dataItem as? WSActionAddType) == actionItem.addType
        }
    }

    // MARK: - 跳转类型
    private func selectNavigateType(_ menuType: SideMenuType) {
        guard actionItem.sideMenuType != menuType else {
            return
        }

        actionItem.sideMenuType = menuType
        syncNavigateTypeCheckmarks()
        adapter.updateCheckmarks()
    }

    private func syncNavigateTypeCheckmarks() {
        for cellItem in navigateTypeCellItems {
            cellItem.isChecked = (cellItem.dataItem as? SideMenuType) == actionItem.sideMenuType
        }
    }
}
