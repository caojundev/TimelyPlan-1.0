//
//  CalendarBaseViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/11.
//

import Foundation

class CalendarBaseViewController: TPViewController,
                                  CalendarTitleViewProvider,
                                    CalendarPageViewDelegate {

    /// 标题视图
    var titleView: UIView? {
        return dateButton
    }
    
    /// 日期按钮
    lazy var dateButton: CalendarDateButton = {
        let button = CalendarDateButton()
        button.addTarget(self, action: #selector(clickDate(_:)), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - AddView
    /// 添加视图按钮
    private let addViewSize = CGSize(width: 50.0, height: 50.0)
    
    /// 添加视图边界间距
    private let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
    
    /// 添加视图
    private var addView: TPAddView?

    /// 任务快速添加控制器
    private(set) lazy var quickAddManager: TodoTaskQuickAddManager = {
        let options = TodoQuickAddOptions(showMoreSetting: false,
                                          forbidContinuousAdd: true)
        let manager = TodoTaskQuickAddManager(containerViewController: self, options: options)
        return manager
    }()
    
    let eventProcessor = CalendarEventProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAddView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutAddView()
    }
    
    private func layoutAddView() {
        let layoutFrame = view.safeAreaFrame()
        if let addView = addView {
            addView.size = addViewSize
            addView.bottom = layoutFrame.maxY - addViewMargins.bottom
            addView.right = layoutFrame.maxX - addViewMargins.right
        }
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    // MARK: - AddView
    private func setupAddView() {
        if canAddTask() {
            let addView = TPAddView()
            addView.normalBackgroundColor = .primary
            addView.didClickAdd = { [weak self] _ in
                self?.clickAddTask()
            }
           
            self.addView = addView
            self.view.insertSubview(addView, at: 999)
        }
    }
    
    func canAddTask() -> Bool {
        return true
    }
    
    func quickAddTaskDate() -> Date {
        return .now
    }
    
    func calendarPageDateChanged(_ date: Date) {
        // 子类重写
    }
    
    // MARK: - Event Response
    @objc func clickDate(_ button: UIButton) {
        
    }
    
    /// 点击添加
    func clickAddTask() {
        TPImpactFeedback.impactWithLightStyle()
        
        // 检查并清理过期的草稿任务
        let date = quickAddTaskDate()
        showQuickAddTask(on: date)
    }

    func showQuickAddTask(on date: Date) {
        // 检查并清理过期的草稿任务
        if shouldClearDraftTask(with: date) {
            quickAddManager.clearDraftTask()
        }

        let task = quickAddTask(on: date)
        quickAddManager.show(with: task)
    }
    
    func showQuickAddTask(with dateRange: DateInterval) {
        quickAddManager.clearDraftTask()
        let task = quickAddTask(with: dateRange)
        quickAddManager.show(with: task)
    }
    
    /// 显示事项列表
    func showEventList(on date: Date) {
        let options = CalendarEventListOptions(date: date)
        CalendarPresenter.showEventList(with: options)
    }
    
    // MARK: - CalendarPageViewDelegate
    func calendarPageView(_ pageView: CalendarPageView, didTapEvent event: CalendarEvent) {
        eventProcessor.clickEvent(event)
    }
    
    func calendarPageView(_ pageView: CalendarPageView, didTapAllDayMoreOnDate date: Date) {
        showEventList(on: date)
    }
    
    func calendarPageView(_ pageView: CalendarPageView, createEventWithDateRange dateRange: DateInterval) {
        showQuickAddTask(with: dateRange)
    }
    
    func calendarPageView(_ pageView: CalendarPageView, updateEvent event: CalendarEvent, withDateRange dateRange: DateInterval, completion: @escaping ((Bool) -> Void)) {
        eventProcessor.updateEvent(event, with: dateRange, completion: completion)
    }
    
    func calendarPageView(_ pageView: CalendarPageView, didScrollTo date: Date) {
        calendarPageDateChanged(date)
    }
    
    func calendarPageViewWillEndDragging(_ pageView: CalendarPageView, withTargetDate date: Date) {
        calendarPageDateChanged(date)
    }
    
    // MARK: - Helpers
    private func quickAddTask(with dateRange: DateInterval) -> TodoQuickAddTask {
        let dateInfo = TaskDateInfo(startDate: dateRange.start,
                                    endDate: dateRange.end,
                                    isAllDay: false)
        let reminder = CalendarSetting.shared.timedEventReminder
        let schedule = TaskSchedule(dateInfo: dateInfo,
                                    reminder: reminder,
                                    repeatRule: nil)
        let task = TodoQuickAddTask()
        task.schedule = schedule
        return task
    }
    
    private func quickAddTask(on date: Date) -> TodoQuickAddTask {
        let dateInfo = TaskDateInfo(date: date)
        let reminder = CalendarSetting.shared.allDayEventReminder
        let schedule = TaskSchedule(dateInfo: dateInfo,
                                    reminder: reminder,
                                    repeatRule: nil)
        let task = TodoQuickAddTask()
        task.schedule = schedule
        return task
    }
    
    private func shouldClearDraftTask(with date: Date) -> Bool {
        guard let draftTask = quickAddManager.draftTask,
              let dateInfo = draftTask.schedule?.dateInfo else {
            return quickAddManager.draftTask != nil // 无日期信息的草稿需要清理
        }
        
        return !dateInfo.startDate.isInSameDayAs(date)
    }
}
