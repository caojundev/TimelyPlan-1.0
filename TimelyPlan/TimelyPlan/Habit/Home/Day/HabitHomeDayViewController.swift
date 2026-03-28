//
//  HabitHomeDayViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//

import Foundation
import UIKit

class HabitHomeDayViewController: TPContainerViewController,
                                  HabitPeriodItemListViewDelegate,
                                  HabitHomeDayListCellDelegate,
                                  TPCalendarSingleDateSelectionDelegate,
                                  SettingAgentObserver {
    
    /// 日期
    private(set) var date: Date = .now
    
    /// 周视图
    private let weekViewHeight = 80.0
    private lazy var weekView: TPCalendarScrollableWeekView = {
        let view = TPCalendarScrollableWeekView(frame: .zero)
        view.symbolStyle = .veryShort
        view.selection = selection
        view.addSeparator(position: .bottom)
        return view
    }()
    
    /// 日期选择管理器
    private lazy var selection: TPCalendarSingleDateSelection = {
        let selection = TPCalendarSingleDateSelection()
        selection.setSelectedDateComponents(date.yearMonthDayComponents)
        selection.delegate = self
        return selection
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
    lazy var addView: TPAddView = {
        let view = TPAddView()
        view.didClickAdd = { [weak self] button in
            self?.didClickAdd(button)
        }
        
        return view
    }()
    
    /// 过滤按钮
    private lazy var filterButton: HabitTaskFilterButton = {
        let button = HabitTaskFilterButton()
        button.didSelectFilterType = {[weak self] type in
            self?.selectFilterType(type)
        }
        
        return button
    }()
    
    /// 过滤类型
    private var filterType: HabitTaskFilterType = .all
    
    private var groupProvider = HabitHomeDayListGroupProvider()
    
    private(set) lazy var listView: HabitPeriodItemListView = {
        let view = HabitPeriodItemListView(frame: view.bounds)
        view.delegate = self
        view.collectionConfiguration = { collectionView in
            collectionView.contentInset = UIEdgeInsets(bottom: 60.0)
        }
        
        return view
    }()
    
    private let processor = HabitTaskMenuActionProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.filterType = filterType
        updatePlaceholderView()
        view.addSubview(weekView)
        view.addSubview(listView)
        view.addSubview(filterButton)
        view.addSubview(backView)
        view.addSubview(addView)
        reloadData()
        HabitSetting.shared.addObserver(self, forKey: .firstWeekday)
        habit.addUpdater(self, for: .all)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        weekView.width = layoutFrame.width
        weekView.height = weekViewHeight
        weekView.top = layoutFrame.minY
        
        filterButton.sizeToFit()
        filterButton.layer.setLayerShadow(color: Color(0x000000, 0.25),
                                          offset: .zero,
                                          radius: 8.0)
        filterButton.left = edgeMargins.left
        filterButton.bottom = layoutFrame.maxY - edgeMargins.bottom
    
        addView.size = addViewSize
        addView.right = layoutFrame.maxX - edgeMargins.right
        addView.bottom =  layoutFrame.maxY - edgeMargins.bottom
    
        backView.size = backViewSize
        backView.bottom = addView.bottom
        backView.right = addView.left - backViewMargin
        
        listView.width = layoutFrame.width
        listView.height = layoutFrame.height - weekViewHeight
        listView.top = weekView.bottom
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    /// 更新占位视图
    private func updatePlaceholderView() {
        var title: String?
        switch filterType {
        case .all:
            title = resGetString("No Habit Today")
        case .todo:
            title = resGetString("No To-do Habit Today")
        case .completed:
            title = resGetString("No Completed Habit Today")
        case .skipped:
            title = resGetString("No Skipped Habit Today")
        case .failed:
            title = resGetString("No Failed Habit Today")
        }
        
        self.listView.placeholderView?.title = title
    }
    
    // MARK: - Public
    func reloadData() {
        updateBackView()
        reloadWeekView()
        listView.asyncReloadData()
    }
    
    private func reloadWeekView() {
        weekView.firstWeekday = HabitSetting.shared.firstWeekday
        weekView.reloadData()
    }
    
    // MARK: - Update
    private func updateWeekView(with date: Date, animated: Bool = true) {
        let dateComponents = date.yearMonthDayComponents
        selection.setSelectedDateComponents(dateComponents)
        weekView.setVisibleDateComponents(dateComponents, animated: animated)
    }
    
    private func updateListView(fromDate: Date, toDate: Date) {
        if fromDate.isInSameDayAs(toDate) {
            return
        }
        
        let style = SlideStyle.horizontalStyle(fromValue: fromDate,
                                               toValue: toDate)
        self.listView.asyncReloadData(animateStyle: style)
        self.updatePlaceholderView()
    }
    
    func updateBackView() {
        if date.isToday {
            backView.showTodayButton()
        } else if date < .now {
            backView.showLeftBackButton()
        } else {
            backView.showRightBackButton()
        }
    }
    
    // MARK: - Event Response
    private func selectFilterType(_ filterType: HabitTaskFilterType) {
        self.filterType = filterType
        self.updatePlaceholderView()
        /// 更新列表
        self.listView.asyncPerformUpdate(forceRefresh: false)
    }
    
    @objc func didClickBack(_ button: UIButton) {
        let fromDate = self.date
        self.date = .now
        updateWeekView(with: date)
        updateListView(fromDate: fromDate, toDate: self.date)
        updateBackView()
    }
    
    @objc func didClickAdd(_ button: UIButton){
        processor.createNewTask()
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for key: String) {
        if key == HabitSetting.Key.firstWeekday.name {
            reloadWeekView()
        }
    }
    
    // MARK: - TPCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        guard let selectedDate = Date.dateFromComponents(date) else {
            return
        }
        
        let fromDate = self.date
        self.date = selectedDate
        self.updateListView(fromDate: fromDate, toDate: self.date)
        self.updateBackView()
    }
    
     // MARK: - HabitPeriodItemListViewDelegate
    func habitPeriodItemListView(_ listView: HabitPeriodItemListView,
                                 forceRefresh: Bool,
                                 fetchTaskGroups completion: @escaping ([HabitTaskGroup]?) -> Void) {
        if forceRefresh {
            self.groupProvider.setNeedsRefresh()
        }
        
        self.groupProvider.fetchGroups(on: self.date,
                                       with: self.filterType) { groups in
            completion(groups)
        }
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitHomeDayListCell.self
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitHomeDayListCell
        cell.delegate = self
        cell.periodItem = listView.item(at: indexPath) as? HabitPeriodItem
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, didSelectItemAt indexPath: IndexPath) {
        guard let periodItem = listView.item(at: indexPath) as? HabitPeriodItem else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        HabitPresenter.showStats(for: periodItem.habitTask, date: self.date)
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
    
    
    // MARK: - HabitTaskListInfoCellDelegate
    func habitTaskListInfoCell(_ cell: HabitTaskListDefaultInfoCell, didClickMore button: UIButton) {
        guard let cell = cell as? HabitHomeDayListCell, let periodItem = cell.periodItem else {
            return
        }
        
        let habitTask = periodItem.habitTask
        let date = periodItem.period.date
        let status = periodItem.status(on: date)
        let record = periodItem.record(on: date)
        let menuController = HabitHomeDayMenuController(task: habitTask,
                                                        status: status,
                                                        date: date)
        menuController.didSelectMenuActionType = {[weak self] type in
            self?.processor.performMenuAction(type, for: habitTask, on: date, with: record)
        }
        
        menuController.showMenu(from: button)
    }
    
    func habitHomeDayListCell(_ cell: HabitHomeDayListCell, didClickRecord button: UIButton) {
        guard let periodItem = cell.periodItem else {
            return
        }
        
        let habitTask = periodItem.habitTask
        let date = periodItem.period.date
        processor.clickRecrod(for: habitTask, on: date)
    }
}

extension HabitHomeDayViewController: HabitTaskProcessorDelegate,
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
        self.updateCell(for: task, with: change)
        let status = task.status(with: record)
        if status != .inProgress {
            callback(after: 0.4) {
                self.listView.asyncPerformUpdate(forceRefresh: false)
            }
        }
    }
    
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        guard period.contains(self.date) else {
            return
        }
        
        self.groupProvider.deleteHabitRecords(for: task, in: period)
        self.updateCell(for: task, with: nil)
        callback(after: 0.4) {
            self.listView.asyncPerformUpdate(forceRefresh: false)
        }
    }
    
    private func updateCell(for task: HabitTask, with change: HabitRecordChange?) {
        guard let cell = listView.cell(for: task) as? HabitHomeDayListCell else {
            return
        }
        
        cell.updateRecord(with: change, animated: true)
    }
}

