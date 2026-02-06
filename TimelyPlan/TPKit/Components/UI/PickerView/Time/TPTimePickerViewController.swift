//
//  TPTimePickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/15.
//

import Foundation

class TPTimePickerViewController: TPTableSectionsViewController {
    
    /// 编辑时间对象
    var date: Date
    
    /// 选中日期回调
    var didPickDate: ((Date) -> Void)?

    init(date: Date = .now) {
        self.date = date.dateByRemovingSeconds()!
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 时间点
    lazy var timePointSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 0.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [absoluteTimePresetCellItem,
                                       timePickerCellItem,
                                       relativeTimePresetCellItem]
        return sectionController
    }()
    
    lazy var timePickerCellItem: TPTimePickerTableCellItem = {
        let cellItem = TPTimePickerTableCellItem()
        cellItem.height = 240.0
        cellItem.updater = { [weak self] in
            self?.timePickerCellItem.date = self?.date ?? .now
        }
        
        cellItem.didPickDate = { [weak self] date in
            self?.date = date
        }
        
        return cellItem
    }()
    
    lazy var absoluteTimePresetCellItem: TPAbsoluteTimePresetTableCellItem = {
        let cellItem = TPAbsoluteTimePresetTableCellItem()
        cellItem.height = 60.0
        cellItem.didSelectOffset = { [weak self] offset in
            self?.didSelectPresetAbsoluteTimeOffset(offset)
        }

        return cellItem
    }()
    
    lazy var relativeTimePresetCellItem: TPRelativeTimePresetTableCellItem = {
        let cellItem = TPRelativeTimePresetTableCellItem()
        cellItem.height = 64.0
        cellItem.didSelectOffset = { [weak self] offset in
            self?.didSelectPresetRelativeTimeOffset(offset)
        }
        
        return cellItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Time")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.preferredContentSize = popoverContentSize
        self.actionsBarHeight = 75.0
        self.setupActionsBar(actions: [cancelAction, doneAction])
        self.sectionControllers = [timePointSectionController]
        self.adapter.cellStyle.backgroundColor = .clear
        self.adapter.reloadData()
    }
    
    override var popoverContentSize: CGSize {
        let contentHeight = timePickerCellItem.height + absoluteTimePresetCellItem.height + relativeTimePresetCellItem.height + actionsBarHeight
        return CGSize(width: kPopoverPreferredContentWidth, height: contentHeight)
    }
    
    override func clickDone() {
        didPickDate?(date)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Select
    private func didSelectPresetAbsoluteTimeOffset(_ offset: Duration) {
        self.date = date.dateWithTimeOffset(offset)
        reloadTimerPicker()
    }
    
    private func didSelectPresetRelativeTimeOffset(_ offset: Int) {
        guard let date = Date.now.dateByAddingMinutes(offset) else {
            return
        }
        
        self.date = date
        reloadTimerPicker()
    }
    
    /// 更新时间选择器
    private func reloadTimerPicker() {
        if let cell = adapter.cellForItem(timePickerCellItem) as? TPTimePickerTableCell {
            cell.reloadData(animated: true)
        }
    }
}
