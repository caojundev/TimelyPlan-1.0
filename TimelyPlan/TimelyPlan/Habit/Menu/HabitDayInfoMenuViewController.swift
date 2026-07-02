//
//  HabitDayInfoMenuViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/2.
//

import Foundation
import UIKit

class HabitDayInfoMenuViewController: HabitDaySheetMenuViewController {
    
    private let infoViewHeight = 70.0
    private let infoView = HabitTaskProgressInfoView()
    private let detailProvider = HabitTaskDetailProvider()
    
    let periodItem: HabitPeriodItem

    init(periodItem: HabitPeriodItem,
         date: Date,
         menuItems: [TPMenuItem]) {
        self.periodItem = periodItem
        let status = periodItem.status(on: date)
        super.init(task: periodItem.habitTask,
                   date: date,
                   status: status,
                   menuItems: menuItems)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = BOLD_SYSTEM_FONT
        view.addSubview(infoView)
        updateInfo()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.bounds.inset(by: UIEdgeInsets(horizontal: 20.0))
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.top = titleLabel.bottom + titleMargins.bottom
        infoView.left = layoutFrame.minX
    }
    
    override func tableViewFrame() -> CGRect {
        var frame = super.tableViewFrame()
        frame.origin.y = frame.origin.y + infoViewHeight
        return frame
    }
    
    private func updateInfo() {
        infoView.iconView.icon = task.icon
        infoView.iconView.font = .boldSystemFont(ofSize: 24.0)
        infoView.titleView.title = task.name ?? resGetString("Untitled Habit")
        let subtitle = detailProvider.detail(for: periodItem, on: date, color: .secondaryLabel)
        infoView.titleView.subtitle = subtitle
        
        let status = periodItem.status(on: date)
        infoView.statusView.setStatus(status)
        
        /// 更新进度
        let progressView = infoView.progressView
        progressView.backLineColor = Color(0x000000, 0.4)
        progressView.progressLineColor = task.color
        progressView.progress = periodItem.progress(on: date)
    }
}

