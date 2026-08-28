//
//  GanttTimelineSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/27.
//

import Foundation
import UIKit

class GanttTimelineSettingViewController: TPTableSectionsViewController {
    
    private let rowHeight = 60.0
    
    var didSelectScale: ((GanttTimeScale.Scale) -> Void)?
    
    /// 返回
    lazy var dismissButtonItem: UIBarButtonItem = {
        let image = resGetImage("chevron_right_24")
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickDismiss))
        return item
    }()
    
    /// 模式
    lazy var modeCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.height = 90.0
        cellItem.contentPadding = UIEdgeInsets(horizontal: 4.0, vertical: 4.0)
        cellItem.minimumButtonWidth = 80.0
        cellItem.imagePosition = .top
        cellItem.segmentedImageConfig.margins = UIEdgeInsets(bottom: 5.0)
        cellItem.segmentedImageConfig.size = .size(6)
        cellItem.segmentedTitleConfig.font = BOLD_SMALL_SYSTEM_FONT
        cellItem.cornerRadius = 12.0
         
        cellItem.menuItems = GanttTimeScale.Scale.segmentedMenuItems()
        cellItem.updater = {
            guard let self = self else { return }
            self.modeCellItem.selectedMenuTag = self.scale.tag
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            let scale: GanttTimeScale.Scale? = menuItem.actionType()
            if let scale = scale {
                self?.selectScale(scale)
            }
        }
        
        return cellItem
    }()
    
    lazy var modeSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.cellItems = [modeCellItem]
        return sectionController
    }()

    /// 行高设置
    lazy var rowHeightCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = rowHeight
        cellItem.title = resGetString("Row Height")
        cellItem.updater = {
            let type = GanttSetting.shared.rowHeightType
            self?.rowHeightCellItem.valueConfig = .valueText(type.title)
        }

        cellItem.didSelectHandler = {
            self?.editRowHeight()
        }

        return cellItem
    }()

    /// 显示已完成事项
    lazy var showCompletedCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = rowHeight
        cellItem.title = resGetString("Show Completed")
        cellItem.updater = {
            self?.showCompletedCellItem.isOn = GanttSetting.shared.showCompleted
        }

        cellItem.valueChanged = { isOn in
            GanttSetting.shared.showCompleted = isOn
        }

        return cellItem
    }()
    
    lazy var generalSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.cellItems = [rowHeightCellItem,
                                       showCompletedCellItem]
        return sectionController
    }()
    
    /// 显示待办
    lazy var showTodoCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = rowHeight
        cellItem.title = resGetString("Show Todo")
        cellItem.updater = {
            self?.showTodoCellItem.isOn = GanttSetting.shared.showTodo
        }

        cellItem.valueChanged = { isOn in
            GanttSetting.shared.showTodo = isOn
        }

        return cellItem
    }()
    
    lazy var todoSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.cellItems = [showTodoCellItem]
        return sectionController
    }()
    
    private(set) var scale: GanttTimeScale.Scale
    
    init(scale: GanttTimeScale.Scale) {
        self.scale = scale
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = dismissButtonItem
        wrapperView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.01))
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        sectionControllers = [modeSectionController,
                              generalSectionController,
                              todoSectionController]
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func selectScale(_ scale: GanttTimeScale.Scale) {
        guard self.scale != scale else {
            return
        }
        
        self.scale = scale
        didSelectScale?(scale)
        dismiss(animated: true)
    }

    private func editRowHeight() {
        guard let cell = adapter.cellForItem(rowHeightCellItem) else {
            return
        }
        
        let rowHeightType = GanttSetting.shared.rowHeightType
        let menuVC = TPMenuListViewController()
        let menuItem = TPMenuItem.item(with: GanttRowHeightType.allCases, updater: { type, menuAction in
            menuAction.handleBeforeDismiss = true
            menuAction.isChecked = rowHeightType == type
        })
        
        menuVC.menuItems = [menuItem]
        menuVC.didSelectMenuAction = { menuAction in
            guard let type: GanttRowHeightType = menuAction.actionType(), rowHeightType != type else {
                return
            }
            
            GanttSetting.shared.rowHeightType = type
            self.adapter.reloadCell(forItem: self.rowHeightCellItem, with: .none)
        }
        
        menuVC.popoverShow(from: cell,
                           sourceRect: cell.bounds,
                           isSourceViewCovered: false,
                           preferredPosition: .bottomLeft)
    }
    
    // MARK: - Event Response
    @objc private func clickDismiss() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true)
    }

}
