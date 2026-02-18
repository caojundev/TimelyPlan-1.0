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
            let info = self?.timerInfo()
            self?.timerCellItem.valueConfig = .valueText(info)
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
    
    /// 计时器信息
    private func timerInfo() -> TextRepresentable? {
        guard let timer = timer as? FocusTimer else {
            return resGetString("None")
        }

        let timerName = timer.name ?? resGetString("Untitled")
        let timerColor = timer.color ?? kFocusTimerDefaultColor
        let attributedInfo: ASAttributedString = "\("●", .foreground(timerColor)) \(timerName)"
        return attributedInfo
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
