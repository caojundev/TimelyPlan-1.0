//
//  HabitDaySheetMenuViewController.swift
//  iTimeFlow
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
    
    /// 点击记录
    var didClickRecord: (() -> Void)?
    
    init(task: HabitTask, date: Date, menuItems: [TPMenuItem]) {
        self.task = task
        self.date = date
        super.init(menuItems: menuItems)
        self.title = date.yearMonthDayWeekdaySymbolString()
        actionsBar?.padding = UIEdgeInsets(horizontal: 20.0, vertical: 10.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var recordAction: TPButtonAction = {
        let recordAmount = self.task.goal.validatedRecordAmount
        let title = "+\(recordAmount)"
        let action = TPButtonAction(type: .normal,
                                    title: title) { [weak self] action in
            self?.didClickRecord?()
        }
        
        action.titleColor = resGetColor(.title)
        action.style.backgroundColor = .secondarySystemGroupedBackground
        action.style.selectedBackgroundColor = .secondarySystemFill
        return action
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if task.goal.mode == .amount, task.goal.recordType == .automatically {
            setupActionsBar(actions: [recordAction, doneAction])
        } else {
            setupActionsBar(actions: [doneAction])
        }
    }
}
