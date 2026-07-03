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
    
    private static let monthTitleHeight: CGFloat = 20
    private static let weekdayHeaderHeight: CGFloat = 16
    private static let monthTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    private static let weekdayFont = UIFont.systemFont(ofSize: 9)
    private static let dayFont = UIFont.systemFont(ofSize: 10)
    
    static let lunarNewYearLineHeight = 1.8
    static let lunarFirstDayLineHeight = 1.0
    static let lunarFirstLineColor = UIColor.systemOrange
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(monthInfo: MonthInfo, todayDay: Int) {
        self.monthInfo = monthInfo
        self.todayDay = todayDay
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let monthInfo = monthInfo else { return }
        
        let width = bounds.width
        let dayWidth = width / 7.0
        
        // 计算日期区域高度
        let dateAreaTop = Self.monthTitleHeight + Self.weekdayHeaderHeight
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
        monthTitle.draw(at: CGPoint(x: titleX, y: 0), withAttributes: titleAttributes)
        
        // 2. 绘制星期头
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        let weekdayAttributes: [NSAttributedString.Key: Any] = [
            .font: Self.weekdayFont,
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        for (index, weekday) in weekdays.enumerated() {
            let weekdaySize = weekday.size(withAttributes: weekdayAttributes)
            let x = CGFloat(index) * dayWidth + (dayWidth - weekdaySize.width) / 2
            weekday.draw(at: CGPoint(x: x, y: Self.monthTitleHeight + 2), withAttributes: weekdayAttributes)
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
}

// MARK: - 年日历View
class CalendarYearView: UIView {
    private var collectionView: UICollectionView!
    private let baseYear = 1970
    private let totalSections = 200 // 覆盖1900-2099年

    private var currentYear: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: Date())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCollectionView()
        scrollToCurrentYear(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        // 使用自定义布局，所有布局参数都在布局内部
        let collectionLayout = CalendarYearCollectionLayout()
        collectionLayout.minimumItemsPerRow = 3
        collectionLayout.maximumItemsPerRow = 4
        collectionLayout.preferredMinimumSpacing = 4.0
        collectionLayout.preferredSectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        collectionLayout.yearHeaderHeight = 80
        collectionLayout.monthAspectRatio = 1.4
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MonthCell.self, forCellWithReuseIdentifier: "MonthCell")
        collectionView.register(CalendarYearHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "YearHeader")
        collectionView.showsVerticalScrollIndicator = true
        
        addSubview(collectionView)
        
        /// 跳转到今年
        DispatchQueue.main.async { [weak self] in
            self?.scrollToCurrentYear(animated: false)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    
    func scrollToCurrentYear(animated: Bool) {
        let section = currentYear - baseYear
        guard section >= 0 && section < totalSections else { return }
        
        if animated {
            let indexPath = IndexPath(item: 0, section: section)
            if let attributes = collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: indexPath
            ) {
                let offsetY = attributes.frame.origin.y - collectionView.contentInset.top
                collectionView.setContentOffset(CGPoint(x: 0, y: max(0, offsetY)), animated: true)
            }
        } else {
            // 无动画方式：直接设置 contentOffset
            let indexPath = IndexPath(item: 0, section: section)
            if let attributes = collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: indexPath
            ) {
                let offsetY = attributes.frame.origin.y - collectionView.contentInset.top
                collectionView.contentOffset = CGPoint(x: 0, y: max(0, offsetY))
            }
        }
    }
    
    // MARK: - 公开方法
    func goToToday() {
        scrollToCurrentYear(animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension CalendarYearView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return totalSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath) as! MonthCell
        
        let year = baseYear + indexPath.section
        let month = indexPath.item + 1
        let monthInfo = CalendarCache.shared.getMonthInfo(year: year, month: month)
        
        let calendar = Calendar.current
        let todayDay = calendar.component(.day, from: Date())
        
        cell.configure(monthInfo: monthInfo, todayDay: todayDay)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "YearHeader",
            for: indexPath
        ) as! CalendarYearHeaderView
        
        let year = baseYear + indexPath.section
        header.configure(year: year)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let year = baseYear + indexPath.section
        let month = indexPath.item + 1
        print("选中: \(year)年\(month)月")
        // 这里可以跳转到月视图
    }
}

// MARK: - UIScrollViewDelegate 预加载
extension CalendarYearView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCenter = CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)
        if let indexPath = collectionView.indexPathForItem(at: visibleCenter) {
            let year = baseYear + indexPath.section
            CalendarCache.shared.preloadNearbyYears(currentYear: year)
        }
    }
}

class CalendarYearViewController: UIViewController {
    private var calendarYearView: CalendarYearView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "年日历"
        
        calendarYearView = CalendarYearView(frame: view.bounds)
        calendarYearView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(calendarYearView)
        
        // 立即布局，确保 frame 正确
        calendarYearView.layoutIfNeeded()
        
        // 无动画滚动到今年
        calendarYearView.scrollToCurrentYear(animated: false)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "今天",
            style: .plain,
            target: self,
            action: #selector(goToToday)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保在视图出现前再次确认位置
        if calendarYearView != nil {
            calendarYearView.scrollToCurrentYear(animated: false)
        }
    }
    
    @objc private func goToToday() {
        calendarYearView.scrollToCurrentYear(animated: true)
    }
}
