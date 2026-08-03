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

    private let infoViewTopMargin = 20.0
    private let infoViewHeight = 60.0
    private let infoViewBottomMargin = 10.0
    private let infoView = HabitTaskDefaultInfoView()
    
    init(task: HabitEditingTask) {
        self.editingTask = task
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(infoView)
        setupActionsBar(actions: [doneAction])
        sectionControllers = [timeSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        reloadData()
        updateInfoView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.bounds.inset(by: UIEdgeInsets(horizontal: 20.0))
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.top = infoViewTopMargin
        infoView.left = layoutFrame.minX
    }
    
    override func tableViewFrame() -> CGRect {
        var frame = super.tableViewFrame()
        frame.origin.y = frame.origin.y + infoViewTopMargin + infoViewHeight + infoViewBottomMargin
        frame.size.height = frame.size.height - infoViewTopMargin - infoViewHeight - infoViewBottomMargin
        return frame
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func updateInfoView() {
        infoView.iconView.backColor = .secondarySystemGroupedBackground
        infoView.iconView.icon = editingTask.icon
        infoView.iconView.font = .boldSystemFont(ofSize: 32.0)
        infoView.titleView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        infoView.titleView.subtitleConfig.font = .boldSystemFont(ofSize: 12.0)
        infoView.titleView.title = editingTask.name ?? resGetString("Untitled Habit")
        infoView.titleView.subtitle = editingTask.goal.targetDescription
    }
    
    override func clickDone() {
        didEndEditing?(editingTask)
        dismiss(animated: true, completion: nil)
    }
}
