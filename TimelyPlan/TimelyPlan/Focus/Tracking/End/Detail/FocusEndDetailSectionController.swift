//
//  FocusEndDetailSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/15.
//

import Foundation

class FocusEndDetailSectionController: FocusEndSectionController,
                                        FocusEndDetailRecordCellDelegate {
    
    override init(dataItem: FocusEndDataItem) {
        super.init(dataItem: dataItem)
        guard let validRecords = dataItem.validFocusRecords else {
            return
        }
        
        var cellItems = [FocusEndDetailRecordCellItem]()
        for record in validRecords {
            let cellItem = FocusEndDetailRecordCellItem(record: record)
            cellItems.append(cellItem)
        }
        
        self.cellItems = cellItems
    }
    
    // MARK: - FocusEndDetailRecordCellDelegate
    func focusEndDetailRecordCellDidClickBind(_ cell: FocusEndDetailRecordCell) {
        guard let indexPath = adapter?.indexPath(for: cell), let record = cell.record else {
            return
        }
        
        TaskPickerViewController.show(with: record.task, animated: true) { task in
            record.task = task
            self.adapter?.reloadCell(at: indexPath)
        }
    }
    
    func focusEndDetailRecordCellDidClickNote(_ cell: FocusEndDetailRecordCell) {
        guard let indexPath = adapter?.indexPath(for: cell), let record = cell.record else {
            return
        }
        
        let editVC = TPTextEditViewController(text: record.note)
        editVC.didEndEditing = { note in
            record.note = note
            self.adapter?.reloadCell(at: indexPath)
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.popoverShow()
    }
}
