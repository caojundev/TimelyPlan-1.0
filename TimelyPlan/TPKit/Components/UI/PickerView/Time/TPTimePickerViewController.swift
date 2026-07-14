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

    /// 点击清除
    var didClickClear: (() -> Void)?
    
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
        sectionController.headerItem.height = 20.0
        sectionController.headerItem.height = 0.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [timePickerCellItem,
                                       absoluteTimePresetCellItem]
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
    
    /// 清除按钮
    private lazy var clearBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: resGetString("Clear"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear))
        item.tintColor = .redPrimary
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Time")
        self.navigationItem.rightBarButtonItem = clearBarButtonItem
        self.preferredContentSize = popoverContentSize
        self.actionsBarHeight = 70.0
        self.setupActionsBar(actions: [cancelAction, doneAction])
        self.sectionControllers = [timePointSectionController]
        self.adapter.cellStyle.backgroundColor = .clear
        self.adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .secondarySystemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .secondarySystemBackground
    }
    
    override var popoverContentSize: CGSize {
        var contentHeight = timePointSectionController.headerItem.height
        let cellItems = timePointSectionController.cellItems ?? []
        for cellItem in cellItems {
            contentHeight += cellItem.height
        }
        
        contentHeight += actionsBarHeight
        return CGSize(width: AppLayout.Popover.preferredContentWidth, height: contentHeight)
    }
    
    override func clickDone() {
        let date = date.truncatedToMinute()
        didPickDate?(date)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func clickClear() {
        TPImpactFeedback.impactWithSoftStyle()
        didClickClear?()
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
