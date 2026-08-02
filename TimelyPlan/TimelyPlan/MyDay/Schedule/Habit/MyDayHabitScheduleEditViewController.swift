//
//  MyDayHabitScheduleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/2.
//

import Foundation
import UIKit

class MyDayHabitScheduleEditViewController: TPTableSectionsViewController {
    
    /// 编辑任务
    var editingTask: HabitEditingTask

    /// 结束编辑回调
    var didEndEditing: ((HabitEditingTask) -> Void)?
    
    /// 时间
    lazy var timeSectionController: MyDayHabitTimeEditSectionController = { [weak self] in
        let sectionController = MyDayHabitTimeEditSectionController(timeOption: editingTask.timeOption,
                                                                    startTime: editingTask.validatedStartTime,
                                                                    duration: editingTask.validatedDuration)
        sectionController.onTimeOptionChanged = { timeOption in
            self?.editingTask.timeOption = timeOption
        }
        
        sectionController.onStartTimeChanged = { startTime in
            self?.editingTask.startTime = startTime
        }
        
        sectionController.onDurationChanged = { duration in
            self?.editingTask.duration = duration
        }

        return sectionController
    }()

    
    init(task: HabitEditingTask) {
        self.editingTask = task
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActionsBar(actions: [doneAction])
        let sectionControllers = [timeSectionController]
        self.sectionControllers = sectionControllers
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        self.didEndEditing?(self.editingTask)
        self.dismiss(animated: true, completion: nil)
    }
}
