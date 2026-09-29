//
//  CalendarPanelPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/29.
//

import Foundation
import UIKit

class CalendarPanelPageView: TPDayPageView {
    
    /// 周开始日
    private(set) var firstWeekday: Weekday
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true

    struct Config {
        /// 左右条目数
        static let nearItemsCount = 6
    }
    
    init(visibleDate: Date = .now, firstWeekday: Weekday = .sunday) {
        self.firstWeekday = firstWeekday
        let visibleDate = visibleDate.startOfWeek(firstWeekday: firstWeekday)
        super.init(frame: .zero, visibleDate: visibleDate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func validatedDate(_ date: Date) -> Date {
        return date.startOfWeek(firstWeekday: firstWeekday).startOfDay()
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarPanelPageCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarPanelPageCell else {
            return
        }
        
        let date = adapter.item(at: indexPath) as! Date
        cell.date = date
        cell.reloadData()
    }
    
    override func getDates() -> [Date]? {
        let currentDate = visibleDate.startOfWeek(firstWeekday: firstWeekday)
        var dates: [Date] = [currentDate]
        for i in 1...Config.nearItemsCount {
            let leftDate = currentDate.dateByAddingWeeks(-i)!
            dates.insert(leftDate, at: 0)
            let rightDate = currentDate.dateByAddingWeeks(i)!
            dates.append(rightDate)
        }
        
        return dates
    }
}

class CalendarPanelPageCell: UICollectionViewCell {

    var date: Date? {
        get {
            return panelView.firstDay
        }
        
        set {
            panelView.firstDay = newValue
        }
    }
    
    private let panelView = CalendarPanelSingleView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(panelView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        panelView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func reloadData() {
        panelView.reloadData()
    }
    
}
