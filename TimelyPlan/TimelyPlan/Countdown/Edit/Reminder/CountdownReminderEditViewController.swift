//
//  CountdownReminderEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

class CountdownReminderEditViewController: TPTableSectionsViewController {
    
    struct Config {
        static let defaultCellHeight = 55.0
    }

    /// 结束编辑提醒
    var didEndEditing: ((TaskReminder?) -> Void)?

    /// 提醒改变
    var reminderChanged: ((TaskReminder?) -> Void)?
    
    /// 提醒区块
    private lazy var alarmSectionController: TaskReminderEditSectionController = {
        let sectionController = TaskReminderEditSectionController(date: self.targetDate,
                                                                  isAllDay: true,
                                                                  alarms: self.reminder.startAlarms)
        sectionController.absolutePresetAlarmsCellItem.alarms = self.presetAlarms
        sectionController.headerItem.height = 0.0
        sectionController.canAddAlarm = { [weak self] in
            return self?.canAddNewAlarm() ?? false
        }
        
        sectionController.didClickCustom = { [weak self] in
            self?.createAbsoluteAlarm()
        }
        
        sectionController.alarmsDidChange = { [weak self] alarms in
            self?.startAlarmsDidChange(alarms)
        }
        
        return sectionController
    }()
    
    private var presetAlarms: [TaskAlarm] {
        let alarmRawValues: [(daysBefore: Int, duration: Int)]
        alarmRawValues = [(0, 9 * SECONDS_PER_HOUR),
                          (0, 13 * SECONDS_PER_HOUR),
                          (0, 18 * SECONDS_PER_HOUR),
                          (1, 9 * SECONDS_PER_HOUR),
                          (1, 18 * SECONDS_PER_HOUR),
                          (1, 20 * SECONDS_PER_HOUR),
                          (2, 9 * SECONDS_PER_HOUR),
                          (3, 9 * SECONDS_PER_HOUR),
                          (5, 9 * SECONDS_PER_HOUR),
                          (7, 9 * SECONDS_PER_HOUR),
                          (10,9 * SECONDS_PER_HOUR),
                          (30,9 * SECONDS_PER_HOUR)]
        
        var alarms: [TaskAlarm] = []
        for alarmRawValue in alarmRawValues {
            let alarm = TaskAlarm(daysAbsolute: alarmRawValue)
            alarms.append(alarm)
        }
        
        return alarms
    }
    
    /// 提醒对象
    private(set) var reminder: TaskReminder
    
    /// 最多提醒数目
    private let maximumAlarmsCount = 5

    let targetDate: Date
    
    init(reminder: TaskReminder?,
         targetDate: Date) {
        self.reminder = (reminder?.copy() as? TaskReminder) ?? TaskReminder()
        self.targetDate = targetDate
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Reminder")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.tableView.showsVerticalScrollIndicator = false
        self.preferredContentSize = .Popover.extraLarge
        self.setupActionsBar(actions: [doneAction])
        
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.separatorColor = Color(0xaaaaaa, 0.1)
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        
        sectionControllers = [alarmSectionController]
        adapter.reloadData()
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override func clickDone() {
        dismiss(animated: true, completion: nil)
        didEndEditing?(reminder)
    }

    // MARK: - 自定义提醒
    private func createAbsoluteAlarm() {
        let vc = AlarmAbsoluteOffsetEditViewController()
        vc.didEndEditing = { alarm in
            self.alarmSectionController.didCreateAlarm(alarm)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow()
    }
    
    // MARK: - 提醒改变
    func startAlarmsDidChange(_ alarms: [TaskAlarm]) {
        reminder.startAlarms = alarms
        reminderChanged?(reminder)
    }
    
    /// 是否可以添加新提醒
    private func canAddNewAlarm() -> Bool {
        return alarmSectionController.alarmsCount < maximumAlarmsCount
    }
    
}
