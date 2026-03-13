//
//  HabitHomeWeekViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

class HabitHomeWeekViewController: TPViewController,
                                   HabitPeriodTaskListViewDelegate,
                                   HabitHomeWeekListCellDelegate {

    private lazy var listView: HabitPeriodTaskListView = {
        let view = HabitPeriodTaskListView(frame: view.bounds)
        view.preferredItemHeight = 210.0
        view.delegate = self
        return view
    }()
    
    /// 添加按钮
    private let addViewSize = CGSize(width: 40.0, height: 40.0)
    private let addViewMargin = 15.0
    private lazy var addView: TPAddView = {
        let view = TPAddView()
        view.didClickAdd = { [weak self] button in
            self?.didClickAdd(button)
        }
        
        return view
    }()
    
    private var groupProvider = HabitHomeWeekListGroupProvider()
    
    private let processor = HabitTaskMenuActionProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        view.addSubview(addView)
        listView.asyncReloadData()
        habit.addUpdater(self, for: .all)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        addView.size = addViewSize
        addView.bottom = layoutFrame.maxY - addViewMargin
        addView.right = layoutFrame.maxX - addViewMargin
        
        listView.frame = view.bounds
        let insetBottom = view.height - addView.top - addViewMargin
        listView.contentInset = UIEdgeInsets(bottom: insetBottom)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - Event Response
    @objc func didClickAdd(_ button: UIButton){
        processor.createNewTask()
    }
    
    // MARK: - HabitHomeWeekListCellDelegate
    func habitHomeWeekListCell(_ cell: HabitHomeWeekListCell, didClickMore button: UIButton) {
        guard let task = cell.task else {
            return
        }

        let habitTask = task.habitTask
        let menuController = HabitHomeWeekMenuController()
        menuController.didSelectMenuActionType = {[weak self] type in
            self?.processor.performMenuAction(type, for: habitTask, on: .now)
        }
        
        menuController.showMenu(from: button)
    }
    
    func habitHomeWeekListCell(_ cell: HabitHomeWeekListCell, didClickDate date: Date) {
        guard let task = cell.task else {
            return
        }
        
        let habitTask = task.habitTask
        let status = task.status(on: date)
        let record = task.record(on: date)
        let menuController = HabitHomeWeekDayMenuController(task: habitTask,
                                                            status: status,
                                                            date: date)
        menuController.didSelectMenuActionType = {[weak self] type in
            self?.processor.performMenuAction(type, for: habitTask, on: date, with: record)
        }
        
        menuController.didClickRecord = { [weak self] in
            self?.processor.clickRecrod(for: habitTask, on: date)
        }
        
        menuController.showMenu()
    }
    
    
    // MARK: - HabitPeriodTaskListViewDelegate
   func habitPeriodTaskListView(_ listView: HabitPeriodTaskListView, fetchTaskGroups completion: @escaping ([HabitTaskGroup]?) -> Void) {
       let firstWeekday = HabitSetting.shared.firstWeekday
       let period = HabitDatePeriod(date: .now, mode: .week, firstWeekday: firstWeekday)
       self.groupProvider.fetchGroups(in: period) { groups in
           completion(groups)
       }
   }
    
    func habitTaskListView(_ listView: HabitTaskListView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitHomeWeekListCell.self
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitHomeWeekListCell
        cell.delegate = self
        cell.task = listView.item(at: indexPath) as? HabitPeriodTask
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, classForHeaderInSection section: Int) -> AnyClass? {
        return HabitTaskListGroupHeaderView.self
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, sizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        if let headerView = headerView as? HabitTaskListGroupHeaderView {
            headerView.contentPadding = UIEdgeInsets(top: 10.0,
                                                     left: 16.0,
                                                     bottom: 0.0,
                                                     right: 16.0)
            headerView.group = listView.sectionObject(at: section) as? HabitTaskGroup
        }
    }
}

extension HabitHomeWeekViewController: HabitTaskProcessorDelegate,
                                       HabitRecordProcessorDelegate {
    
    func didCreateHabitTask(_ task: HabitTask) {
        self.groupProvider.setNeedsRefresh()
        self.listView.asyncPerformUpdate { [weak self] success in
            guard success, let self = self else { return }
            self.listView.revealTask(task)
        }
    }

    func didUpdateHabitTask(_ task: HabitTask) {
        self.groupProvider.setNeedsRefresh()
        self.listView.asyncPerformUpdate { [weak self] success in
            guard success, let self = self else { return }
            self.listView.reloadCell(forTask: task, focusAnimated: true)
        }
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        self.groupProvider.setNeedsRefresh()
        self.listView.asyncPerformUpdate()
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        self.groupProvider.setNeedsRefresh()
        self.listView.asyncPerformUpdate()
    }
    
    func didReorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        self.groupProvider.setNeedsRefresh()
        self.listView.asyncPerformUpdate()
    }
    
    // MARK: - HabitRecordProcessorDelegate
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        self.groupProvider.updateHabitRecord(record, for: task, on: date)
        if let cell = listView.cell(for: task) as? HabitHomeWeekListCell {
            cell.updateRecord(on: date, with: change, animated: true)
        }
    }
    
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        self.groupProvider.deleteHabitRecords(for: task, in: period)
        if let cell = listView.cell(for: task) as? HabitHomeWeekListCell {
            cell.updateRecords(in: period, animated: true)
        }
    }
}
