//
//  HabitHomeDayViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//

import Foundation
import UIKit

class HabitHomeDayViewController: TPContainerViewController,
                                  TPGroupCollectionViewDelegate,
                                  TPCalendarSingleDateSelectionDelegate,
                                  HabitHomeDayListCellDelegate,
                                  HabitRecordProcessorDelegate {
    
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
        button.didSelectFilterType = { [weak self] filterType in
            self?.viewModel.setFilterType(filterType)
        }
        
        return button
    }()
    
    private(set) lazy var listView: HabitPeriodItemListView = {
        let view = HabitPeriodItemListView(frame: view.bounds)
        view.delegate = self
        view.collectionConfiguration = { collectionView in
            collectionView.contentInset = UIEdgeInsets(bottom: 60.0)
        }
        
        view.placeholderProvider = self.viewModel.placeholderProvider
        return view
    }()
    
    private let processor = HabitTaskMenuActionProcessor()
    
    private lazy var viewModel: HabitDayPeriodItemViewModel = { [weak self] in
        let viewModel = HabitDayPeriodItemViewModel()
        viewModel.delegate = self
        viewModel.groupsDidChange = {
            self?.groupsChanged()
        }
        
        viewModel.firstWeekDidChange = {
            self?.reloadWeekView()
        }
        
        viewModel.midnightHandler = {
            self?.reloadWeekView()
        }
        
        return viewModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.filterType = viewModel.filterType
        view.addSubview(weekView)
        view.addSubview(listView)
        view.addSubview(filterButton)
        view.addSubview(backView)
        view.addSubview(addView)
        reloadData()
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

    private func groupsChanged() {
        DispatchQueue.main.async {
            self.listView.groups = self.viewModel.groups
            self.listView.performUpdate()
        }
    }
    
    // MARK: - Public
    func reloadData() {
        updateBackView()
        reloadWeekView()
        listView.reloadData()
        viewModel.loadGroups(on: self.date)
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
        
        let style = SlideStyle.horizontalStyle(fromValue: fromDate, toValue: toDate)
        self.listView.groups = nil
        self.listView.reloadData(animateStyle: style)
        self.viewModel.loadGroups(on: self.date)
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
    
    // MARK: - TPLoadableGroupCollectionViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitHomeDayListCell.self
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitHomeDayListCell
        cell.delegate = self
        cell.periodItem = listView.item(at: indexPath) as? HabitPeriodItem
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let periodItem = listView.item(at: indexPath) as? HabitPeriodItem else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        HabitPresenter.showStats(for: periodItem.habitTask, date: self.date)
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForHeaderInSection section: Int) -> AnyClass? {
        return HabitTaskListGroupHeaderView.self
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, sizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
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
    
    // MARK: - HabitRecordProcessorDelegate
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        updateCell(for: task, with: change)
    }
    
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        updateCell(for: task, with: nil)
    }
    
    private func updateCell(for task: HabitTask, with change: HabitRecordChange?) {
        guard let cell = listView.cell(for: task) as? HabitHomeDayListCell else {
            return
        }
        
        cell.updateRecord(with: change, animated: true)
    }
}
