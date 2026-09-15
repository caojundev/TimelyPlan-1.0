//
//  CountdownDatePickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation
import UIKit

class CountdownDatePickerViewController: TPTableSectionsViewController {

    private let dateCellHeight: CGFloat = 220.0
    
    /// 编辑中的倒数日日期
    var countdownDate: CountdownDate = CountdownDate()
    
    /// 结束选择回调
    var didPickDate: ((CountdownDate) -> Void)?
    
    convenience init(countdownDate: CountdownDate) {
        self.init(style: .grouped)
        self.countdownDate = countdownDate
    }
    
    lazy var dateSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 12.0
        sectionController.footerItem.height = 12.0
        return sectionController
    }()
    
    lazy var dateTypeCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = AppLayout.Cell.segmentedMenuCornerRadius
        cellItem.menuItems = CountdownDateType.segmentedMenuItems()
        cellItem.contentPadding = UIEdgeInsets(horizontal: 8.0)
        cellItem.updater = {
            self?.dateTypeCellItem.selectedMenuTag = self?.countdownDate.type.rawValue ?? 0
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            let dateType: CountdownDateType? = menuItem.actionType()
            if let dateType = dateType {
                self?.selectDateType(dateType)
            }
        }
        
        return cellItem
    }()

    lazy var gregorianDateCellItem: TPDatePickerTableCellItem = { [weak self] in
        let cellItem = TPDatePickerTableCellItem()
        cellItem.datePickerMode = .date
        cellItem.height = dateCellHeight
        cellItem.updater = {
            self?.gregorianDateCellItem.date = self?.countdownDate.targetDate ?? Date()
        }

        cellItem.dateChanged = { date in
            self?.selectDate(date)
        }

        return cellItem
    }()
    
    lazy var lunarDateCellItem: TPLunarDatePickerTableCellItem = { [weak self] in
        let cellItem = TPLunarDatePickerTableCellItem()
        cellItem.height = dateCellHeight
        cellItem.updater = {
            self?.lunarDateCellItem.date = self?.countdownDate.targetDate ?? Date()
        }
        
        cellItem.dateChanged = { date in
            self?.selectDate(date)
        }
        
        return cellItem
    }()
    
    /// 当前日期选择条目
    var currentDateCellItem: TPBaseTableCellItem {
        switch countdownDate.type {
        case .gregorian:
            return gregorianDateCellItem
        case .lunar:
            return lunarDateCellItem
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionsBarHeight = 75.0
        setupActionsBar(actions: [cancelAction, doneAction])
        dateSectionController.cellItems = [dateTypeCellItem, currentDateCellItem]
        sectionControllers = [dateSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemBackground
        adapter.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updatePopoverContentSize()
    }
    
    override var popoverContentSize: CGSize {
        let contentHeight = dateSectionController.headerItem.height + dateSectionController.footerItem.height + actionsBarHeight + currentDateCellItem.height + dateTypeCellItem.height
        return CGSize(width: AppLayout.Popover.preferredContentWidth, height: contentHeight)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .secondarySystemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .secondarySystemBackground
    }
    
    override func clickDone() {
        didPickDate?(countdownDate)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Event Response
    /// 选择日期类型（公历 / 农历）
    func selectDateType(_ dateType: CountdownDateType) {
        guard countdownDate.type != dateType else {
            return
        }
        
        countdownDate.type = dateType
        updateLeapMonth()
        updateDateSectionController()
    }
    
    /// 选择日期
    func selectDate(_ date: Date) {
        guard countdownDate.targetDate != date else {
            return
        }
        
        countdownDate.targetDate = date
        updateLeapMonth()
    }
    
    // MARK: - Update
    /// 同步闰月标记（仅农历有效）
    private func updateLeapMonth() {
        guard countdownDate.isLunar else {
            countdownDate.isLeapMonth = false
            return
        }
        
        countdownDate.isLeapMonth = countdownDate.lunarComponents?.isLeapMonth ?? false
    }
    
    /// 切换公历 / 农历日期选择器
    private func updateDateSectionController() {
        dateSectionController.cellItems = [dateTypeCellItem, currentDateCellItem]
        adapter.performSectionUpdate(forSectionObject: dateSectionController, rowAnimation: .fade)
        updatePopoverContentSize()
    }
    
}
