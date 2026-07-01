//
//  FocusSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/22.
//

import Foundation
import UIKit

class FocusSettingViewController: BaseSettingViewController {
     
    /// 周开始日
    lazy var firstWeekdayCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Week Start on")
        cellItem.updater = {
            guard let self = self else { return }
            let firstWeekday = FocusSetting.shared.firstWeekday
            self.firstWeekdayCellItem.valueConfig = .valueText(firstWeekday.symbol)
        }
        
        cellItem.didSelectHandler = {
            self?.editFirstWeekday()
        }
        
        return cellItem
    }()
    
     /// 最小会话时长
     lazy var minimumRecordDurationCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
         let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
         cellItem.autoResizable = true
         cellItem.minimumHeight = defaultCellHeight
         cellItem.title = resGetString("Minimum Record Duration")
         cellItem.updater = {
             guard let self = self else { return }
             let duration = FocusSetting.shared.validatedMinimumRecordDuration
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
         cellItem.minimumHeight = defaultCellHeight
         cellItem.title = resGetString("Adjust Step Duration")
         cellItem.subtitle = resGetString("The amount of time the timer increases/decreases each time")
         cellItem.updater = {
             guard let self = self else { return }
             let duration = FocusSetting.shared.validatedAdjustStepDuration
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
         cellItem.height = defaultCellHeight
         cellItem.title = resGetString("Add New Timers on Top")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = FocusSetting.shared.addTimerOnTop
             self.addTimerOnTopCellItem.isOn = isOn
         }

         cellItem.valueChanged = { isOn in
             FocusSetting.shared.addTimerOnTop = isOn
         }
         
         return cellItem
     }()
     
     /// 隐藏浮动计时器下一步按钮
     lazy var hideFloatingTimerNextButtonCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem()
         cellItem.height = defaultCellHeight
         cellItem.title = resGetString("Hide Next Button Of Floating Timer")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = FocusSetting.shared.isFloatingTimerNextButtonHidden
             self.hideFloatingTimerNextButtonCellItem.isOn = isOn
         }

         cellItem.valueChanged = { isOn in
             guard let self = self else { return }
             FocusSetting.shared.isFloatingTimerNextButtonHidden = isOn
             NotificationCenter.default.post(name: FocusSetting.didChangeFloatingTimerNextButtonHiddenNotification, object: nil)
         }
         
         return cellItem
     }()
     
     lazy var generalSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.height = 10.0
         sectionController.cellItems = [firstWeekdayCellItem      ,
                                        addTimerOnTopCellItem,
                                        hideFloatingTimerNextButtonCellItem,
                                        minimumRecordDurationCellItem,
                                        adjustStepDurationCellItem]
         return sectionController
     }()

    // MARK: - 通知
    lazy var focusEndSoundCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Focus End Sound")
        cellItem.updater = {
            let name = NotificationSound.displayName(of: FocusSetting.shared.focusEndSound)
            self?.focusEndSoundCellItem.valueConfig = .valueText(name)
        }
        
        cellItem.didSelectHandler = {
            self?.editFocusEndSound()
        }

        return cellItem
    }()
    
    lazy var breakEndSoundCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Break End Sound")
        cellItem.updater = {
            let name = NotificationSound.displayName(of: FocusSetting.shared.breakEndSound)
            self?.breakEndSoundCellItem.valueConfig = .valueText(name)
        }
        
        cellItem.didSelectHandler = {
            self?.editBreakEndSound()
        }

        return cellItem
    }()
     
     lazy var notificationSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.title = resGetString("Notification")
         sectionController.headerItem.height = titleHeaderHeight
         sectionController.headerItem.padding = titleHeaderPadding
         sectionController.cellItems = [focusEndSoundCellItem,
                                        breakEndSoundCellItem]
         return sectionController
     }()
    
    
     // MARK: - Pomodoro
     
     /// 自动专注
     lazy var pomodoroAutoFocusCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem()
         cellItem.autoResizable = true
         cellItem.minimumHeight = defaultCellHeight
         cellItem.title = resGetString("Auto-Focus")
         cellItem.subtitle = resGetString("After the break is over, start to focus automatically")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = FocusSetting.shared.pomodoroAutoStartFocus
             self.pomodoroAutoFocusCellItem.isOn = isOn
         }

         cellItem.valueChanged = { isOn in
             FocusSetting.shared.pomodoroAutoStartFocus = isOn
         }
         
         return cellItem
     }()
     
     /// 自动休息
     lazy var pomodoroAutoBreakCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem()
         cellItem.autoResizable = true
         cellItem.minimumHeight = defaultCellHeight
         cellItem.title = resGetString("Auto-Break")
         cellItem.subtitle = resGetString("After the focus is over, start to rest automatically")
         cellItem.updater = {
             let isOn = FocusSetting.shared.pomodoroAutoStartBreak
             self?.pomodoroAutoBreakCellItem.isOn = isOn
         }
         
         cellItem.valueChanged = { isOn in
             FocusSetting.shared.pomodoroAutoStartBreak = isOn
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
         let cellItem = TPSwitchTableCellItem()
         cellItem.height = defaultCellHeight
         cellItem.title = resGetString("Auto Start Next Step")
         cellItem.updater = {
             let isOn = FocusSetting.shared.steppedAutoStartNext
             self?.steppedAutoStartNextCellItem.isOn = isOn
         }
         
         cellItem.valueChanged = { isOn in
             FocusSetting.shared.steppedAutoStartNext = isOn
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
         cellItem.height = defaultCellHeight
         cellItem.title = resGetString("Maximum Duration")
         cellItem.updater = {
             let duration = FocusSetting.shared.validatedStopwatchMaxDuration
             self?.stopwatchDurationCellItem.valueConfig = .valueText(duration.localizedTitle)
         }
         
         cellItem.didSelectHandler = {
             self?.editStopwatchMaxDuration()
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
         let cellItem = TPSwitchTableCellItem()
         cellItem.autoResizable = true
         cellItem.minimumHeight = defaultCellHeight
         cellItem.title = resGetString("Auto Hide Hour")
         cellItem.subtitle = resGetString("Display only minute and second when the hour is zero")
         cellItem.updater = {
             let isOn = FocusSetting.shared.flipClockAutoHideHour
             self?.autoHideHourCellItem.isOn = isOn
         }
         
         cellItem.valueChanged = { isOn in
             FocusSetting.shared.flipClockAutoHideHour = isOn
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
         sectionController.headerItem.height = titleHeaderHeight
         sectionController.headerItem.padding = titleHeaderPadding
         return sectionController
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         self.title = resGetString("Focus Settings")
         self.sectionControllers = [generalSectionController,
                                    notificationSectionController,
                                    pomodoroSectionController,
                                    steppedSectionController,
                                    stopwatchSectionController,
                                    flipClockSectionController]
         self.reloadData()
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
         let duration = FocusSetting.shared.validatedMinimumRecordDuration
         let minutes = duration.numberOfMinutes
         self.selectMinute(within: FocusSetting.minimumRecordMinuteRange, selectedMinute: minutes) {[weak self] count in
             guard let self = self else { return }
             let duration = count * SECONDS_PER_MINUTE
             FocusSetting.shared.minimumRecordDuration = duration
             self.adapter.reloadCell(forItem: self.minimumRecordDurationCellItem, with: .none)
         }
     }
     
     private func editAdjustStepDuration() {
         let duration = FocusSetting.shared.validatedAdjustStepDuration
         let minutes = duration.numberOfMinutes
         self.selectMinute(within: FocusSetting.adjustStepMinuteRange, selectedMinute: minutes) { [weak self] count in
             guard let self = self else { return }
             let duration = count * SECONDS_PER_MINUTE
             FocusSetting.shared.adjustStepDuration = duration
             self.adapter.reloadCell(forItem: self.adjustStepDurationCellItem, with: .none)
         }
     }
     
     private func editStopwatchMaxDuration() {
         let vc = TPDurationPickerViewController(showPresetDuration: false)
         vc.duration = FocusSetting.shared.validatedStopwatchMaxDuration
         vc.minimumDuration = FocusSetting.minimumStopwatchDuration
         vc.didPickDuration = {[weak self] duration in
             guard let self = self else { return }
             FocusSetting.shared.stopwatchMaxDuration = duration
             self.adapter.reloadCell(forItem: self.stopwatchDurationCellItem, with: .none)
         }
         
         vc.popoverShow()
     }
    
    
    private func editFirstWeekday() {
        guard let cell = adapter.cellForItem(firstWeekdayCellItem) else {
            return
        }
        
        let firstWeekday = FocusSetting.shared.firstWeekday
        WeekdayPickerController.show(currentWeekday: firstWeekday,
                                     allowWeekdays: [.sunday, .monday],
                                     from: cell.contentView,
                                     popoverPosition: .bottomLeft,
                                     permittedPositions: [.bottomLeft, .topLeft],
                                     isSourceViewCovered: false,
                                     animated: true) { weekday in
            FocusSetting.shared.firstWeekday = weekday
            self.adapter.reloadCell(forItem: self.firstWeekdayCellItem, with: .none)
        }
    }
    
    private func editFocusEndSound() {
        let vc = NotificationSoundSelectViewController(sound: FocusSetting.shared.focusEndSound)
        vc.completion = { sound in
            if FocusSetting.shared.focusEndSound != sound {
                FocusSetting.shared.focusEndSound = sound
                self.adapter.reloadCell(forItem: self.focusEndSoundCellItem, with: .none)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editBreakEndSound() {
        let vc = NotificationSoundSelectViewController(sound: FocusSetting.shared.breakEndSound)
        vc.completion = { sound in
            if FocusSetting.shared.breakEndSound != sound {
                FocusSetting.shared.breakEndSound = sound
                self.adapter.reloadCell(forItem: self.breakEndSoundCellItem, with: .none)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }

 }
                                                                            
