//
//  CalendarSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/8.
//

import Foundation
import UIKit

class CalendarSettingViewController: TPTableSectionsViewController {
     
    private let defaultCellHeight = 60.0
     
    /// 周开始日
    lazy var firstWeekdayCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Week Start on")
        cellItem.updater = {
            guard let self = self else { return }
            let firstWeekday = CalendarSetting.shared.firstWeekday
            self.firstWeekdayCellItem.valueConfig = .valueText(firstWeekday.symbol)
        }
        
        cellItem.didSelectHandler = {
            self?.editFirstWeekday()
        }
        
        return cellItem
    }()
 
     lazy var generalSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.height = 10.0
         sectionController.cellItems = [firstWeekdayCellItem]
         return sectionController
     }()
     
     override func viewDidLoad() {
         super.viewDidLoad()
         self.title = resGetString("Settings")
         self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
         self.sectionControllers = [generalSectionController]
         self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
         self.reloadData()
     }
     
     override func viewWillLayoutSubviews() {
         super.viewWillLayoutSubviews()
     }
     
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func editFirstWeekday() {
        guard let cell = adapter.cellForItem(firstWeekdayCellItem) else {
            return
        }
        
        let firstWeekday = CalendarSetting.shared.firstWeekday
        WeekdayPickerController.show(currentWeekday: firstWeekday,
                                     allowWeekdays: [.sunday, .monday],
                                     from: cell.contentView,
                                     popoverPosition: .bottomLeft,
                                     permittedPositions: [.bottomLeft, .topLeft],
                                     isSourceViewCovered: false,
                                     animated: true) { weekday in
            if firstWeekday != weekday {
                CalendarSetting.shared.firstWeekday = weekday
                self.adapter.reloadCell(forItem: self.firstWeekdayCellItem, with: .none)
            }
        }
    }
 }
