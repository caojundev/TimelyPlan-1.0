//
//  FocusSettingsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/22.
//

import Foundation
import UIKit

class FocusSettingsViewController: TPTableSectionsViewController {
     
     /// 设置
     lazy var setting: FocusSetting = {
         return focus.setting
     }()
     
     /// 最小会话时长
     lazy var minimumRecordDurationCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
         let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
         cellItem.autoResizable = true
         cellItem.title = resGetString("Minimum Record Duration")
         cellItem.updater = {
             guard let self = self else { return }
             let duration = self.setting.getMinimumRecordDuration()
             let valueText = duration.localizedTitle
             let subtitleFormat = resGetString("Records with a focus duration of less than %@ will be discarded")
             let subtitle = String(format: subtitleFormat, valueText)
             self.minimumRecordDurationCellItem.valueConfig = .valueText(valueText)
             self.minimumRecordDurationCellItem.subtitle = subtitle
         }
         
         cellItem.didSelectHandler = {
             self?.editMinimumRecordDuration()
         }
         
         return cellItem
     }()
     
     /// 微调步长
     lazy var adjustStepDurationCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
         let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
         cellItem.autoResizable = true
         cellItem.title = resGetString("Adjust Step Duration")
         cellItem.subtitle = resGetString("The amount of time the timer increases/decreases each time")
         cellItem.updater = {
             guard let self = self else { return }
             let duration = self.setting.getAdjustStepDuration()
             self.adjustStepDurationCellItem.valueConfig = .valueText(duration.localizedTitle)
         }
         
         cellItem.didSelectHandler = {
             self?.editAdjustStepDuration()
         }
         
         return cellItem
     }()
     
     /// 添加计时器到顶部
     lazy var addTimerOnTopCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem()
         cellItem.title = resGetString("Add New Timers On Top")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = self.setting.getAddTimerOnTop()
             self.addTimerOnTopCellItem.isOn = isOn
         }

         cellItem.valueChanged = { isOn in
             guard let self = self else { return }
             self.setting.addTimerOnTop = isOn
             self.settingDidChange()
         }
         
         return cellItem
     }()
     
     /// 隐藏浮动计时器下一步按钮
     lazy var hideFloatingTimerNextButtonCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem()
         cellItem.title = resGetString("Hide Next Button Of Floating Timer")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = self.setting.getIsFloatingTimerNextButtonHidden()
             self.hideFloatingTimerNextButtonCellItem.isOn = isOn
         }

         cellItem.valueChanged = { isOn in
             guard let self = self else { return }
             self.setting.isFloatingTimerNextButtonHidden = isOn
             self.settingDidChange()
             NotificationCenter.default.post(name: FocusSetting.didChangeFloatingTimerNextButtonHiddenNotification, object: nil)
         }
         
         return cellItem
     }()
     
     lazy var generalSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.height = 10.0
         sectionController.cellItems = [addTimerOnTopCellItem,
                                        hideFloatingTimerNextButtonCellItem,
                                        minimumRecordDurationCellItem,
                                        adjustStepDurationCellItem]
         return sectionController
     }()
     
     // MARK: - Pomodoro
     
     /// 自动专注
     lazy var pomodoroAutoFocusCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem(autoResizable: true)
         cellItem.title = resGetString("Auto-Focus")
         cellItem.subtitle = resGetString("After the break is over, start to focus automatically")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = self.setting.getPomodoroAutoStartFocus()
             self.pomodoroAutoFocusCellItem.isOn = isOn
         }

         cellItem.valueChanged = { isOn in
             guard let self = self else { return }
             self.setting.pomodoroAutoStartFocus = isOn
             self.settingDidChange()
         }
         
         return cellItem
     }()
     
     /// 自动休息
     lazy var pomodoroAutoBreakCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem(autoResizable: true)
         cellItem.title = resGetString("Auto-Break")
         cellItem.subtitle = resGetString("After the focus is over, start to rest automatically")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = self.setting.getPomodoroAutoStartBreak()
             self.pomodoroAutoBreakCellItem.isOn = isOn
         }
         
         cellItem.valueChanged = { isOn in
             guard let self = self else { return }
             self.setting.pomodoroAutoStartBreak = isOn
             self.settingDidChange()
         }
         
         return cellItem
     }()
     
     lazy var pomodoroSectionController: TPTableItemSectionController = {
         let sectionController = sectionController(title: resGetString("Pomodoro"))
         sectionController.cellItems = [pomodoroAutoFocusCellItem,
                                        pomodoroAutoBreakCellItem]
         return sectionController
     }()

     // MARK: - 步骤计时器
     /// 自动休息
     lazy var steppedAutoStartNextCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem(autoResizable: true)
         cellItem.title = resGetString("Auto Start Next Step")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = self.setting.getSteppedAutoStartNext()
             self.steppedAutoStartNextCellItem.isOn = isOn
         }
         
         cellItem.valueChanged = { isOn in
             guard let self = self else { return }
             self.setting.steppedAutoStartNext = isOn
             self.settingDidChange()
         }
         
         return cellItem
     }()
     
     lazy var steppedSectionController: TPTableItemSectionController = {
         let sectionController = sectionController(title: resGetString("Stepped Timer"))
         sectionController.cellItems = [steppedAutoStartNextCellItem]
         return sectionController
     }()
     
     // MARK: - 正计时
     lazy var stopwatchDurationCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
         let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
         cellItem.title = resGetString("Maximum Duration")
         cellItem.updater = {
             guard let self = self else { return }
             let duration = self.setting.getStopwatchDuration()
             self.stopwatchDurationCellItem.valueConfig = .valueText(duration.localizedTitle)
         }
         
         cellItem.didSelectHandler = {
             self?.editStopwatchDuration()
         }
         
         return cellItem
     }()
     
     lazy var stopwatchSectionController: TPTableItemSectionController = {
         let sectionController = sectionController(title: resGetString("Stopwatch"))
         sectionController.cellItems = [stopwatchDurationCellItem]
         return sectionController
     }()
     
     // MARK: - 步骤计时器
     /// 自动休息
     lazy var autoHideHourCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem(autoResizable: true)
         cellItem.title = resGetString("Auto Hide Hour")
         cellItem.subtitle = resGetString("Display only minute and second when the hour is zero")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = self.setting.getFlipClockAutoHideHour()
             self.autoHideHourCellItem.isOn = isOn
         }
         
         cellItem.valueChanged = { isOn in
             guard let self = self else { return }
             self.setting.flipClockAutoHideHour = isOn
             self.settingDidChange()
         }
         
         return cellItem
     }()
     
     lazy var flipClockSectionController: TPTableItemSectionController = {
         let sectionController = sectionController(title: resGetString("Flip Clock"))
         sectionController.cellItems = [autoHideHourCellItem]
         return sectionController
     }()
     
     func sectionController(title: String) -> TPTableItemSectionController {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.title = title
         sectionController.headerItem.height = 50.0
         sectionController.headerItem.padding = UIEdgeInsets(horizontal: 5.0, top: 10.0)
         return sectionController
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         self.title = resGetString("Focus Settings")
         self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
         self.sectionControllers = [generalSectionController,
                                    pomodoroSectionController,
                                    steppedSectionController,
                                    stopwatchSectionController,
                                    flipClockSectionController]
         self.reloadData()
     }
     
     override func viewWillLayoutSubviews() {
         super.viewWillLayoutSubviews()
     }
     
     private func settingDidChange() {
         focus.setting = setting
     }
     
     private func selectMinute(within range: ClosedRange<Int>, selectedMinute: Int, completion: ((Int) -> Void)?) {
         let pickerVC = TPCountPickerViewController()
         pickerVC.count = selectedMinute
         pickerVC.minimumCount = range.lowerBound
         pickerVC.maximumCount = range.upperBound
         pickerVC.tailingTextForCount = { count in
             return resGetString("Minutes")
         }
         
         pickerVC.didPickCount = completion
         pickerVC.popoverShow()
     }
     
     private func editMinimumRecordDuration() {
         let duration = setting.getMinimumRecordDuration()
         let minutes = duration.numberOfMinutes
         selectMinute(within: FocusSetting.minimumRecordMinuteRange, selectedMinute: minutes) { count in
             let duration = count * SECONDS_PER_MINUTE
             guard self.setting.minimumRecordDuration != duration else {
                 return
             }
             
             self.setting.minimumRecordDuration = duration
             self.settingDidChange()
             self.adapter.reloadCell(forItem: self.minimumRecordDurationCellItem, with: .none)
         }
     }
     
     private func editAdjustStepDuration() {
         let duration = setting.getAdjustStepDuration()
         let minutes = duration.numberOfMinutes
         selectMinute(within: FocusSetting.adjustStepMinuteRange, selectedMinute: minutes) { count in
             let duration = count * SECONDS_PER_MINUTE
             guard self.setting.adjustStepDuration != duration else {
                 return
             }
             
             self.setting.adjustStepDuration = duration
             self.settingDidChange()
             self.adapter.reloadCell(forItem: self.adjustStepDurationCellItem, with: .none)
         }
     }
     
     private func editStopwatchDuration() {
         let vc = TPDurationPickerViewController(showPresetDuration: false)
         vc.duration = setting.getStopwatchDuration()
         vc.minimumDuration = FocusSetting.minimumStopwatchDuration
         vc.didPickDuration = { duration in
             guard self.setting.stopwatchDuration != duration else {
                 return
             }
                     
             self.setting.stopwatchDuration = duration
             self.settingDidChange()
             self.adapter.reloadCell(forItem: self.stopwatchDurationCellItem, with: .none)
         }
         
         vc.popoverShowAsNavigationRoot()
     }
 }
