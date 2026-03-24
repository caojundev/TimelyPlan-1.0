//
//  FocusRecordEditBindSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/9.
//

import Foundation
import UIKit

class FocusRecordEditBindSectionController: TPTableItemSectionController {
     
    var timerFeature: TimerFeature?
    
    var taskFeature: TaskFeature?
    
    var didSelectTimer: ((TimerFeature?) -> Void)?
    
    var didSelectTask: ((TaskFeature?) -> Void)?
   
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
            if let taskFeature = self?.taskFeature {
                valueText = taskFeature.snapshotName ?? resGetString("Untitled")
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
        guard let timerFeature = timerFeature else {
            return resGetString("None")
        }

        return timerFeature.timerInfo
    }
    
    // MARK: - Handler
    func selectTimer() {
        let selectedTimerID = self.timerFeature?.identifier
        let timerPicker = FocusTimerPickerViewController(selectedTimerID: selectedTimerID)
        timerPicker.didPickTimer = { timer in
            let feature = timer?.feature
            self.timerFeature = feature
            self.adapter?.reloadCell(forItem: self.timerCellItem, with: .none)
            self.didSelectTimer?(feature)
        }
        
        let navController = UINavigationController(rootViewController: timerPicker)
        navController.show()
    }
    
    func selectTask() {
        TaskPickerViewController.show(with: taskFeature, animated: true) { taskFeature in
            self.taskFeature = taskFeature
            self.adapter?.reloadCell(forItem: self.taskCellItem, with: .none)
            self.didSelectTask?(taskFeature)
        }
    }
}
