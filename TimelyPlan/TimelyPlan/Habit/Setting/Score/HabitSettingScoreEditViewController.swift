//
//  HabitSettingScoreEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/19.
//

import Foundation
import UIKit

class HabitSettingScoreEditViewController: TPTableSectionsViewController {
    
     lazy var editSectionController: HabitSettingScoreEditSectionController = {
         let sectionController = HabitSettingScoreEditSectionController()
         sectionController.headerItem.height = 10.0
         sectionController.completedScore = HabitSetting.shared.defaultCompletedScore
         sectionController.skippedScore = HabitSetting.shared.defaultSkippedScore
         sectionController.failedScore = HabitSetting.shared.defaultFailedScore
         return sectionController
     }()
     
     override func viewDidLoad() {
         super.viewDidLoad()
         self.title = resGetString("Default Score")
         self.actionsBar?.actionsCountPerRow = 1
         self.setupActionsBar(actions: [saveAction])
         self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
         self.sectionControllers = [self.editSectionController]
         self.reloadData()
     }
     
     override func viewWillLayoutSubviews() {
         super.viewWillLayoutSubviews()
         self.actionsBar?.backgroundColor = .systemGroupedBackground
     }
     
     override func tableViewFrame() -> CGRect {
         let layoutFrame = view.safeLayoutFrame()
         let height = layoutFrame.height - actionsBarHeight
         return CGRect(x: 0.0, y: 0.0, width: view.width, height: height)
     }
     
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickSave() {
        TPImpactFeedback.impactWithSoftStyle()
        HabitSetting.shared.defaultCompletedScore = editSectionController.completedScore
        HabitSetting.shared.defaultSkippedScore = editSectionController.skippedScore
        HabitSetting.shared.defaultFailedScore = editSectionController.failedScore
        self.navigationController?.popViewController(animated: true)
    }
 }
