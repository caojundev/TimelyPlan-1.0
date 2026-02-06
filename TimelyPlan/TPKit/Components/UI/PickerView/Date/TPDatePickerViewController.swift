//
//  TPDatePickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/29.
//

import Foundation
import UIKit

class TPDatePickerViewController: TPTableSectionsViewController {
    
    var date: Date = Date() {
        didSet {
            datePickerCellItem.date = date
        }
    }
    
    var didPickDate: ((Date) -> Void)?

    lazy var sectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 0.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [datePickerCellItem,
                                       timePresetCellItem]
        return sectionController
    }()
    
    /// 日期选择单元格条目
    lazy var datePickerCellItem: TPDatePickerTableCellItem = { [weak self] in
        let cellItem = TPDatePickerTableCellItem()
        cellItem.height = 200.0
        cellItem.datePickerMode = .dateAndTime
        cellItem.updater =  {
            self?.datePickerCellItem.date = self?.date ?? Date()
        }
        
        cellItem.dateChanged = { date in
            self?.date = date
            self?.updateRightNavigationItem(animated: true)
        }
        
        return cellItem
    }()
    
    lazy var timePresetCellItem: TPAbsoluteTimePresetTableCellItem = {
        let cellItem = TPAbsoluteTimePresetTableCellItem()
        cellItem.height = 60.0
        cellItem.didSelectOffset = { [weak self] offset in
            self?.didSelectPresetTimeOffset(offset)
        }

        return cellItem
    }()
    
    convenience init() {
        self.init(style: .plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Date and Time")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.updateRightNavigationItem(animated: false)
        self.actionsBarHeight = 70.0
        self.setupActionsBar(actions: [doneAction])
        self.sectionControllers = [sectionController]
        self.adapter.cellStyle.backgroundColor = .clear
        self.adapter.reloadData()
        self.updatePopoverContentSize()
    }
    
    override var popoverContentSize: CGSize {
        let contentHeight = wrapperView.contentSize.height + actionsBarHeight
        return CGSize(width: kPopoverPreferredContentWidth, height: contentHeight)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updatePopoverContentSize()
    }

    lazy var todayBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: resGetString("Today"),
                                   style: .done,
                                   target: self,
                                   action: #selector(didClickToday))
        return item
    }()
    
    @objc func didClickToday() {
        self.date = self.date.dateByReplacingDayWithToday()
        updateRightNavigationItem(animated: true)
        updateDatePicker()
    }
    
    func updateRightNavigationItem(animated: Bool) {
        if !date.isToday {
            navigationItem.rightBarButtonItem = todayBarButtonItem
            navigationItem.setRightBarButton(todayBarButtonItem,
                                             animated: animated)
        } else {
            navigationItem.setRightBarButton(nil,
                                             animated: animated)
        }
    }
    
    override func clickDone() {
        didPickDate?(date)
        dismiss(animated: true, completion: nil)
    }
    
    /// 选中预设时间
    func didSelectPresetTimeOffset(_ offset: Duration) {
        let hour = offset.hour
        let minute = offset.minute
        self.date = date.date(withHour: hour, minute: minute)!
        updateDatePicker()
    }
    
    func updateDatePicker() {
        if let cell = adapter.cellForItem(datePickerCellItem) as? TPDatePickerTableViewCell {
            cell.reloadData(animated: true)
        }
    }
}
