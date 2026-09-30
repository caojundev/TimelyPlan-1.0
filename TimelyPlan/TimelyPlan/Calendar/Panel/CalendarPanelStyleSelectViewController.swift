//
//  CalendarPanelStyleSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/30.
//

import Foundation
import UIKit

/// 日历面板样式选择
class CalendarPanelStyleSelectViewController: TPTableSectionsViewController,
                                             TPTableSectionControllerDelegate {
    
    /// 选择结束回调
    var didEndEditing: ((CalendarPanelStyle) -> Void)?
    
    private let sectionController = TPTableItemSectionController()
    
    private let styles = CalendarPanelStyle.allCases
    
    private var panelStyle: CalendarPanelStyle
    
    init(panelStyle: CalendarPanelStyle) {
        self.panelStyle = panelStyle
        super.init(style: .insetGrouped)
        self.sectionController.headerItem.height = 5.0
        self.sectionController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Panel Style")
        setupActionsBar(actions: [saveAction])
        setupCellItems()
        sectionControllers = [sectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.cellStyle.selectedBackgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickSave() {
        navigationController?.popViewController(animated: true)
        if CalendarSetting.shared.panelStyle != panelStyle {
            CalendarSetting.shared.panelStyle = panelStyle
            callback(after: 0.1) {
                self.didEndEditing?(self.panelStyle)
            }
        }
    }
    
    // MARK: - CellItems
    
    private func setupCellItems() {
        var cellItems = [CalendarPanelStyleCellItem]()
        for style in styles {
            let cellItem = CalendarPanelStyleCellItem(panelStyle: style)
            cellItems.append(cellItem)
        }
        
        sectionController.cellItems = cellItems
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        panelStyle = styles[index]
        adapter.updateCheckmarks()
    }
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        return styles[index] == panelStyle
    }
}

/// 面板样式单元格
class CalendarPanelStyleCellItem: TPCheckmarkTableCellItem {
    
    let panelStyle: CalendarPanelStyle
    
    init(panelStyle: CalendarPanelStyle) {
        self.panelStyle = panelStyle
        super.init()
        self.title = panelStyle.displayName
        /// 图标后续添加：self.imageName = panelStyle.iconName
    }
}
