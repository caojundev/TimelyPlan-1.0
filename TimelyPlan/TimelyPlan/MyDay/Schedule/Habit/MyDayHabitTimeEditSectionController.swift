//
//  MyDayHabitTimeEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/2.
//

import Foundation

class MyDayHabitTimeEditSectionController: HabitTimeEditSectionController {
    
    var isTimePickerActive = true
    
    lazy var timePickerCellItem: TPTimePickerTableCellItem = {
        let cellItem = TPTimePickerTableCellItem()
        cellItem.height = 180.0
        cellItem.updater = { [weak self] in
            guard let self = self else { return }
            self.timePickerCellItem.date = self.startDate
        }
        
        cellItem.didPickDate = { [weak self] date in
            self?.didPickTime(date)
        }
        
        return cellItem
    }()
    
    lazy var durationPickerCellItem: TPDurationPickerTableCellItem = { [weak self] in
        let cellItem = TPDurationPickerTableCellItem()
        cellItem.minimumDuration = SECONDS_PER_MINUTE
        cellItem.height = 180.0
        cellItem.updater = {
            guard let self = self else { return }
            self.durationPickerCellItem.duration = Int(self.duration)
        }
        
        cellItem.didPickDuration = { [weak self] duration in
            self?.selectDuration(duration)
        }

        return cellItem
    }()

    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var items: [TPBaseTableCellItem] = [timeEditCellItem]
            if timeOption != .anytime {
                items.append(timeCellItem)
                if isTimePickerActive {
                    items.append(timePickerCellItem)
                }
                
                items.append(durationCellItem)
                if !isTimePickerActive {
                    items.append(durationPickerCellItem)
                }
            }
            
            return items
        }
        
        set {}
    }
    
    override func editTime() {
        guard !isTimePickerActive else {
            return
        }
        
        isTimePickerActive = true
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade, completion: nil)
    }
    
    override func editDuration() {
        guard isTimePickerActive else {
            return
        }
        
        isTimePickerActive = false
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade, completion: nil)
    }
    
}
