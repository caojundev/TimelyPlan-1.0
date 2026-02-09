//
//  FocusTimelineDayPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation

class FocusTimelineDayPageView: CalendarDatePageView, FocusTimelineEventListDelegate {
    
    /// 滚动同步器
    private lazy var synchronizer: FocusTimelineSynchronizer = {
        return FocusTimelineSynchronizer()
    }()
    
    override func getDates() -> [Date] {
        var dates: [Date] = [visibleDate]
        for i in 1...kNearItemsCount {
            let leftDate = visibleDate.dateByAddingDays(-i)!
            dates.insert(leftDate, at: 0)
            let rightDate = visibleDate.dateByAddingDays(i)!
            dates.append(rightDate)
        }

        return dates
    }
    
    override func validatedDate(_ date: Date) -> Date {
        return date.startOfDay()
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return FocusTimelineDayTimelineCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        /// 需要立即布局以解决滚动跳动的问题
        cell.layoutIfNeeded()
        
        guard let cell = cell as? FocusTimelineDayTimelineCell else {
            return
        }
        
        let timelineView = cell.timelineView
        timelineView.delegate = self
        
        let date = adapter.item(at: indexPath) as! Date
        timelineView.date = date
        timelineView.reloadData()

        /// 将时间线视图添加到同步器
        synchronizer.addTimelineView(timelineView)
    }
    
    // MARK: - FocusTimelineEventListDelegate
    func timelineEvents(for date: Date) -> [FocusTimelineEvent]? {
        debugPrint("获取日期事件\(date.yearMonthDayString)")
        
        let calendar = Calendar.current
        let now = date
        let events = [
            FocusTimelineEvent(name: "晨会",
                               color: CalendarEventColor.random,
                               startDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!,
                               endDate: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now)!,
                               focusDuration: 15*60),
            FocusTimelineEvent(name: "产品评审产品评审产品评审产品评审",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 10, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 40, second: 0, of: now)!,
                               focusDuration: 90*60),
            
            FocusTimelineEvent(name: "开发 Coding",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 10, minute: 00, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!,
                               focusDuration: 30*60),
            
            FocusTimelineEvent(name: "阅读",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 13, minute: 00, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 15, minute: 40, second: 0, of: now)!,
                               focusDuration: 160*60),
        ]
        
        
        return events
    }
}

class FocusTimelineDayTimelineCell: TPCollectionCell {
    
    let timelineView = FocusTimelineView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(timelineView)
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
        timelineView.reset()
    }
}
