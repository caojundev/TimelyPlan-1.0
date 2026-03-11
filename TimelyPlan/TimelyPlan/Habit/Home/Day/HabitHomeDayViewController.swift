//
//  HabitHomeDayViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//

import Foundation
import UIKit

class HabitHomeDayViewController: TPContainerViewController,
                                  HabitPeriodTaskListViewDelegate,
                                  HabitHomeDayListCellDelegate,
                                  TPCalendarSingleDateSelectionDelegate {
    
    /// 日期
    private(set) var date: Date = .now {
        didSet {
            self.groupProvider.setNeedsRefresh()
        }
    }

    /// 周视图
    private let weekViewHeight = 90.0
    private lazy var weekView: TPCalendarScrollableWeekView = {
        let view = TPCalendarScrollableWeekView(frame: .zero)
        view.symbolStyle = .veryShort
        view.firstWeekday = HabitSetting.shared.firstWeekday
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
    
    /// 返回和添加按钮视图
    private let addViewSize = CGSize(width: 40.0, height: 40.0)
    lazy var addView: HabitHomeDayAddView = {
        let view = HabitHomeDayAddView()
        view.showAddButton()
        view.didClickAdd = { [weak self] button in
            self?.didClickAdd(button)
        }
        
        view.didClickBack = { [weak self] button in
            self?.didClickBack(button)
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
    var filterType: HabitTaskFilterType = .all
    
    var groupProvider = HabitTaskListGroupProvider()
    
    private(set) lazy var listView: HabitPeriodTaskListView = {
        let view = HabitPeriodTaskListView(frame: view.bounds)
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
        
        view.addSubview(weekView)
        view.addSubview(listView)
        view.addSubview(filterButton)
        view.addSubview(addView)
        reloadData()
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
        addView.bottom = layoutFrame.maxY - edgeMargins.bottom
        
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

    // MARK: - Public
    func reloadData() {
        updateAddView()
        weekView.reloadData()
        listView.asyncReloadData()
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
        listView.asyncReloadData(animateStyle: style)
    }
    
    func updateAddView() {
        if date.isToday {
            addView.showAddButton()
        }else{
            if date.compare(.now) == .orderedAscending {
                addView.showLeftBackButton()
            } else {
                addView.showRightBackButton()
            }
        }
    }
    
    // MARK: - Event Response
    private func selectFilterType(_ filterType: HabitTaskFilterType) {
        self.filterType = filterType
        /// 更新列表
        self.listView.asyncPerformUpdate()
    }
    
    @objc func didClickBack(_ button: UIButton) {
        let fromDate = self.date
        self.date = .now
        updateWeekView(with: date)
        updateListView(fromDate: fromDate, toDate: self.date)
        updateAddView()
    }
    
    @objc func didClickAdd(_ button: UIButton){
        processor.createNewTask()
    }
    
    // MARK: - TPCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        guard let selectedDate = Date.dateFromComponents(date) else {
            return
        }
        
        let fromDate = self.date
        self.date = selectedDate
        self.updateListView(fromDate: fromDate, toDate: self.date)
        self.updateAddView()
    }
    
     // MARK: - HabitPeriodTaskListViewDelegate
    func habitPeriodTaskListView(_ listView: HabitPeriodTaskListView, fetchTaskGroups completion: @escaping ([HabitTaskGroup]?) -> Void) {
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
    
    // MARK: - HabitTaskListInfoCellDelegate
    func habitTaskListInfoCell(_ cell: HabitTaskListDefaultInfoCell, didClickMore button: UIButton) {
        guard let cell = cell as? HabitHomeDayListCell, let task = cell.task else {
            return
        }
        
        let habitTask = task.habitTask
        let date = task.period.date
        let status = task.status(on: date)
        let record = task.record(on: date)
        let menuController = HabitHomeDayMenuController(task: habitTask,
                                                        status: status,
                                                        date: date)
        menuController.didSelectMenuActionType = {[weak self] type in
            self?.processor.performMenuAction(type,
                                              for: habitTask,
                                              on: date,
                                              with: record,
                                              from: button)
        }
        
        menuController.showMenu(from: button)
    }
    
    func habitHomeDayListCell(_ cell: HabitHomeDayListCell, didClickRecord button: UIButton) {
        guard let task = cell.task else {
            return
        }
        
        let habitTask = task.habitTask
        let date = task.period.date
        processor.clickRecrod(for: habitTask, on: date)
    }
}

extension HabitHomeDayViewController: HabitTaskProcessorDelegate,
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
        self.updateCell(for: task, with: change)
        let status = task.status(with: record)
        if status != .inProgress {
            callback(after: 0.4) {
                self.listView.asyncPerformUpdate()
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
            self.listView.asyncPerformUpdate()
        }
    }
    
    private func updateCell(for task: HabitTask, with change: HabitRecordChange?) {
        guard let cell = listView.cell(for: task) as? HabitHomeDayListCell else {
            return
        }
        
        cell.updateRecord(with: change, animated: true)
    }
}

