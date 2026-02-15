//
//  TPDurationPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation
import UIKit

class TPDurationPickerViewController: TPTableSectionsViewController {

    var duration: Int = 0
    
    var minimumDuration: Duration = 5 * SECONDS_PER_MINUTE
    
    var didPickDuration: ((Int) -> Void)?

    var presetMinutes: [Int] {
        get {
            return durationPresetCellItem.presetMinutes
        }
        
        set {
            durationPresetCellItem.presetMinutes = newValue
        }
    }
    
    lazy var durationSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 20.0
        sectionController.footerItem.height = 0.0
        var cellItems: [TPBaseTableCellItem] = [durationPickerCellItem]
        if showPresetDuration {
            cellItems.append(durationPresetCellItem)
        }
        
        sectionController.cellItems = cellItems
        return sectionController
    }()
    
    lazy var durationPickerCellItem: TPDurationPickerTableCellItem = { [weak self] in
        let cellItem = TPDurationPickerTableCellItem()
        cellItem.height = 180.0
        cellItem.updater = {
            self?.durationPickerCellItem.minimumDuration = self?.minimumDuration ?? SECONDS_PER_MINUTE * 5
            self?.durationPickerCellItem.duration = self?.duration ?? 0
        }
        
        cellItem.didPickDuration = { [weak self] duration in
            self?.durationValueChanged(duration)
        }

        return cellItem
    }()

    lazy var durationPresetCellItem: TPDurationPresetTableCellItem = {
        let cellItem = TPDurationPresetTableCellItem()
        cellItem.presetMinutes = [1, 5, 15, 30, 45, 60, 90, 120, 240]
        cellItem.height = 64.0
        cellItem.didSelectMinute = { [weak self] minute in
            self?.didSelectPresetDuration(minute * SECONDS_PER_MINUTE)
        }

        return cellItem
    }()
    
    let showPresetDuration: Bool

    init(showPresetDuration: Bool = true) {
        self.showPresetDuration = showPresetDuration
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionsBarHeight = 75.0
        setupActionsBar(actions: [cancelAction, doneAction])
        sectionControllers = [durationSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemBackground
        adapter.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updatePopoverContentSize()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .secondarySystemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .secondarySystemBackground
    }
    
    override var popoverContentSize: CGSize {
        var contentHeight = durationSectionController.headerItem.height + 
        durationPickerCellItem.height + actionsBarHeight
        if showPresetDuration {
            contentHeight += durationPresetCellItem.height
        }
        
        return CGSize(width: kPopoverPreferredContentWidth, height: contentHeight)
    }
    
    override func clickDone() {
        let result = max(duration, minimumDuration)
        didPickDuration?(result)
        dismiss(animated: true, completion: nil)
    }
    
    func durationValueChanged(_ duration: Int) {
        self.duration = duration
    }
    
    func didSelectPresetDuration(_ duration: Duration) {
        self.duration = duration
        updateDurationPicker()
    }
    
    // MARK: - Update
    func updateDurationPicker() {
        if let cell = adapter.cellForItem(durationPickerCellItem) as? TPDurationPickerTableCell {
            cell.reloadData(animated: true)
        }
    }
}
