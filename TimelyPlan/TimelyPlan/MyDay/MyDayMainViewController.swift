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

extension MyDayMainViewController: TimelineViewDelegate {
    
    // MARK: - TimelineViewDelegate
    func timelineViewWillBeginDragging(_ timelineView: BaseTimelineView) {
        calendarView.switchMode(.week, animated: true)
    }
    
    func timelineViewEvents(_ timelineView: BaseTimelineView) -> [MyDayEvent] {
        return testEvents
    }
    
    func timelineView(_ timelineView: BaseTimelineView, didSelectEvent event: MyDayEvent) {
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
        // 1. 冥想 - point 类型 (10分钟) - 独立节点 (independent)
        // ====================================
        let meditateStart = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: today)!
        let meditateEnd = calendar.date(bySettingHour: 7, minute: 10, second: 0, of: today)!
        
        let meditateEvent = MyDayEvent(
            identifier: "event-001",
            source: .habit,
            name: "Morning Meditation",
            color: CalendarEventColor.random,
            startDate: meditateStart,
            endDate: meditateEnd,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "habit-data-002"
        )
        events.append(meditateEvent)
        
        // ====================================
        // 2. Wind Down - point 类型 (15分钟) - connectToNext (与下一个事件重叠)
        // ====================================
        let windDownStart = calendar.date(bySettingHour: 7, minute: 5, second: 0, of: today)!
        let windDownEnd = calendar.date(bySettingHour: 7, minute: 20, second: 0, of: today)!
        
        let windDownEvent = MyDayEvent(
            identifier: "event-002",
            source: .habit,
            name: "Wind Down",
            color: CalendarEventColor.random,
            startDate: windDownStart,
            endDate: windDownEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "habit-data-001"
        )
        events.append(windDownEvent)
        
        // ====================================
        // 3. 晨间阅读 - short 类型 (30分钟) - connectToPrevious (与上一个事件重叠)
        // ====================================
        let readingStart = calendar.date(bySettingHour: 7, minute: 15, second: 0, of: today)!
        let readingEnd = calendar.date(bySettingHour: 7, minute: 45, second: 0, of: today)!
        
        let readingEvent = MyDayEvent(
            identifier: "event-003",
            source: .todo,
            name: "Morning Reading",
            color: CalendarEventColor.random,
            startDate: readingStart,
            endDate: readingEnd,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "todo-task-003"
        )
        events.append(readingEvent)
        
        // ====================================
        // 4. 晨间会议 - short 类型 (45分钟) - connectToBoth (与上下事件都重叠)
        // ====================================
        let meetingStart = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: today)!
        let meetingEnd = calendar.date(bySettingHour: 8, minute: 15, second: 0, of: today)!
        
        let meetingEvent = MyDayEvent(
            identifier: "event-004",
            source: .todo,
            name: "Morning Standup",
            color: CalendarEventColor.random,
            startDate: meetingStart,
            endDate: meetingEnd,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "todo-task-002"
        )
        events.append(meetingEvent)
        
        // ====================================
        // 5. 早餐时间 - short 类型 (40分钟) - connectToPrevious (与上一个事件重叠)
        // ====================================
        let breakfastStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today)!
        let breakfastEnd = calendar.date(bySettingHour: 8, minute: 40, second: 0, of: today)!
        
        let breakfastEvent = MyDayEvent(
            identifier: "event-005",
            source: .habit,
            name: "Breakfast Time",
            color: CalendarEventColor.random,
            startDate: breakfastStart,
            endDate: breakfastEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "habit-data-003"
        )
        events.append(breakfastEvent)
        
        // ====================================
        // 6. 专注工作 - long 类型 (1小时30分钟) - independent (独立节点)
        // ====================================
        let focusStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!
        let focusEnd = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: today)!
        
        let focusEvent = MyDayEvent(
            identifier: "event-006",
            source: .focus,
            name: "Deep Work Session",
            color: CalendarEventColor.random,
            startDate: focusStart,
            endDate: focusEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "focus-timer-001"
        )
        events.append(focusEvent)
        
        // ====================================
        // 7. 代码审查 - short 类型 (45分钟) - connectToBoth (与上下事件都重叠)
        // ====================================
        let codeReviewStart = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!
        let codeReviewEnd = calendar.date(bySettingHour: 10, minute: 45, second: 0, of: today)!
        
        let codeReviewEvent = MyDayEvent(
            identifier: "event-007",
            source: .todo,
            name: "Code Review",
            color: CalendarEventColor.random,
            startDate: codeReviewStart,
            endDate: codeReviewEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "todo-task-005"
        )
        events.append(codeReviewEvent)
        
        // ====================================
        // 8. 团队同步 - point 类型 (20分钟) - connectToPrevious (与上一个事件重叠)
        // ====================================
        let syncStart = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: today)!
        let syncEnd = calendar.date(bySettingHour: 10, minute: 50, second: 0, of: today)!
        
        let syncEvent = MyDayEvent(
            identifier: "event-008",
            source: .todo,
            name: "Team Sync",
            color: CalendarEventColor.random,
            startDate: syncStart,
            endDate: syncEnd,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "todo-task-006"
        )
        events.append(syncEvent)
        
        // ====================================
        // 9. 午休 - long 类型 (1小时) - independent (独立节点)
        // ====================================
        let lunchStart = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
        let lunchEnd = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: today)!
        
        let lunchEvent = MyDayEvent(
            identifier: "event-009",
            source: .habit,
            name: "Lunch Break",
            color: CalendarEventColor.random,
            startDate: lunchStart,
            endDate: lunchEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "habit-data-004"
        )
        events.append(lunchEvent)
        
        // ====================================
        // 10. 番茄钟1 - short 类型 (25分钟) - connectToNext (与下一个事件重叠)
        // ====================================
        let pomodoro1Start = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!
        let pomodoro1End = calendar.date(bySettingHour: 14, minute: 25, second: 0, of: today)!
        
        let pomodoro1Event = MyDayEvent(
            identifier: "event-010",
            source: .focus,
            name: "Pomodoro #1",
            color: CalendarEventColor.random,
            startDate: pomodoro1Start,
            endDate: pomodoro1End,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "focus-timer-002"
        )
        events.append(pomodoro1Event)
        
        // ====================================
        // 11. 番茄钟2 - short 类型 (25分钟) - connectToBoth (与上下事件都重叠)
        // ====================================
        let pomodoro2Start = calendar.date(bySettingHour: 14, minute: 15, second: 0, of: today)!
        let pomodoro2End = calendar.date(bySettingHour: 14, minute: 40, second: 0, of: today)!
        
        let pomodoro2Event = MyDayEvent(
            identifier: "event-011",
            source: .focus,
            name: "Pomodoro #2",
            color: CalendarEventColor.random,
            startDate: pomodoro2Start,
            endDate: pomodoro2End,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "focus-timer-003"
        )
        events.append(pomodoro2Event)
        
        // ====================================
        // 12. 番茄钟3 - point 类型 (20分钟) - connectToPrevious (与上一个事件重叠)
        // ====================================
        let pomodoro3Start = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: today)!
        let pomodoro3End = calendar.date(bySettingHour: 14, minute: 50, second: 0, of: today)!
        
        let pomodoro3Event = MyDayEvent(
            identifier: "event-012",
            source: .focus,
            name: "Pomodoro #3",
            color: CalendarEventColor.random,
            startDate: pomodoro3Start,
            endDate: pomodoro3End,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "focus-timer-004"
        )
        events.append(pomodoro3Event)
        
        // ====================================
        // 13. 项目回顾 - long 类型 (1小时30分钟) - independent (独立节点)
        // ====================================
        let reviewStart = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today)!
        let reviewEnd = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: today)!
        
        let reviewEvent = MyDayEvent(
            identifier: "event-013",
            source: .todo,
            name: "Project Review",
            color: CalendarEventColor.random,
            startDate: reviewStart,
            endDate: reviewEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "todo-task-004"
        )
        events.append(reviewEvent)
        
        // ====================================
        // 14. Go Shopping - short 类型 (30分钟) - connectToNext (与下一个事件重叠)
        // ====================================
        let shoppingStart = calendar.date(bySettingHour: 16, minute: 15, second: 0, of: today)!
        let shoppingEnd = calendar.date(bySettingHour: 16, minute: 45, second: 0, of: today)!
        
        let shoppingEvent = MyDayEvent(
            identifier: "event-014",
            source: .todo,
            name: "Go Shopping",
            color: CalendarEventColor.random,
            startDate: shoppingStart,
            endDate: shoppingEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "todo-task-001"
        )
        events.append(shoppingEvent)
        
        // ====================================
        // 15. 运动时间 - long 类型 (1小时) - connectToBoth (与上下事件都重叠)
        // ====================================
        let exerciseStart = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: today)!
        let exerciseEnd = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: today)!
        
        let exerciseEvent = MyDayEvent(
            identifier: "event-015",
            source: .habit,
            name: "Exercise Time",
            color: CalendarEventColor.random,
            startDate: exerciseStart,
            endDate: exerciseEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "habit-data-005"
        )
        events.append(exerciseEvent)
        
        // ====================================
        // 16. 散步 - point 类型 (20分钟) - connectToPrevious (与上一个事件重叠)
        // ====================================
        let walkStart = calendar.date(bySettingHour: 17, minute: 15, second: 0, of: today)!
        let walkEnd = calendar.date(bySettingHour: 17, minute: 35, second: 0, of: today)!
        
        let walkEvent = MyDayEvent(
            identifier: "event-016",
            source: .habit,
            name: "Evening Walk",
            color: CalendarEventColor.random,
            startDate: walkStart,
            endDate: walkEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "habit-data-006"
        )
        events.append(walkEvent)
        
        // ====================================
        // 17. 晚餐 - long 类型 (1小时) - independent (独立节点)
        // ====================================
        let dinnerStart = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)!
        let dinnerEnd = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today)!
        
        let dinnerEvent = MyDayEvent(
            identifier: "event-017",
            source: .habit,
            name: "Dinner Time",
            color: CalendarEventColor.random,
            startDate: dinnerStart,
            endDate: dinnerEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "habit-data-007"
        )
        events.append(dinnerEvent)
        
        // ====================================
        // 18. 晚间学习 - short 类型 (45分钟) - connectToNext (与下一个事件重叠)
        // ====================================
        let studyStart = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today)!
        let studyEnd = calendar.date(bySettingHour: 19, minute: 45, second: 0, of: today)!
        
        let studyEvent = MyDayEvent(
            identifier: "event-018",
            source: .todo,
            name: "Evening Study",
            color: CalendarEventColor.random,
            startDate: studyStart,
            endDate: studyEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "todo-task-007"
        )
        events.append(studyEvent)
        
        // ====================================
        // 19. 在线课程 - long 类型 (1小时) - connectToPrevious (与上一个事件重叠)
        // ====================================
        let courseStart = calendar.date(bySettingHour: 19, minute: 30, second: 0, of: today)!
        let courseEnd = calendar.date(bySettingHour: 20, minute: 30, second: 0, of: today)!
        
        let courseEvent = MyDayEvent(
            identifier: "event-019",
            source: .todo,
            name: "Online Course",
            color: CalendarEventColor.random,
            startDate: courseStart,
            endDate: courseEnd,
            isAllDay: false,
            isCompleted: false,
            sourceItem: "todo-task-008"
        )
        events.append(courseEvent)
        
        // ====================================
        // 20. 起床闹钟 - point 类型 (5分钟) - connectToNext (与下一个事件重叠)
        // ====================================
        let alarmStart = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today)!
        let alarmEnd = calendar.date(bySettingHour: 20, minute: 5, second: 0, of: today)!
        
        let alarmEvent = MyDayEvent(
            identifier: "event-020",
            source: .habit,
            name: "Alarm Check",
            color: CalendarEventColor.random,
            startDate: alarmStart,
            endDate: alarmEnd,
            isAllDay: false,
            isCompleted: true,
            sourceItem: "habit-alarm-001"
        )
        events.append(alarmEvent)
        
        // 返回按时间排序的事件列表
        return events.sorted { $0.startDate < $1.startDate }
    }
}
