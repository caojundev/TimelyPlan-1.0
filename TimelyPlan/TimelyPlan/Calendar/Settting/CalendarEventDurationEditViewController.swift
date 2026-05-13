//
//  CalendarEventDurationEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/13.
//

import Foundation
import UIKit

class CalendarEventDurationEditViewController: TPTableSectionsViewController,
                                                TPTableSectionControllerDelegate {
    var didEndEditing: (() -> Void)?
    
    private let sectionController = TPTableItemSectionController()
    
    private let durations = CalendarSetting.defaultEventDurations
    
    private var selectedDuration: Int = CalendarSetting.shared.defaultEventDuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Default Duration")
        setupActionsBar(actions: [saveAction])
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.cellStyle.selectedBackgroundColor = .secondarySystemGroupedBackground
        sectionController.delegate = self
        sectionControllers = [sectionController]
        setupCellItems()
        reloadData()
    }
    
    func setupCellItems() {
        var cellItems = [TPCheckmarkTableCellItem]()
        for duration in durations {
            let cellItem = TPCheckmarkTableCellItem()
            cellItem.title = (duration * SECONDS_PER_MINUTE).localizedTitle
            cellItems.append(cellItem)
        }
        
        sectionController.cellItems = cellItems
    }
    
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override func clickSave() {
        self.navigationController?.popViewController(animated: true)
        if CalendarSetting.shared.defaultEventDuration != selectedDuration {
            CalendarSetting.shared.defaultEventDuration = selectedDuration
            callback(after: 0.2) {
                self.didEndEditing?()
            }
        }
    }

    // MARK: -
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        selectedDuration = durations[index]
        adapter.updateCheckmarks()
    }
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        let duration = durations[index]
        return duration == selectedDuration
    }
}
