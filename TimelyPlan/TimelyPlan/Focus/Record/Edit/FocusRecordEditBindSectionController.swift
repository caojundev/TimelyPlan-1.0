//
//  FocusRecordEditBindSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/9.
//

import Foundation
import UIKit

class FocusRecordEditBindSectionController: TPTableItemSectionController {
     
    var timer: FocusTimerRepresentable?
    
    var didSelectTimer: ((FocusTimerRepresentable?) -> Void)?
    
    var didSelectTask: ((TaskRepresentable?) -> Void)?
   
    /// 计时器
    private lazy var timerCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Timer")
        cellItem.updater = {
            var valueText: String?
            if let timer = self?.timer {
                valueText = timer.name ?? resGetString("Untitled")
            } else {
                valueText = resGetString("None")
            }
            
            self?.timerCellItem.valueConfig = .valueText(valueText)
        }
        
        cellItem.didSelectHandler = {
            self?.selectTimer()
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [timerCellItem]
    }
    
    // MARK: - Handler
    func selectTimer() {
         let timerPicker = FocusTimerPickerViewController(timer: self.timer)
        timerPicker.didPickTimer = { timer in
            self.timer = timer
            self.adapter?.reloadCell(forItem: self.timerCellItem, with: .none)
            self.didSelectTimer?(timer)
        }
        
        let navController = UINavigationController(rootViewController: timerPicker)
        navController.show()
    }
}
