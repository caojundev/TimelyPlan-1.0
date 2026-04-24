//
//  TodoHomeDisplaySettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/24.
//

import Foundation
import UIKit

class TodoHomeDisplaySettingViewController: TPTableSectionsViewController {
    
    private var reorder: TPTableDragInsertReorder?
    
    private let sectionController = TodoHomeDisplaySectionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Home Display")
        self.setupReorder()
        self.setupActionsBar(actions: [saveAction])
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.cellStyle.selectedBackgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [self.sectionController]
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
        reorder.delegate = sectionController
        reorder.isEnabled = true
        self.reorder = reorder
    }
    
    override func clickSave() {
        TodoSetting.shared.homeSectionTypes = sectionController.types
        print(sectionController.types)
        self.navigationController?.popViewController(animated: true)
    }
}

class TodoHomeDisplaySectionController: TPTableItemSectionController,
                                        TPTableDragInsertReorderDelegate {
    
    private(set) var types: [TodoHomeSectionType]
    
    override init() {
        self.types = TodoSetting.shared.orderedHomeSectionTypes
        super.init()
     
        var cellItems: [TodoHomeDisplayEditCellItem] = []
        for type in types {
            let cellItem = TodoHomeDisplayEditCellItem(sectionType: type)
            cellItems.append(cellItem)
        }
        
        self.cellItems = cellItems
    }
 
    // MARK: - TPTableDragInsertReorderDelegate
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == section
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
        guard targetIndexPath.row != sourceIndexPath.row else {
            return nil
        }
        
        types.moveObject(fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row)
        adapter?.moveRow(at: sourceIndexPath, to: targetIndexPath)
        return targetIndexPath
    }
}

class TodoHomeDisplayEditCellItem: TPImageInfoTableCellItem {
    
    let sectionType: TodoHomeSectionType
    
    init(sectionType: TodoHomeSectionType) {
        self.sectionType = sectionType
        super.init()
        self.identifier = sectionType.rawValue
        self.imageName = sectionType.iconName
        self.title = sectionType.title
        self.registerClass = TodoHomeDisplayEditCell.self
        self.rightViewSize = .mini
        self.rightViewMargins = UIEdgeInsets(right: 8.0)
    }
}

class TodoHomeDisplayEditCell: TPImageInfoTableCell {
    
    let reorderControl = UIImageView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.reorderControl.image = resGetImage("reorderControl_24")
        self.rightView = self.reorderControl
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let color = resGetColor(.title)
        self.reorderControl.updateImage(withColor: color)
    }
    
}
