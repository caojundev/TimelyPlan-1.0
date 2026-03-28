//
//  HabitHomeWeekViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

class HabitHomeWeekViewController: TPViewController,
                                   HabitPeriodItemListViewDelegate,
                                   HabitHomeWeekListCellDelegate,
                                   TPPreviousNextDateViewDelegate,
                                   SettingAgentObserver {
    
    /// 当前周日期
    var date: Date = .now
    
    /// 日期视图
    private let dateViewHeight = 60.0
    
    private lazy var dateView: TPPreviousNextWeekView = {
        let firstWeekday = HabitSetting.shared.firstWeekday
        let view = TPPreviousNextWeekView(firstWeekday: firstWeekday)
        view.date = self.date
        view.delegate = self
        view.addSeparator(position: .bottom) /// 添加分割线
        return view
    }()
    
    private lazy var listView: HabitPeriodItemListView = {
        let view = HabitPeriodItemListView(frame: view.bounds)
        view.preferredItemHeight = 210.0
        view.delegate = self
        view.collectionConfiguration = { collectionView in
            collectionView.contentInset = UIEdgeInsets(bottom: 60.0)
        }
        
        return view
    }()
    
    private let edgeMargins = UIEdgeInsets(value: 15.0)
    private let backViewSize = CGSize(width: 40.0, height: 40.0)
    private let backViewMargin = 15.0
    
    /// 返回按钮
    lazy var backView: TPFlipBackTodayView = {
        let view = TPFlipBackTodayView()
        view.showTodayButton()
        view.didClickBack = { [weak self] button in
            self?.didClickBack(button)
        }
        
        return view
    }()
    
    /// 添加按钮
    private let addViewSize = CGSize(width: 40.0, height: 40.0)
    private lazy var addView: TPAddView = {
        let view = TPAddView()
        view.didClickAdd = { [weak self] button in
            self?.didClickAdd(button)
        }
        
        return view
    }()
    
    private var groupProvider = HabitHomeWeekListGroupProvider()
    
    private let dayMenuController = HabitDayMenuController()
    
    private let processor = HabitTaskMenuActionProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(dateView)
        view.addSubview(listView)
        view.addSubview(backView)
        view.addSubview(addView)
        
        listView.asyncReloadData()
        updateBackView()
        habit.addUpdater(self, for: .all)
        HabitSetting.shared.addObserver(self, forKey: .firstWeekday)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        dateView.width = view.width
        dateView.height = dateViewHeight
        dateView.origin = .zero
        
        addView.size = addViewSize
        addView.right = layoutFrame.maxX - edgeMargins.right
        addView.bottom =  layoutFrame.maxY - edgeMargins.bottom
    
        backView.size = backViewSize
        backView.bottom = addView.bottom
        backView.right = addView.left - backViewMargin
        
        listView.frame = CGRect(x: 0,
                                y: dateViewHeight,
                                width: view.width,
                                height: view.height - dateViewHeight)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - Event Response
    
    @objc func didClickBack(_ button: UIButton) {
        let oldDate = self.date
        let date = Date().startOfDay()
        self.date = date
        dateView.setDate(date, animated: true)
        selectDate(date, from: oldDate)
        updateBackView()
    }
    
    @objc func didClickAdd(_ button: UIButton){
        processor.createNewTask()
    }
    
    // MARK: - Update
    func updateBackView() {
        if self.dateView.dateRange.contains(date: .now) {
            backView.showTodayButton()
        } else if date < .now {
            backView.showLeftBackButton()
        } else {
            backView.showRightBackButton()
        }
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for key: String) {
        if key == HabitSetting.Key.firstWeekday.name {
            self.dateView.firstWeekday = HabitSetting.shared.firstWeekday
            self.listView.asyncReloadData()
        }
    }
    
    // MARK: - TPPreviousNextDateViewDelegate
    func prviousNextDateView(_ view: TPPreviousNextDateView, didSelectDate date: Date) {
        self.selectDate(date, from: self.date)
        self.updateBackView()
    }
    
    private func selectDate(_ date: Date, from oldDate: Date) {
        self.date = date
        let newDateRange = date.rangeOfThisWeek(firstWeekday: self.dateView.firstWeekday)
        if newDateRange.contains(date: oldDate) {
            /// 范围相同不更新数据
            return
        }
        
        let animateStyle: SlideStyle = .horizontalStyle(fromValue: oldDate, toValue: date)
        self.listView.asyncReloadData(animateStyle: animateStyle)
    }
    
    // MARK: - HabitHomeWeekListCellDelegate
    func habitHomeWeekListCell(_ cell: HabitHomeWeekListCell, didClickMore button: UIButton) {
        guard let periodItem = cell.periodItem else {
            return
        }

        let habitTask = periodItem.habitTask
        let menuController = HabitHomeWeekMenuController()
        menuController.didSelectMenuActionType = {[weak self] type in
            self?.processor.performMenuAction(type, for: habitTask, on: .now)
        }
        
        menuController.showMenu(from: button)
    }
    
    func habitHomeWeekListCell(_ cell: HabitHomeWeekListCell, didClickDate date: Date) {
        guard let periodItem = cell.periodItem else {
            return
        }
        let isScheduled = periodItem.isScheduledDate(date)
        if isScheduled {
            dayMenuController.showMenu(for: periodItem, on: date)
        } else {
            HabitPresenter.showNotScheduledDayMessage(for: date)
        }
    }
    
    // MARK: - HabitPeriodItemListViewDelegate
    func habitPeriodItemListView(_ listView: HabitPeriodItemListView,
                                 forceRefresh: Bool,
                                 fetchTaskGroups completion: @escaping ([HabitTaskGroup]?) -> Void) {
        if forceRefresh {
            self.groupProvider.setNeedsRefresh()
        }
        
        let firstWeekday = self.dateView.firstWeekday
        let period = HabitDatePeriod(date: self.date, mode: .week, firstWeekday: firstWeekday)
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
        cell.periodItem = listView.item(at: indexPath) as? HabitPeriodItem
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, classForHeaderInSection section: Int) -> AnyClass? {
        return HabitTaskListGroupHeaderView.self
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, sizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        if let headerView = headerView as? HabitTaskListGroupHeaderView {
            headerView.contentPadding = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 0.0, right: 16.0)
            headerView.group = listView.sectionObject(at: section) as? HabitTaskGroup
        }
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, didSelectItemAt indexPath: IndexPath) {
        guard let task = listView.item(at: indexPath) as? HabitPeriodItem else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        HabitPresenter.showStats(for: task.habitTask, date: .now)
    }
}

extension HabitHomeWeekViewController: HabitTaskProcessorDelegate,
                                       HabitRecordProcessorDelegate {
    
    func didCreateHabitTask(_ task: HabitTask) {
        self.listView.asyncPerformUpdate { [weak self] success in
            guard success, let self = self else { return }
            self.listView.revealTask(task)
        }
    }

    func didUpdateHabitTask(_ task: HabitTask) {
        self.listView.asyncPerformUpdate { [weak self] success in
            guard success, let self = self else { return }
            self.listView.revealTask(task)
        }
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        self.listView.asyncPerformUpdate()
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        self.listView.asyncPerformUpdate()
    }
    
    func didReorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
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
