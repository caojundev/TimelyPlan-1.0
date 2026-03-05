//
//  HabitHomeDayViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//

import Foundation
import UIKit

class HabitHomeDayViewController: TPViewController,
                                      CalendarDatePageViewDelegate,
                                      TPCalendarSingleDateSelectionDelegate {
    
    /// 日期
    private(set) var date: Date = .now

    /// 周视图
    private let weekViewHeight = 90.0
    private lazy var weekView: TPCalendarScrollableWeekView = {
        let view = TPCalendarScrollableWeekView(frame: .zero)
        view.symbolStyle = .veryShort
        #warning("修改 firstWeekday")
        view.firstWeekday = .monday
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
    
    /// 翻页视图
    private lazy var pageView: HabitHomeDayPageView = {
        let view = HabitHomeDayPageView(frame: .zero)
        view.delegate = self
        return view
    }()
    
    private let taskController = HabitTaskController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(weekView)
        view.addSubview(pageView)
        view.addSubview(addView)
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        weekView.width = layoutFrame.width
        weekView.height = weekViewHeight
        weekView.top = layoutFrame.minY
        
        pageView.width = layoutFrame.width
        pageView.height = layoutFrame.height - weekViewHeight
        pageView.top = weekView.bottom
        
        addView.size = addViewSize
        addView.bottom = layoutFrame.maxY - addViewMargin
        addView.right = layoutFrame.maxX - addViewMargin
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
        pageView.reloadData()
        updateAddView()
    }
    
    // MARK: - Update
    private func updateWeekView(with date: Date, animated: Bool = true) {
        let dateComponents = date.yearMonthDayComponents
        selection.setSelectedDateComponents(dateComponents)
        weekView.setVisibleDateComponents(dateComponents, animated: animated)
    }
    
    private func updatePagingView(with date: Date, animated: Bool = true) {
        pageView.setVisibleDate(date, animated: animated)
    }
    
    // MARK: - TPCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        guard let selectedDate = Date.dateFromComponents(date) else {
            return
        }
        
        self.date = selectedDate
        updatePagingView(with: selectedDate)
        updateAddView()
    }
    
    // MARK: - CalendarDayPagingViewDelegate
    func calendarDayPagingViewWillEndDragging(_ pageView: CalendarDatePageView, withTargetDate targetDate: Date) {
        if self.date.isInSameDayAs(targetDate) {
            return
        }
            
        self.date = targetDate
        updateWeekView(with: targetDate)
        updateAddView()
    }
    
    // MARK: - Event Response
    @objc func didClickBack(_ button: UIButton) {
        self.date = .now
        updateWeekView(with: date)
        updatePagingView(with: date)
        updateAddView()
    }
    
    @objc func didClickAdd(_ button: UIButton){
        taskController.createNewTask()
    }

    // MARK: - UI Update
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
}

