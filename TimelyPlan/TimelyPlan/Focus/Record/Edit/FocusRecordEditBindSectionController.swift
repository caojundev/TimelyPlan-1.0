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
    
    var task: TaskRepresentable?
    
    var didSelectTimer: ((FocusTimerRepresentable?) -> Void)?
    
    var didSelectTask: ((TaskRepresentable?) -> Void)?
   
    /// 计时器
    private lazy var timerCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.imageContent = .withName("focus_record_bind_timer_24")
        cellItem.imageConfig.size = .mini
        cellItem.title = resGetString("Timer")
        cellItem.accessoryType = .disclosureIndicator
        cellItem.updater = {
            let info = self?.timerInfo()
            self?.timerCellItem.valueConfig = .valueText(info)
        }
        
        cellItem.didSelectHandler = {
            self?.selectTimer()
        }
        
        return cellItem
    }()
    
    /// 任务
    private lazy var taskCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.imageContent = .withName("focus_record_bind_task_24")
        cellItem.imageConfig.size = .mini
        cellItem.title = resGetString("Task")
        cellItem.accessoryType = .disclosureIndicator
        cellItem.updater = {
            var valueText: String?
            if let task = self?.task {
                valueText = task.name ?? resGetString("Untitled")
            } else {
                valueText = resGetString("None")
            }
            
            self?.taskCellItem.valueConfig = .valueText(valueText)
        }
        
        cellItem.didSelectHandler = {
            self?.selectTask()
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [timerCellItem,
                          taskCellItem]
    }
    
    /// 计时器信息
    private func timerInfo() -> TextRepresentable? {
        guard let timer = timer else {
            return resGetString("None")
        }

        let timerName = timer.name ?? resGetString("Untitled")
        let attributedInfo: ASAttributedString = "\("●", .foreground(timer.timerColor)) \(timerName)"
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
    
    func selectTask() {
        TaskPickerViewController.show(with: task, animated: true) { task in
            self.task = task
            self.adapter?.reloadCell(forItem: self.taskCellItem, with: .none)
            self.didSelectTask?(task)
        }
    }
}
