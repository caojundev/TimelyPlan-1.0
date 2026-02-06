//
//  RepeatEndEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/23.
//

import Foundation

class RepeatEndEditViewController: TPTableSectionsViewController,
                                    TPCalendarSingleDateSelectionDelegate {
    
    var didEndEditing: ((RepeatEnd?) -> Void)?
    
    var repeatEnd: RepeatEnd? {
        switch endType {
        case .never:
            return nil
        case .date:
            return RepeatEnd(end: endDate)
        case .count:
            return RepeatEnd(occurrenceCount: occurrenceCount)
        }
    }
    
    /// 结束类型
    private var endType: RepeatEndType = .never
  
    /// 结束日期
    private var endDate: Date = Date()
    
    /// 重复次数
    private var occurrenceCount: Int = 1
    
    /// 描述信息区块
    lazy var infoSectionController: TPTableItemSectionController = {
        let sectionItem = TPTableItemSectionController()
        sectionItem.headerItem.height = 10.0
        sectionItem.footerItem.height = 0.0
        sectionItem.cellItems = [infoCellItem]
        return sectionItem
    }()
    
    /// 描述信息单元格
    lazy var infoCellItem: TPDescriptionTableCellItem = {
        let cellItem = TPDescriptionTableCellItem()
        cellItem.selectionStyle = .none
        cellItem.height = 45.0
        cellItem.updater = { [weak self] in
            self?.updateDescriptionInfoCellItem()
        }
        
        return cellItem
    }()
    
    /// 规则类型区块
    lazy var editSectionController: TPTableItemSectionController = {
        let sectionItem = TPTableItemSectionController()
        sectionItem.headerItem.height = 10.0
        sectionItem.footerItem.height = 0.0
        return sectionItem
    }()

    /// 规则类型单元格
    lazy var endTypeCellItem: TPFullSizeSegmentedMenuTableCellItem = {
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = RepeatEndType.segmentedMenuItems()
        cellItem.updater = { [weak self] in
            self?.updateEndTypeCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let type: RepeatEndType = menuItem.actionType()!
            self?.didSelectRepeatEndType(type)
        }
        
        return cellItem
    }()

    private lazy var dateSelection: TPCalendarSingleDateSelection = {
        let selection = TPCalendarSingleDateSelection()
        selection.delegate = self
        return selection
    }()
    
    /// 日历
    private lazy var calendarCellItem: TPCalendarTableCellItem = {
        let cellItem = TPCalendarTableCellItem()
        cellItem.selection = dateSelection
        cellItem.updater = { [weak self] in
            self?.updateCalendarCellItem()
        }
        
        cellItem.height = 420.0
        return cellItem
    }()
    
    /// 重复次数
    private lazy var occurrenceCountCellItem: TPCountPickerTableCellItem = {
        let cellItem = TPCountPickerTableCellItem()
        cellItem.minimumCount = 1
        cellItem.maximumCount = 60
        cellItem.updater = { [weak self] in
            self?.updateOccurrenceCountCellItem()
        }
        
        cellItem.leadingTextForCount = { _ in
            return resGetString("Repeat")
        }
        
        cellItem.tailingTextForCount = { count in
            let unit = count > 1 ? "Times" : "Time(count)"
            return resGetString(unit)
        }
        
        cellItem.didPickCount = { [weak self] count in
            self?.didPickOccurrenceCount(count)
        }

        return cellItem
    }()
    
    init(repeatEnd: RepeatEnd?) {
        if let repeatEnd = repeatEnd {
            if let endDate = repeatEnd.endDate {
                self.endType = .date
                self.endDate = endDate
            } else {
                self.endType = .count
                self.occurrenceCount = max(1, repeatEnd.occurrenceCount ?? 1)
            }
        }
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var sectionControllers: [TPTableBaseSectionController]? {
        get {
            var cellItems: [TPBaseTableCellItem] = [endTypeCellItem]
            if endType == .date {
                cellItems.append(calendarCellItem)
            } else if endType == .count {
                cellItems.append(occurrenceCountCellItem)
            }
            
            editSectionController.cellItems = cellItems
            return [infoSectionController, editSectionController]
        }
        
        set {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("End")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.preferredContentSize = .Popover.extraLarge
        self.setupActionsBar(actions: [doneAction])
        sectionControllers = [infoSectionController, editSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    func updateDescriptionInfoCellItem() {
        if let repeatEnd = repeatEnd {
            infoCellItem.attributedText = repeatEnd.localizedAttributedDescription()
        } else {
            infoCellItem.attributedText = nil
            infoCellItem.text = RepeatEnd.neverRepeatDescription
        }
    }

    override func clickDone() {
        didEndEditing?(repeatEnd)
        dismiss(animated: true, completion: nil)
    }
    
    func updateEndTypeCellItem() {
        endTypeCellItem.selectedMenuTag = endType.rawValue
    }
    
    func updateCalendarCellItem() {
        let dateComponents = endDate.yearMonthDayComponents
        dateSelection.setSelectedDateComponents(dateComponents)
        calendarCellItem.visibleDateComponents = dateComponents
    }
    
    func updateOccurrenceCountCellItem() {
        occurrenceCountCellItem.count = occurrenceCount
    }
    
    /// 选中重复结束类型
    func didSelectRepeatEndType(_ endType: RepeatEndType) {
        self.endType = endType
        adapter.performUpdate(with: .fade)
        updateRepeatEndDescription()
    }
    
    func didPickOccurrenceCount(_ count: Int) {
        occurrenceCount = count
        updateRepeatEndDescription()
    }
    
    // MARK: - TPCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        endDate = Date.dateFromComponents(date)!
        updateRepeatEndDescription()
    }

    /// 更新计划描述信息
    func updateRepeatEndDescription() {
        infoCellItem.updater?()
        if let cell = adapter.cellForItem(infoCellItem) as? TFDescriptionTableCell {
            cell.updateDescription()
        }
        
        adapter.performNilUpdate()
    }
    
    // MARK: - Class Methods
    static func editRepeatEnd(_ repeatEnd: RepeatEnd?, completion:@escaping ((RepeatEnd?) -> Void)) {
        let vc = RepeatEndEditViewController(repeatEnd: repeatEnd)
        vc.didEndEditing = completion
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.popoverShow()
    }
}

