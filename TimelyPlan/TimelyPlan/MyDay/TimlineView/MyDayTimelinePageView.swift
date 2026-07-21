//
//  MyDayTimelinePageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/19.
//

import Foundation
import UIKit

class MyDayTimelinePageView: TPDayPageView {

    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return MyDayTimelinePageCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        
    }
}

class MyDayTimelinePageCell: TPDayPageCell {

    private var testEvents: [MyDayEvent] = []
    
    private lazy var timelineView: MyDayTimelineView = {
        let view = MyDayTimelineView(frame: bounds)
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 生成测试数据
        self.testEvents = MyDayEventFactory.createTestEvents()
        contentView.addSubview(timelineView)
        timelineView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timelineView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}


extension MyDayTimelinePageCell: TimelineViewDelegate {
    
    // MARK: - TimelineViewDelegate
    func timelineViewWillBeginDragging(_ timelineView: TimelineView) {
        
    }
    
    func timelineViewEvents(_ timelineView: TimelineView) -> [MyDayEvent] {
        return testEvents
    }
    
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent) {

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
