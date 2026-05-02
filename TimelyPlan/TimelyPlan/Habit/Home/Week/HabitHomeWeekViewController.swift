//
//  HabitHomeWeekViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

class HabitHomeWeekViewController: TPViewController,
                                   TPGroupCollectionViewDelegate,
                                   TPPreviousNextDateViewDelegate,
                                   HabitHomeWeekListCellDelegate,
                                   HabitRecordProcessorDelegate {
    
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
        view.placeholderProvider = self.viewModel.placeholderProvider
        view.collectionConfiguration = { collectionView in
            collectionView.contentInset = UIEdgeInsets(bottom: 60.0)
        }
        
        view.refreshHandler = { [weak self] in
            self?.handleRefresh()
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
    
    private let dayMenuController = HabitDayMenuController()
    
    private let processor = HabitTaskMenuActionProcessor()
    
    private lazy var viewModel: HabitWeekPeriodItemViewModel = { [weak self] in
        let viewModel = HabitWeekPeriodItemViewModel()
        viewModel.delegate = self
        viewModel.groupsDidChange = {
            self?.groupsChanged()
        }
        
        viewModel.firstWeekDidChange = {
            self?.firstWeekdayChanged()
        }
        
        viewModel.midnightHandler = {
            self?.updateAtMidnight()
        }
        
        return viewModel
    }()
    
    var period: HabitDatePeriod {
        let firstWeekday = self.dateView.firstWeekday
        return HabitDatePeriod(date: self.date,
                               mode: .week,
                               firstWeekday: firstWeekday)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(dateView)
        view.addSubview(listView)
        view.addSubview(backView)
        view.addSubview(addView)
        updateBackView()
        listView.reloadData()
        viewModel.loadGroups(in: period)
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
    
    
    private func handleRefresh() {
        viewModel.loadGroups(forceRefresh: true)
    }
    
    // MARK: - Event Response
    private func groupsChanged() {
        DispatchQueue.main.async {
            self.listView.groups = self.viewModel.groups
            self.listView.performUpdate()
        }
    }
    
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
    
    func firstWeekdayChanged() {
        self.dateView.firstWeekday = HabitSetting.shared.firstWeekday
        self.viewModel.loadGroups(in: self.period, forceRefresh: true)
    }
    
    func updateAtMidnight() {
        guard self.dateView.dateRange.contains(date: .now) else {
            return
        }
        
        /// 更新单元格的可用状态
        guard let visibleCells = listView.visibleCells as? [HabitHomeWeekListCell] else {
            return
        }
        
        for cell in visibleCells {
            cell.reloadWeekday(of: .now)
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
        
        let style: SlideStyle = .horizontalStyle(fromValue: oldDate, toValue: date)
        self.listView.groups = nil
        self.listView.reloadData(animateStyle: style)
        self.viewModel.loadGroups(in: self.period)
        self.listView.updatePlaceholderView()
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
    
    // MARK: - TPGroupCollectionViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitHomeWeekListCell.self
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitHomeWeekListCell
        cell.delegate = self
        cell.periodItem = listView.item(at: indexPath) as? HabitPeriodItem
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForHeaderInSection section: Int) -> AnyClass? {
        return HabitTaskListGroupHeaderView.self
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, sizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        if let headerView = headerView as? HabitTaskListGroupHeaderView {
            headerView.contentPadding = UIEdgeInsets(top: 10.0, bottom: 0.0)
            headerView.group = listView.sectionObject(at: section) as? HabitTaskGroup
        }
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let task = listView.item(at: indexPath) as? HabitPeriodItem else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        HabitPresenter.showStats(for: task.habitTask, date: .now)
    }
    
    // MARK: - HabitRecordProcessorDelegate
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        updateCell(for: task, with: change)
    }
    
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        updateCell(for: task, with: nil)
    }
    
    private func updateCell(for task: HabitTask, with change: HabitRecordChange?) {
        guard let cell = listView.cell(for: task) as? HabitHomeWeekListCell else {
            return
        }
        
        cell.updateRecords(in: period, animated: true)
    }
}
