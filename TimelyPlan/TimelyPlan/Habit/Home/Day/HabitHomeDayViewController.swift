//
//  HabitHomeDayViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//

import Foundation
import UIKit

class HabitHomeDayViewController: TPContainerViewController,
                                  HabitTaskListViewDelegate,
                                  HabitTaskListInfoCellDelegate,
                                  TPCalendarSingleDateSelectionDelegate {
    
    /// 日期
    private(set) var date: Date = .now

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
            
    /// 返回和添加按钮视图
    private let addViewSize = CGSize(width: 40.0, height: 40.0)
    private let addViewMargin = 15.0
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
    
    private(set) lazy var listView: HabitTaskListView = {
        let view = HabitTaskListView(frame: view.bounds)
        view.delegate = self
        view.collectionConfiguration = { collectionView in
            collectionView.contentInset = UIEdgeInsets(bottom: 60.0)
        }
        
        return view
    }()
    
    private let taskController = HabitTaskController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(weekView)
        view.addSubview(listView)
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
        
        addView.size = addViewSize
        addView.bottom = layoutFrame.maxY - addViewMargin
        addView.right = layoutFrame.maxX - addViewMargin
        
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
        weekView.reloadData()
        listView.reloadData()
        updateAddView()
    }
    
    // MARK: - Update
    private func updateWeekView(with date: Date, animated: Bool = true) {
        let dateComponents = date.yearMonthDayComponents
        selection.setSelectedDateComponents(dateComponents)
        weekView.setVisibleDateComponents(dateComponents, animated: animated)
    }
    
    private func updateListView(fromDate: Date, toDate: Date) {
        if fromDate.isInSameDayAs(toDate) {
            listView.reloadData()
        }
        
        let slideStyle = SlideStyle.horizontalStyle(fromValue: fromDate,
                                                    toValue: toDate)
        listView.reloadData(animateStyle: slideStyle)
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
    @objc func didClickBack(_ button: UIButton) {
        let fromDate = self.date
        self.date = .now
        updateWeekView(with: date)
        updateListView(fromDate: fromDate, toDate: self.date)
        updateAddView()
    }
    
    @objc func didClickAdd(_ button: UIButton){
        taskController.createNewTask()
    }
    
    // MARK: - TPCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        guard let selectedDate = Date.dateFromComponents(date) else {
            return
        }
        
        let fromDate = self.date
        self.date = selectedDate
        updateListView(fromDate: fromDate, toDate: self.date)
        updateAddView()
    }
    
    
     // MARK: - HabitTaskListViewDelegate
    func groupsInHabitTaskListView(_ listView: HabitTaskListView) -> [HabitTaskGroup]? {
        let group = HabitTaskGroup(identifier: "active")
        group.iconName = HabitTimeOption.evening.iconName
        group.name = HabitTimeOption.evening.title
        group.tasks = habit.activeTasks()
        return [group]
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitHomeDayListCell.self
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitHomeDayListCell
        cell.delegate = self
        cell.task = listView.item(at: indexPath) as? HabitTask
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
        guard let task = cell.task else {
            return
        }
        
        
        let menuController = HabitHomeDayMenuController(task: task, date: self.date)
        menuController.didSelectMenuActionType = { type in
            self.performMenuAction(type, forTask: task)
        }
        
        menuController.showMenu(from: button)
    }
    
    func performMenuAction(_ type: HabitTaskMenuActionType, forTask task: HabitTask) {
        switch type {
        case .edit:
            taskController.editTask(task)
        case .archive:
            taskController.archiveTask(task)
        case .delete:
            taskController.deleteTask(task)
        default:
            break
        }
    }
}

extension HabitHomeDayViewController: HabitTaskProcessorDelegate {
    
    func didCreateHabitTask(_ task: HabitTask) {
        self.listView.performUpdate {[weak self] _ in
            guard let self = self else { return }
            self.listView.revealTask(task)
        }
    }

    func didUpdateHabitTask(_ task: HabitTask) {
        self.listView.reloadCell(forTask: task, focusAnimated: true)
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        self.listView.performUpdate()
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        self.listView.performUpdate()
    }
    
    func didReorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        self.listView.performUpdate()
    }
}

