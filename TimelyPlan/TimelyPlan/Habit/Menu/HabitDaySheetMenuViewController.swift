//
//  HabitDaySheetMenuViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/5.
//

import Foundation
import UIKit

class HabitDaySheetMenuViewController: TPSheetMenuViewController {

    /// 任务
    let task: HabitTask
    
    /// 日期
    let date: Date
    
    /// 任务状态
    let status: HabitTaskStatus
        
    /// 点击记录
    var didClickRecord: (() -> Void)?
    
    init(task: HabitTask,
         date: Date,
         status: HabitTaskStatus,
         menuItems: [TPMenuItem]) {
        self.task = task
        self.date = date
        self.status = status
        super.init(menuItems: menuItems)
        self.title = date.yearMonthDayWeekdaySymbolString()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var recordAction: TPButtonAction = {
        let recordAmount = self.task.goal.validatedRecordAmount
        let unit = self.task.goal.validatedUnit
        let title = "+\(recordAmount) (\(unit))"
        let action = TPButtonAction(type: .normal,
                                    title: title) { [weak self] action in
            self?.clickRecord()
        }
        
        action.titleColor = resGetColor(.title)
        action.style.backgroundColor = .secondarySystemGroupedBackground
        action.style.selectedBackgroundColor = .secondarySystemFill
        return action
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionsBarHeight = 80.0
        let actions: [TPButtonAction]
        if status == .notStarted || status == .inProgress {
            if task.goal.mode == .amount, task.goal.recordType == .automatically {
                actions = [recordAction, doneAction]
            } else {
                actions = [doneAction]
            }
        } else {
            actions = [doneAction]
        }
        
        setupActionsBar(actions: actions)
        actionsBar?.backgroundColor = themeBackgroundColor
        actionsBar?.padding = UIEdgeInsets(top: 10.0,
                                           left: 20.0,
                                           bottom: 15.0,
                                           right: 20.0)
        
    }
    
    private func clickRecord() {
        self.dismiss(animated: true) { [weak self] in
            self?.didClickRecord?()
        }
    }
}
