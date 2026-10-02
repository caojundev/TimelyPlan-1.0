//
//  AppSideMenuSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/2.
//

import Foundation
import UIKit

/// 侧边栏菜单显示与排序设置
class AppSideMenuSettingViewController: TPTableSectionsViewController {
    
    private var reorder: TPTableDragInsertReorder?
    
    private let menuSectionController = AppSideMenuSettingSectionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Side Menu Display")
        self.setupReorder()
        self.setupActionsBar(actions: [saveAction])
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.cellStyle.selectedBackgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [menuSectionController]
        self.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.delegate = menuSectionController
        reorder.isEnabled = true
        self.reorder = reorder
    }
    
    override func clickSave() {
        AppState.shared.saveSideMenuConfiguration(order: menuSectionController.menuTypes,
                                                  hiddenTypes: Array(menuSectionController.hiddenTypes))
        self.navigationController?.popViewController(animated: true)
    }
}

class AppSideMenuSettingSectionController: TPTableItemSectionController,
                                           TPTableDragInsertReorderDelegate {
    
    /// 可自定义的菜单类型顺序
    private(set) var menuTypes: [SideMenuType]
    
    /// 隐藏的菜单类型
    private(set) var hiddenTypes: Set<SideMenuType>
    
    override init() {
        self.menuTypes = AppState.shared.customizableSideMenuOrder
        self.hiddenTypes = Set(AppState.shared.hiddenSideMenuTypes)
        super.init()
        self.headerItem.height = 10.0
        var cellItems = [AppSideMenuSettingCellItem]()
        for menuType in menuTypes {
            cellItems.append(makeCellItem(for: menuType))
        }
        
        self.cellItems = cellItems
    }
    
    /// 创建菜单对应的开关单元格条目
    private func makeCellItem(for menuType: SideMenuType) -> AppSideMenuSettingCellItem {
        let cellItem = AppSideMenuSettingCellItem(menuType: menuType)
        cellItem.updater = { [weak self] in
            self?.updateCellItem(for: menuType)
        }
        
        cellItem.valueChanged = { [weak self] isOn in
            self?.switchValueChanged(for: menuType, isOn: isOn)
        }
        
        return cellItem
    }
    
    private func updateCellItem(for menuType: SideMenuType) {
        guard let cellItem = cellItem(for: menuType) else {
            return
        }
        
        cellItem.isOn = !hiddenTypes.contains(menuType)
    }
    
    private func cellItem(for menuType: SideMenuType) -> AppSideMenuSettingCellItem? {
        guard let cellItems = self.cellItems else {
            return nil
        }
        
        for cellItem in cellItems where cellItem.identifier == menuType.rawValue {
            return cellItem as? AppSideMenuSettingCellItem
        }
        
        return nil
    }
    
    private func switchValueChanged(for menuType: SideMenuType, isOn: Bool) {
        if isOn {
            hiddenTypes.remove(menuType)
        } else {
            hiddenTypes.insert(menuType)
        }
    }
    
    // MARK: - TPTableDragInsertReorderDelegate
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == section
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                canInsertRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == section, targetIndexPath.section == section else {
            return false
        }
        
        return menuTypes.indices.contains(targetIndexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard targetIndexPath.row != sourceIndexPath.row,
              menuTypes.indices.contains(sourceIndexPath.row),
              menuTypes.indices.contains(targetIndexPath.row) else {
            return nil
        }
        
        menuTypes.moveObject(fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row)
        cellItems?.moveObject(fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row)
        adapter?.moveRow(at: sourceIndexPath, to: targetIndexPath)
        return targetIndexPath
    }
}

class AppSideMenuSettingCellItem: TPSwitchTableCellItem {
    
    /// 拖动排序控件宽度
    static let reorderControlWidth: CGFloat = 24.0
    
    /// 拖动排序控件左间距
    static let reorderControlMargin: CGFloat = 8.0
    
    /// 菜单类型
    let menuType: SideMenuType
    
    /// 右侧视图尺寸（开关按钮 + 拖动排序控件）
    override var switchButtonSize: CGSize {
        let size = super.switchButtonSize
        let width = size.width + Self.reorderControlWidth + Self.reorderControlMargin
        return CGSize(width: width, height: size.height)
    }
    
    init(menuType: SideMenuType) {
        self.menuType = menuType
        super.init()
        var imageConfig = TPImageAccessoryConfig()
        imageConfig.size = .default
        imageConfig.shouldRenderImageWithColor = false
        
        self.imageConfig = imageConfig
        self.identifier = menuType.rawValue
        self.imageName = menuType.iconName
        self.title = menuType.title
        self.isOn = !AppState.shared.hiddenSideMenuTypes.contains(menuType)
        self.registerClass = AppSideMenuSettingCell.self
        self.rightViewMargins = UIEdgeInsets(right: 8.0)
    }
}

class AppSideMenuSettingCell: TPSwitchTableCell {
    
    /// 拖动排序提示图标
    let reorderControl: UIImageView = {
        let imageView = UIImageView()
        imageView.image = resGetImage("reorderControl_24")
        return imageView
    }()
    
    /// 右侧内容视图
    private let rightContentView = UIView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        rightView = rightContentView
        rightContentView.addSubview(switchButton)
        rightContentView.addSubview(reorderControl)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let handleWidth = AppSideMenuSettingCellItem.reorderControlWidth
        let margin = AppSideMenuSettingCellItem.reorderControlMargin
        
        reorderControl.size = CGSize(width: handleWidth, height: handleWidth)
        reorderControl.left = rightViewSize.width - handleWidth
        reorderControl.centerY = rightViewSize.halfHeight
        reorderControl.updateImage(withColor: resGetColor(.title))
        
        switchButton.centerY = rightViewSize.halfHeight
        switchButton.right = rightViewSize.width - handleWidth - margin
    }
}
