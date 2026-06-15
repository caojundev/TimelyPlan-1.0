//
//  HabitStatsMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitStatsMainViewController: StatsMainViewController,
                                        HabitRecordProcessorDelegate {

    /// 信息视图间距
    let infoViewMargins = UIEdgeInsets(value: 10.0)
    
    /// 信息视图
    lazy var infoView: HabitTaskDefaultInfoView = {
        let view = HabitTaskDefaultInfoView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.iconView.backColor = .tertiarySystemGroupedBackground
        view.padding = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
        return view
    }()

    /// 任务
    let task: HabitTask
    
    init(task: HabitTask, type: StatsType = .week, date: Date = .now) {
        self.task = task
        let allowTypes: [StatsType] = [.week, .month, .year]
        super.init(type: type, allowTypes: allowTypes, date: date)
        self.updateInfoView()
        HabitRepository.addUpdater(self, for: [.record])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutInfoView(infoView)
        self.contentInset = UIEdgeInsets(bottom: infoView.height + infoViewMargins.verticalLength)
    }
    
    override func handleFirstAppearance() {
        self.view.addSubview(self.infoView)
        self.layoutInfoView(infoView, isHidden: true) /// 隐藏
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            self.layoutInfoView(self.infoView)
        }, completion: nil)
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let firstWeekday = HabitSetting.shared.firstWeekday
        let vc = HabitStatsWeeklyViewController(task: task, date: date, firstWeekday: firstWeekday)
        return vc
    }
    
    override func monthlyStatsViewController() -> UIViewController! {
        let vc = HabitStatsMonthlyViewController(task: task, date: date)
        return vc
    }
    
    override func yearlyStatsViewController() -> UIViewController! {
        let vc = HabitStatsYearlyViewController(task: task, date: date)
        return vc
    }

    /// 布局任务信息视图
    private func layoutInfoView(_ infoView: UIView, isHidden: Bool = false){
        let layoutFrame = view.safeLayoutFrame().inset(by: infoViewMargins)
        infoView.width = min(480.0, layoutFrame.width)
        infoView.height = 70.0
        if isHidden {
            infoView.top = view.height
        } else {
            infoView.bottom = layoutFrame.maxY
        }
        
        infoView.centerX = layoutFrame.midX
        infoView.layer.cornerRadius = 18.0
        infoView.layer.setLayerShadow(color: Color(0x000000, 0.2),
                                      offset: CGSize(width: 0.0, height: -2.0),
                                      radius: 18.0)
        infoView.layoutIfNeeded()
    }
    
    private func updateInfoView() {
        self.infoView.iconView.icon = task.icon
        self.infoView.titleView.title = task.name
        self.infoView.titleView.subtitle = task.goal.targetDescription
    }
    
    private func reloadContentViewController() {
        if let viewController = contentViewController as? StatsContentViewController {
            viewController.reloadData()
        }
    }
    
    // MARK: - HabitRecordProcessorDelegate
    
    /// 通知习惯记录已更新
    func didUpdateHabitRecord(_ record: HabitRecord,
                              for task: HabitTask,
                              on date: Date,
                              with change: HabitRecordChange) {
        reloadContentViewController()
    }
    
    /// 通知习惯记录删除
    func didDeleteHabitRecords(for task: HabitTask?, in dateRange: DateRange) {
        reloadContentViewController()
    }

}
