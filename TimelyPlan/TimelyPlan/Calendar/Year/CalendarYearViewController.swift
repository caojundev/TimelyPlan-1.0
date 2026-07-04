//
//  CalendarYearViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/3.
//

import Foundation
import UIKit

// MARK: - 农历工具类
struct LunarCalendar {
    private static let chineseCalendar = Calendar(identifier: .chinese)
    private static let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    private static let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    private static let zodiac = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    
    // 判断是否为农历初一
    static func isLunarFirstDay(date: Date) -> Bool {
        let components = chineseCalendar.dateComponents([.day], from: date)
        return components.day == 1
    }
    
    // 判断是否为农历正月初一
    static func isLunarNewYear(date: Date) -> Bool {
        let components = chineseCalendar.dateComponents([.month, .day], from: date)
        return components.month == 1 && components.day == 1
    }
    
    // 获取农历年份的干支生肖描述
    static func getChineseYearDescription(year: Int) -> String {
        let stemIndex = (year - 4) % 10
        let branchIndex = (year - 4) % 12
        return "\(heavenlyStems[stemIndex])\(earthlyBranches[branchIndex])\(zodiac[branchIndex])年"
    }
    
    // 获取某月的所有农历初一日
    static func getLunarFirstDays(year: Int, month: Int) -> Set<Int> {
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: year, month: month)
        dateComponents.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        var lunarFirstDays = Set<Int>()
        
        for day in 1...range.count {
            dateComponents.day = day
            if let date = calendar.date(from: dateComponents),
               isLunarFirstDay(date: date) {
                lunarFirstDays.insert(day)
            }
        }
        
        return lunarFirstDays
    }
}

// MARK: - 数据模型
struct MonthInfo {
    let year: Int
    let month: Int
    let daysCount: Int
    let firstWeekday: Int // 1=周日, 2=周一...7=周六
    let containsToday: Bool
    let lunarFirstDays: Set<Int> // 农历初一对应的公历日期
    
    var yearMonth: String {
        return "\(year)-\(String(format: "%02d", month))"
    }
}

// MARK: - 缓存管理器
class CalendarCache {
    static let shared = CalendarCache()
    private var cache = NSCache<NSString, MonthInfoWrapper>()
    
    class MonthInfoWrapper {
        let info: MonthInfo
        init(_ info: MonthInfo) {
            self.info = info
        }
    }
    
    func getMonthInfo(year: Int, month: Int) -> MonthInfo {
        let key = "\(year)-\(month)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached.info
        }
        
        let info = calculateMonthInfo(year: year, month: month)
        cache.setObject(MonthInfoWrapper(info), forKey: key)
        return info
    }
    
    private func calculateMonthInfo(year: Int, month: Int) -> MonthInfo {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        
        guard let date = calendar.date(from: dateComponents) else {
            return MonthInfo(year: year, month: month, daysCount: 30, firstWeekday: 1, containsToday: false, lunarFirstDays: [])
        }
        
        // 获取该月天数
        let range = calendar.range(of: .day, in: .month, for: date)
        let daysCount = range?.count ?? 30
        
        // 获取该月第一天是周几
        var firstDateComponents = calendar.dateComponents([.year, .month], from: date)
        firstDateComponents.day = 1
        guard let firstDay = calendar.date(from: firstDateComponents) else {
            return MonthInfo(year: year, month: month, daysCount: daysCount, firstWeekday: 1, containsToday: false, lunarFirstDays: [])
        }
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        // 检查是否包含今天
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let containsToday = (year == todayComponents.year && month == todayComponents.month)
        
        // 计算该月的农历初一日期
        let lunarFirstDays = LunarCalendar.getLunarFirstDays(year: year, month: month)
        
        return MonthInfo(
            year: year,
            month: month,
            daysCount: daysCount,
            firstWeekday: firstWeekday,
            containsToday: containsToday,
            lunarFirstDays: lunarFirstDays
        )
    }
    
    func preloadNearbyYears(currentYear: Int) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            for year in (currentYear - 2)...(currentYear + 2) {
                for month in 1...12 {
                    _ = self.getMonthInfo(year: year, month: month)
                }
            }
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - 月视图Cell
class MonthCell: UICollectionViewCell {
    private var monthInfo: MonthInfo?
    private var todayDay: Int = 0
    
    // 上次绘制的宽度，用于检测是否需要重绘
    private var lastDrawnWidth: CGFloat = 0
    
    // 字体基础比例（以最小宽度120pt为基准）
    private static let baseWidth: CGFloat = 120.0
    private static let baseMonthTitleSize: CGFloat = 14.0
    private static let baseWeekdaySize: CGFloat = 9.0
    private static let baseDaySize: CGFloat = 10.0
    
    // 字体缩放比例
    private static var monthTitleScale: CGFloat = 1.0
    private static var weekdayScale: CGFloat = 1.0
    private static var dayScale: CGFloat = 1.0
    
    // 当前使用的字体
    private static var monthTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    private static var weekdayFont = UIFont.systemFont(ofSize: 9)
    private static var dayFont = UIFont.systemFont(ofSize: 10)
    
    // 上次更新字体时的宽度
    private static var lastFontUpdateWidth: CGFloat = 0
    
    // 标题和星期头高度（会根据字体动态调整）
    private static var monthTitleHeight: CGFloat = 20
    private static var weekdayHeaderHeight: CGFloat = 16
    
    // 布局常量
    private static let monthTitleToWeekdaySpacing: CGFloat = 2.0
    
    // 农历横线属性
    static let lunarNewYearLineHeight: CGFloat = 1.8
    static let lunarFirstDayLineHeight: CGFloat = 1.0
    static let lunarFirstLineColor = UIColor.systemOrange
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentWidth = bounds.width
        
        // 检查宽度是否发生变化
        if abs(currentWidth - lastDrawnWidth) > 0.5 {
            lastDrawnWidth = currentWidth
            updateFontsIfNeeded()
            setNeedsDisplay()
        }
    }
    
    func configure(monthInfo: MonthInfo, todayDay: Int) {
        self.monthInfo = monthInfo
        self.todayDay = todayDay
        
        // 检查是否需要更新
        let currentWidth = bounds.width
        if currentWidth > 0 && abs(currentWidth - lastDrawnWidth) > 0.5 {
            lastDrawnWidth = currentWidth
            updateFontsIfNeeded()
        }
        
        setNeedsDisplay()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        monthInfo = nil
        todayDay = 0
        lastDrawnWidth = 0
    }
    
    private func updateFontsIfNeeded() {
        let width = bounds.width
        guard width > 0 else { return }
        
        // 计算缩放比例（限制在0.8到1.5之间）
        let scale = min(1.5, max(0.8, width / Self.baseWidth))
        
        // 检查是否需要更新字体（宽度变化超过1pt才更新）
        if abs(width - Self.lastFontUpdateWidth) > 1.0 {
            Self.lastFontUpdateWidth = width
            
            Self.monthTitleScale = scale
            Self.weekdayScale = scale
            Self.dayScale = scale
            
            // 更新字体
            let monthFontSize = Self.baseMonthTitleSize * scale
            let weekdayFontSize = Self.baseWeekdaySize * scale
            let dayFontSize = Self.baseDaySize * scale
            
            Self.monthTitleFont = UIFont.systemFont(ofSize: monthFontSize, weight: .medium)
            Self.weekdayFont = UIFont.systemFont(ofSize: weekdayFontSize)
            Self.dayFont = UIFont.systemFont(ofSize: dayFontSize)
            
            // 更新标题和星期头高度
            let monthTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: Self.monthTitleFont
            ]
            let sampleText = "12月"
            let titleSize = sampleText.size(withAttributes: monthTitleAttributes)
            Self.monthTitleHeight = ceil(titleSize.height)
            
            let weekdayAttributes: [NSAttributedString.Key: Any] = [
                .font: Self.weekdayFont
            ]
            let weekdaySize = "日".size(withAttributes: weekdayAttributes)
            Self.weekdayHeaderHeight = ceil(weekdaySize.height)
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let monthInfo = monthInfo else { return }
        
        let width = bounds.width
        let dayWidth = width / 7.0
        
        // 计算日期区域高度
        let dateAreaTop = Self.monthTitleHeight + Self.monthTitleToWeekdaySpacing + Self.weekdayHeaderHeight
        let dateAreaHeight = bounds.height - dateAreaTop
        let dayHeight = dateAreaHeight / 6.0 // 固定按6行计算
        
        // 1. 绘制月份标题
        let monthTitle = "\(monthInfo.month)月"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: Self.monthTitleFont,
            .foregroundColor: monthInfo.containsToday ? UIColor.systemRed : UIColor.label
        ]
        
        let titleSize = monthTitle.size(withAttributes: titleAttributes)
        let titleX = (width - titleSize.width) / 2
        let titleY = (Self.monthTitleHeight - titleSize.height) / 2
        monthTitle.draw(at: CGPoint(x: titleX, y: titleY), withAttributes: titleAttributes)
        
        // 2. 绘制星期头
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        let weekdayAttributes: [NSAttributedString.Key: Any] = [
            .font: Self.weekdayFont,
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        for (index, weekday) in weekdays.enumerated() {
            let weekdaySize = weekday.size(withAttributes: weekdayAttributes)
            let x = CGFloat(index) * dayWidth + (dayWidth - weekdaySize.width) / 2
            let y = Self.monthTitleHeight + Self.monthTitleToWeekdaySpacing
            weekday.draw(at: CGPoint(x: x, y: y), withAttributes: weekdayAttributes)
        }
        
        // 3. 绘制日期
        let dayAttributes: [NSAttributedString.Key: Any] = [
            .font: Self.dayFont,
            .foregroundColor: UIColor.label
        ]
        
        let todayAttributes: [NSAttributedString.Key: Any] = [
            .font: Self.dayFont,
            .foregroundColor: UIColor.white
        ]
        
        let weekendAttributes: [NSAttributedString.Key: Any] = [
            .font: Self.dayFont,
            .foregroundColor: UIColor.systemGray3
        ]
        
        for day in 1...monthInfo.daysCount {
            let position = day + monthInfo.firstWeekday - 2
            let col = position % 7
            let row = position / 7
            
            let cellX = CGFloat(col) * dayWidth
            let cellY = dateAreaTop + CGFloat(row) * dayHeight
            
            let dayString = "\(day)"
            let daySize = dayString.size(withAttributes: dayAttributes)
            let dayX = cellX + (dayWidth - daySize.width) / 2
            let dayY = cellY + (dayHeight - daySize.height) / 2
            
            // 判断是否今天
            if monthInfo.containsToday && day == todayDay {
                // 绘制圆形背景
                let circleDiameter = min(dayWidth, dayHeight) * 0.75
                let circleX = cellX + (dayWidth - circleDiameter) / 2
                let circleY = cellY + (dayHeight - circleDiameter) / 2
                let circleRect = CGRect(x: circleX, y: circleY, width: circleDiameter, height: circleDiameter)
                
                context.setFillColor(UIColor.systemRed.cgColor)
                context.fillEllipse(in: circleRect)
                
                dayString.draw(at: CGPoint(x: dayX, y: dayY), withAttributes: todayAttributes)
            } else {
                // 判断周末
                let attributes: [NSAttributedString.Key: Any]
                if col == 0 || col == 6 {
                    attributes = weekendAttributes
                } else {
                    attributes = dayAttributes
                }
                dayString.draw(at: CGPoint(x: dayX, y: dayY), withAttributes: attributes)
            }

            // 绘制农历横线
            if monthInfo.lunarFirstDays.contains(day) {
                let dateComponents = DateComponents(year: monthInfo.year, month: monthInfo.month, day: day)
                let date = Calendar.current.date(from: dateComponents)
                let isLunarNewYear = date.map { LunarCalendar.isLunarNewYear(date: $0) } ?? false
                
                let lineHeight: CGFloat = isLunarNewYear ? Self.lunarNewYearLineHeight : Self.lunarFirstDayLineHeight
                let lineY = cellY + dayHeight - lineHeight / 2
                let lineWidth = dayWidth * 0.6
                let lineX = cellX + (dayWidth - lineWidth) / 2
                
                context.setStrokeColor(Self.lunarFirstLineColor.cgColor)
                context.setLineWidth(lineHeight)
                context.move(to: CGPoint(x: lineX, y: lineY))
                context.addLine(to: CGPoint(x: lineX + lineWidth, y: lineY))
                context.strokePath()
            }
        }
    }
    
    // MARK: - 公开方法：获取当前cell高度
    static func estimatedHeight(for width: CGFloat) -> CGFloat {
        let scale = min(1.5, max(0.8, width / baseWidth))
        let titleHeight = baseMonthTitleSize * scale * 1.2
        let weekdayHeight = baseWeekdaySize * scale * 1.2
        let dateAreaHeight = width / 7.0 * 6.0
        
        return titleHeight + monthTitleToWeekdaySpacing + weekdayHeight + dateAreaHeight
    }
}


class CalendarYearViewController: TPViewController,
                                  CalendarTitleViewProvider {
    
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

    private var calendarYearView: CalendarYearView!
    
    private var currentYearDate: Date {
        let year = calendarYearView.currentDisplayYear
        let date = Date()
        return date.dateByReplacingYear(year)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarYearView = CalendarYearView(frame: view.bounds)
        calendarYearView.delegate = self
        calendarYearView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(calendarYearView)
        
        // 立即布局，确保 frame 正确
        calendarYearView.layoutIfNeeded()
        
        // 无动画滚动到今年
        calendarYearView.scrollToCurrentYear(animated: false)
        
        updateTitle()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保在视图出现前再次确认位置
        if calendarYearView != nil {
            calendarYearView.scrollToCurrentYear(animated: false)
        }
    }
    
    private func updateTitle() {
        dateButton.title = "\(calendarYearView.currentDisplayYear)"
    }

    @objc private func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController(mode: .yearOnly)
        datePickerVC.date = currentYearDate
        datePickerVC.yearRange = CalendarYearConfig.yearRange
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        let year = date.year
        guard calendarYearView.currentDisplayYear != year else {
            return
        }
        
        calendarYearView.scrollToYear(year: year, animated: true)
        updateTitle()
    }
}

// MARK: - CalendarYearViewDelegate
extension CalendarYearViewController: CalendarYearViewDelegate {
    
    func calendarYearView(_ view: CalendarYearView, didChangeYearTo year: Int) {
        print(year)
        // 更新标题
        updateTitle()
    }
}
