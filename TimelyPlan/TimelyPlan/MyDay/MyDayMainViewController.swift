//
//  MyDayMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/13.
//

import Foundation
import UIKit

class MyDayMainViewController: TPViewController,
                               TPSidebarContent {

    var sidebarController: SidebarController?
    
    /// 单行周视图高度
    private let calendarWeekHeight: CGFloat = 60.0

    private lazy var calendarView: CalendarWeekMonthExpandView = {
        let firstWeekday = MyDaySetting.shared.firstWeekday
        let showLunar = MyDaySetting.shared.showLunar
        let showChineseHolidays = MyDaySetting.shared.showChineseHolidays
        let eventsInfoFetcher = MyDayRangeEventsInfoFetcher()
        let view = CalendarWeekMonthExpandView(frame: .zero,
                                               firstWeekday: firstWeekday,
                                               visibleDateComponents: date.yearMonthDayComponents,
                                               showLunar: showLunar,
                                               showChineseHolidays: showChineseHolidays,
                                               eventsInfoFetcher: eventsInfoFetcher)
        view.delegate = self
        return view
    }()
    
    private lazy var timelineView: MyDayTimelineView = {
        let view = MyDayTimelineView(frame: view.bounds)
        view.delegate = self
        return view
    }()
    
    /// 日期按钮
    lazy var dateButton: CalendarDateButton = {
        let button = CalendarDateButton()
        button.addTarget(self, action: #selector(clickDate(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: resGetImage("ellipsis_24"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickMore))
        return item
    }()
    
    private let contentView = UIView()
    
    private(set) var date: Date
    
    private var testEvents: [MyDayEvent] = []
    
    init(date: Date = .now) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
        
        // 生成测试数据
        self.testEvents = MyDayEventFactory.createTestEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
        navigationItem.titleView = dateButton
        view.addSubview(contentView)
        contentView.addSubview(timelineView)
        contentView.addSubview(calendarView)
        updateTitle(with: date)
        MyDaySetting.shared.addObserver(self)
        timelineView.reloadData()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = view.bounds
        layoutContents()
    }

    private func layoutContents() {
        calendarView.width = view.bounds.width
        calendarView.height = calendarView.contentHeight
        
        timelineView.width = view.bounds.width
        timelineView.height = view.height - calendarView.height
        timelineView.top = calendarView.bottom
    }
    
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
        dateButton.sizeToFit()
    }
    
    // MARK: - Event Response
    @objc private func clickMore() {
        TPImpactFeedback.impactWithSoftStyle()
        MyDayPresenter.showSetting()
    }
    
    @objc func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = date
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        updateTitle(with: date)
        calendarView.setVisibleDateComponents(date.yearMonthDayComponents, animated: true)
    }
}

extension MyDayMainViewController: MyDayTimelineViewDelegate {
    
    // MARK: - MyDayTimelineViewDelegate
    func timelineViewEvents(_ timelineView: MyDayTimelineView) -> [MyDayEvent] {
        return testEvents
    }
    
    func timelineView(_ timelineView: MyDayTimelineView, didSelectEvent event: MyDayEvent) {
        let completedText = event.isCompleted ? "✅ 已完成" : "⏳ 进行中"
        
        print("=======================================")
        print("Selected Event:")
        print("  Title: \(event.title ?? "N/A")")
        print("  ID: \(event.identifier)")
        print("  Source: \(event.source)")
        print("  Color: \(event.color)")
        print("  Start: \(event.startDate)")
        print("  End: \(event.endDate)")
        print("  Completed: \(completedText)")
        print("=======================================")
        
        // 示例：显示一个 Alert
        let sourceName = getSourceName(for: event.source)
        let alert = UIAlertController(
            title: event.title,
            message: "来源: \(sourceName)\n开始: \(formatDate(event.startDate))\n结束: \(formatDate(event.endDate))\n状态: \(completedText)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func getSourceName(for source: MyDayEventSource) -> String {
        switch source {
        case .todo:
            return "📋 待办任务"
        case .habit:
            return "🔄 习惯追踪"
        case .focus:
            return "⏱️ 专注计时"
        }
    }
}

extension MyDayMainViewController: SettingAgentObserver {
    
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = MyDaySetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .firstWeekday:
            let firstWeekday = MyDaySetting.shared.firstWeekday
            calendarView.setFirstWeekday(firstWeekday)
        case .showLunar:
            let showLunar = MyDaySetting.shared.showLunar
            calendarView.setShowLunar(showLunar)
        case .showChineseHolidays:
            let showChineseHolidays = MyDaySetting.shared.showChineseHolidays
            calendarView.setShowChineseHolidays(showChineseHolidays)
        default:
            break
        }
    }

}

extension MyDayMainViewController: CalendarWeekMonthExpandViewDelegate {
    
    func calendarWeekMonthExpandView(_ view: CalendarWeekMonthExpandView, didChangeVisibleDate dateComponents: DateComponents) {
        guard let date = Date.dateFromComponents(dateComponents) else {
            return
        }
        
        self.date = date
        updateTitle(with: date)
    }
    
    func calendarWeekMonthExpandView(_ view: CalendarWeekMonthExpandView, didSelectDate dateComponents: DateComponents) {
        guard let date = Date.dateFromComponents(dateComponents),
                !self.date.isInSameDayAs(date) else {
            return
        }

        self.date = date
        updateTitle(with: date)
//        reloadEvents(on: date, animated: true)
    }
    
    func calendarWeekMonthExpandViewFrameChanged(_ view: CalendarWeekMonthExpandView) {
        layoutContents()
    }
}

// 创建测试数据的工厂方法
struct MyDayEventFactory {
    
    static func createTestEvents() -> [MyDayEvent] {
        
        // 获取当前日期
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        var events: [MyDayEvent] = []
        
        // ====================================
        // 1. Wind Down - point 类型 (15分钟) - 习惯任务
        // ====================================
        let windDownStart = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: today)!
        let windDownEnd = calendar.date(bySettingHour: 8, minute: 45, second: 0, of: today)!
        
        let windDownEvent = MyDayEvent(
            identifier: "event-001",
            source: .habit,
            name: "Wind Down",
            color: TimelineLayoutManager.blueColor,
            startDate: windDownStart,
            endDate: windDownEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "habit-data-001"
        )
        events.append(windDownEvent)
        
        // ====================================
        // 2. Go Shopping - short 类型 (30分钟) - 待办任务
        // ====================================
        let shoppingStart = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: today)!
        let shoppingEnd = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: today)!
        
        let shoppingEvent = MyDayEvent(
            identifier: "event-002",
            source: .todo,
            name: "Go Shopping",
            color: TimelineLayoutManager.yellowColor,
            startDate: shoppingStart,
            endDate: shoppingEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "todo-task-001"
        )
        events.append(shoppingEvent)
        
        // ====================================
        // 3. 起床 - long 类型 (1小时30分钟) - 习惯任务
        // ====================================
        let wakeUpStart = calendar.date(bySettingHour: 21, minute: 45, second: 0, of: today)!
        let wakeUpEnd = calendar.date(bySettingHour: 23, minute: 15, second: 0, of: today)!
        
        let wakeUpEvent = MyDayEvent(
            identifier: "event-003",
            source: .habit,
            name: "起床",
            color: TimelineLayoutManager.greenColor,
            startDate: wakeUpStart,
            endDate: wakeUpEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "habit-alarm-001"
        )
        events.append(wakeUpEvent)
        
        // ====================================
        // 4. 晨间会议 - short 类型 (45分钟) - 待办任务 - 已完成
        // ====================================
        let meetingStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!
        let meetingEnd = calendar.date(bySettingHour: 9, minute: 45, second: 0, of: today)!
        
        let meetingEvent = MyDayEvent(
            identifier: "event-004",
            source: .todo,
            name: "Morning Standup",
            color: UIColor.systemPurple,
            startDate: meetingStart,
            endDate: meetingEnd,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "todo-task-002"
        )
        events.append(meetingEvent)
        
        // ====================================
        // 5. 深度工作 - long 类型 (2小时) - 专注计时器
        // ====================================
        let focusStart = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)!
        let focusEnd = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today)!
        
        let focusEvent = MyDayEvent(
            identifier: "event-005",
            source: .focus,
            name: "Deep Work Session",
            color: UIColor.systemOrange,
            startDate: focusStart,
            endDate: focusEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "focus-timer-001"
        )
        events.append(focusEvent)
        
        // ====================================
        // 6. 快速阅读 - point 类型 (20分钟) - 待办任务 - 已完成
        // ====================================
        let readingStart = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: today)!
        let readingEnd = calendar.date(bySettingHour: 10, minute: 50, second: 0, of: today)!
        
        let readingEvent = MyDayEvent(
            identifier: "event-006",
            source: .todo,
            name: "Read Chapter 5",
            color: UIColor.systemTeal,
            startDate: readingStart,
            endDate: readingEnd,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "todo-task-003"
        )
        events.append(readingEvent)
        
        // ====================================
        // 7. 冥想 - point 类型 (10分钟) - 习惯任务
        // ====================================
        let meditateStart = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: today)!
        let meditateEnd = calendar.date(bySettingHour: 7, minute: 10, second: 0, of: today)!
        
        let meditateEvent = MyDayEvent(
            identifier: "event-007",
            source: .habit,
            name: "Morning Meditation",
            color: UIColor.systemIndigo,
            startDate: meditateStart,
            endDate: meditateEnd,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "habit-data-002"
        )
        events.append(meditateEvent)
        
        // ====================================
        // 8. 午休 - short 类型 (1小时) - 习惯任务
        // ====================================
        let lunchStart = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
        let lunchEnd = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: today)!
        
        let lunchEvent = MyDayEvent(
            identifier: "event-008",
            source: .habit,
            name: "Lunch Break",
            color: UIColor.systemRed,
            startDate: lunchStart,
            endDate: lunchEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "habit-data-003"
        )
        events.append(lunchEvent)
        
        // ====================================
        // 9. 番茄钟 - short 类型 (25分钟) - 专注计时器
        // ====================================
        let pomodoroStart = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!
        let pomodoroEnd = calendar.date(bySettingHour: 14, minute: 25, second: 0, of: today)!
        
        let pomodoroEvent = MyDayEvent(
            identifier: "event-009",
            source: .focus,
            name: "Pomodoro Timer",
            color: UIColor.systemPink,
            startDate: pomodoroStart,
            endDate: pomodoroEnd,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "focus-timer-002"
        )
        events.append(pomodoroEvent)
        
        // ====================================
        // 10. 项目回顾 - long 类型 (1小时) - 待办任务
        // ====================================
        let reviewStart = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today)!
        let reviewEnd = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: today)!
        
        let reviewEvent = MyDayEvent(
            identifier: "event-010",
            source: .todo,
            name: "Project Review",
            color: UIColor.systemBlue,
            startDate: reviewStart,
            endDate: reviewEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "todo-task-004"
        )
        events.append(reviewEvent)
        
        // 返回按时间排序的事件列表
        return events.sorted { $0.startDate < $1.startDate }
    }
}
