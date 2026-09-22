//
//  CountdownSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/22.
//

import Foundation
import UIKit

class CountdownSettingViewController: BaseSettingViewController {
    
    // MARK: - 显示
    /// 在日历显示
    lazy var showInCalendarCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show in Calendar")
        cellItem.updater = {
            self?.showInCalendarCellItem.isOn = CountdownSetting.shared.showInCalendar
        }
        
        cellItem.valueChanged = { isOn in
            CountdownSetting.shared.showInCalendar = isOn
        }
        
        return cellItem
    }()
    
    /// 在我的一天显示
    lazy var showInMyDayCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show in My Day")
        cellItem.updater = {
            self?.showInMyDayCellItem.isOn = CountdownSetting.shared.showInMyDay
        }
        
        cellItem.valueChanged = { isOn in
            CountdownSetting.shared.showInMyDay = isOn
        }
        
        return cellItem
    }()
    
    lazy var displaySectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        sectionController.cellItems = [showInCalendarCellItem,
                                       showInMyDayCellItem]
        return sectionController
    }()
    
    // MARK: - 通知
    /// 通知声音
    lazy var soundCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Notification Sound")
        cellItem.updater = {
            let name = NotificationSound.displayName(of: CountdownSetting.shared.sound)
            self?.soundCellItem.valueConfig = .valueText(name)
        }
        
        cellItem.didSelectHandler = {
            self?.editSound()
        }
        
        return cellItem
    }()
    
    lazy var notificationSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        sectionController.cellItems = [soundCellItem]
        return sectionController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Countdown Settings")
        self.sectionControllers = [displaySectionController,
                                   notificationSectionController]
        self.reloadData()
    }
    
    /// 编辑通知声音
    private func editSound() {
        let vc = NotificationSoundSelectViewController(sound: CountdownSetting.shared.sound)
        vc.completion = { sound in
            if CountdownSetting.shared.sound != sound {
                CountdownSetting.shared.sound = sound
                self.adapter.reloadCell(forItem: self.soundCellItem, with: .none)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
