//
//  GoalSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

class GoalSettingViewController: BaseSettingViewController {
     
     lazy var generalSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.height = 10.0
         sectionController.cellItems = []
         return sectionController
     }()
    
    
    // MARK: - 通知
    
    lazy var soundCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Notification Sound")
        cellItem.updater = {
            let name = NotificationSound.displayName(of: HabitSetting.shared.sound)
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
         self.title = resGetString("Goal Settings")
         self.sectionControllers = [generalSectionController,
                                    notificationSectionController]
         self.reloadData()
     }
    
    private func editSound() {
        let vc = NotificationSoundSelectViewController(sound: HabitSetting.shared.sound)
        vc.completion = { sound in
            if HabitSetting.shared.sound != sound {
                HabitSetting.shared.sound = sound
                self.adapter.reloadCell(forItem: self.soundCellItem, with: .none)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
