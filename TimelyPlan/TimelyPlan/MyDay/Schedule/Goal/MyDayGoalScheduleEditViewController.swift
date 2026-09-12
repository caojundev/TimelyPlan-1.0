//
//  MyDayGoalScheduleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/12.
//

import Foundation
import UIKit

class MyDayGoalScheduleEditViewController: TPTableSectionsViewController {
    
    /// 结束编辑
    var didEndEditing: ((GoalEditingTask) -> Void)?
    
    /// 当前编辑的任务
    var editingTask: GoalEditingTask
    
    lazy var timeEditSectionController: MyDayTimeEditSectionController = { [weak self] in
        let sectionController = MyDayTimeEditSectionController(startTime: editingTask.startTime,
                                                               duration: editingTask.duration,
                                                               isDurationEditable: true)
        sectionController.onStartTimeChanged = { startTime in
            self?.editingTask.startTime = startTime
        }
        
        sectionController.onDurationChanged = { duration in
            self?.editingTask.duration = duration
        }
        
        return sectionController
    }()
    
    private let indicatorSize = CGSize(width: 6.0, height: 36.0)
    
    private let infoViewTopMargin = 20.0
    private let infoViewHeight = 60.0
    private let infoViewBottomMargin = 10.0
    private let infoView = TPColorInfoView()
    
    init(goalTask: GoalEditingTask) {
        self.editingTask = goalTask
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(infoView)
        setupActionsBar(actions: [doneAction])
        sectionControllers = [timeEditSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
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
        infoView.colorConfig = .withColor(editingTask.color, size: indicatorSize)
        infoView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        infoView.subtitleConfig.font = .boldSystemFont(ofSize: 12.0)
        infoView.title = editingTask.name
        infoView.subtitle = dateRangeDetail
    }
    
    /// 简单的详情副标题：任务计划日期范围
    private var dateRangeDetail: String? {
        guard let startDate = editingTask.startDate else {
            return nil
        }
        
        let startString = startDate.yearMonthDayString(omitYear: true,
                                                       showRelativeDate: true,
                                                       slashFormatted: true)
        guard let endDate = editingTask.endDate else {
            return startString
        }
        
        let endString = endDate.yearMonthDayString(omitYear: true,
                                                   showRelativeDate: true,
                                                   slashFormatted: true)
        return "\(startString) - \(endString)"
    }
    
    override func clickDone() {
        didEndEditing?(editingTask)
        dismiss(animated: true, completion: nil)
    }
}
