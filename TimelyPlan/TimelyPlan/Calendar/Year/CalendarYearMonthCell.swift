//
//  CalendarYearMonthCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/4.
//

import Foundation
import UIKit

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

// MARK: - 事项相关数据模型

/// 天事项绘制信息
struct CalendarDayEventInfo {
    let day: Int
    let indicatorColors: [UIColor] // 事项指示颜色数组，空数组表示没有事项
}

/// 月事项绘制信息
struct CalendarMonthEventsInfo {
    let year: Int
    let month: Int
    var dayEvents: [CalendarDayEventInfo] // 该月所有天的事项信息
}

// MARK: - 事项数据获取协议
protocol CalendarYearEventsProvider: AnyObject {
    /// 异步获取指定月份的事项绘制信息
    /// - Parameters:
    ///   - year: 年份
    ///   - month: 月份
    ///   - completion: 完成回调，在主线程调用
    /// - Returns: 可用于取消请求的标识，如果为nil表示不支持取消
    func fetchEventsForMonth(year: Int, month: Int, completion: @escaping (CalendarMonthEventsInfo) -> Void)
    
    /// 取消指定月份的请求（可选实现）
    func cancelFetchForMonth(year: Int, month: Int)
}

// 默认实现，取消方法可选
extension CalendarYearEventsProvider {
    func cancelFetchForMonth(year: Int, month: Int) {
        // 默认不实现
    }
}

// MARK: - 天事项指示条视图
class CalendarEventIndicatorView: UIView {
    
    var firstWeekday: Int = 1 {
        didSet {
            if oldValue != firstWeekday {
                setNeedsDisplay()
            }
        }
    }
    
    private var dayEventColors: [Int: [UIColor]] = [:] // day -> colors
    private var monthInfo: MonthInfo?
    
    // 布局常量
    private static let indicatorHeight: CGFloat = 2.8 // 圆点直径
    private static let maxDotsCount = 3 // 最多显示圆点数
    private static let dotSpacing: CGFloat = 2.0 // 圆点之间的间距
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(monthInfo: MonthInfo, dayEventColors: [Int: [UIColor]]) {
        self.monthInfo = monthInfo
        self.dayEventColors = dayEventColors
        setNeedsDisplay()
    }
    
    func clear() {
        self.dayEventColors = [:]
        setNeedsDisplay()
    }
  
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let monthInfo = monthInfo,
              !dayEventColors.isEmpty else { return }
        
        let width = bounds.width
        let dayWidth = width / 7.0
        
        // 计算日期区域的起始Y坐标
        let dateAreaTop = CalendarDayContentView.dateAreaTopOffset
        let dateAreaHeight = bounds.height - dateAreaTop
        let dayHeight = dateAreaHeight / 6.0
        
        let firstDayAdjustedCol = (monthInfo.firstWeekday - firstWeekday + 7) % 7
        for (day, colors) in dayEventColors {
            guard !colors.isEmpty else { continue }
            guard day >= 1 && day <= monthInfo.daysCount else { continue }

            let position = day - 1 + firstDayAdjustedCol
            let col = position % 7
            let row = position / 7
            
            let cellX = CGFloat(col) * dayWidth
            let cellY = dateAreaTop + CGFloat(row) * dayHeight
            
            // 在天的底部居中绘制指示器
            let indicatorY = cellY + dayHeight - Self.indicatorHeight - 2.0
            
            // 取前3个颜色
            let displayColors = Array(colors.prefix(Self.maxDotsCount))
            drawDots(context: context, cellX: cellX, cellWidth: dayWidth, y: indicatorY, colors: displayColors)
        }
    }
    
    /// 绘制小圆点
    private func drawDots(context: CGContext, cellX: CGFloat, cellWidth: CGFloat, y: CGFloat, colors: [UIColor]) {
        let dotDiameter = Self.indicatorHeight
        let spacing = Self.dotSpacing
        
        // 计算所有圆点的总宽度
        let totalWidth = CGFloat(colors.count) * dotDiameter + CGFloat(max(0, colors.count - 1)) * spacing
        
        // 居中起始位置
        var startX = cellX + (cellWidth - totalWidth) / 2.0
        
        for color in colors {
            let dotRect = CGRect(x: startX, y: y, width: dotDiameter, height: dotDiameter)
            
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: dotRect)
            
            startX += dotDiameter + spacing
        }
    }
}


// MARK: - 天内容绘制视图（独立封装）
class CalendarDayContentView: UIView {
    
    // 暴露给 CalendarEventIndicatorView 使用的布局常量
    static var dateAreaTopOffset: CGFloat {
        return monthTitleHeight + monthTitleToWeekdaySpacing + weekdayHeaderHeight
    }
    
    var firstWeekday: Int = 1 {
        didSet {
            if oldValue != firstWeekday {
                weekdays = Date.veryShortWeekdaySymbols(firstWeekday: firstWeekday)
                setNeedsDisplay()
            }
        }
    }
    
    private lazy var weekdays: [String] = {
        return Date.veryShortWeekdaySymbols(firstWeekday: firstWeekday)
    }()
    
    // 绘制相关数据
    private var monthInfo: MonthInfo?
    private var todayDay: Int = 0

    // 上次绘制的宽度
    private var lastDrawnWidth: CGFloat = 0
    
    // 字体基础比例（以最小宽度120pt为基准）
    private static let baseWidth: CGFloat = 120.0
    private static let baseMonthTitleSize: CGFloat = 14.0
    private static let baseWeekdaySize: CGFloat = 9.0
    private static let baseDaySize: CGFloat = 10.0
    
    // 当前使用的字体
    private static var monthTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    private static var weekdayFont = UIFont.systemFont(ofSize: 9)
    private static var dayFont = UIFont.systemFont(ofSize: 10)
    
    // 上次更新字体时的宽度
    private static var lastFontUpdateWidth: CGFloat = 0
    
    // 标题和星期头高度
    private static var monthTitleHeight: CGFloat = 20
    private static var weekdayHeaderHeight: CGFloat = 16
    
    // 布局常量
    private static let monthTitleToWeekdaySpacing: CGFloat = 2.0
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentWidth = bounds.width
        if abs(currentWidth - lastDrawnWidth) > 0.5 {
            lastDrawnWidth = currentWidth
            updateFontsIfNeeded()
            setNeedsDisplay()
        }
    }
    
    func configure(monthInfo: MonthInfo?, todayDay: Int) {
        self.monthInfo = monthInfo
        self.todayDay = todayDay

        // 如果 monthInfo 为 nil，清空绘制
        guard monthInfo != nil else {
            setNeedsDisplay()
            return
        }
        
        let currentWidth = bounds.width
        if currentWidth > 0 && abs(currentWidth - lastDrawnWidth) > 0.5 {
            lastDrawnWidth = currentWidth
            updateFontsIfNeeded()
        }
        
        setNeedsDisplay()
    }
    
    private func updateFontsIfNeeded() {
        let width = bounds.width
        guard width > 0 else { return }
        
        let scale = min(1.5, max(0.8, width / Self.baseWidth))
        
        if abs(width - Self.lastFontUpdateWidth) > 1.0 {
            Self.lastFontUpdateWidth = width
            
            let monthFontSize = Self.baseMonthTitleSize * scale
            let weekdayFontSize = Self.baseWeekdaySize * scale
            let dayFontSize = Self.baseDaySize * scale
            
            Self.monthTitleFont = UIFont.systemFont(ofSize: monthFontSize, weight: .medium)
            Self.weekdayFont = UIFont.systemFont(ofSize: weekdayFontSize)
            Self.dayFont = UIFont.systemFont(ofSize: dayFontSize)
            
            let monthTitleAttributes: [NSAttributedString.Key: Any] = [.font: Self.monthTitleFont]
            let titleSize = "JAN".size(withAttributes: monthTitleAttributes)
            Self.monthTitleHeight = ceil(titleSize.height)
            
            let weekdayAttributes: [NSAttributedString.Key: Any] = [.font: Self.weekdayFont]
            let weekdaySize = "S".size(withAttributes: weekdayAttributes)
            Self.weekdayHeaderHeight = ceil(weekdaySize.height)
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let monthInfo = monthInfo else { return }
        let width = bounds.width
        let dayWidth = width / 7.0
        
        let dateAreaTop = Self.monthTitleHeight + Self.monthTitleToWeekdaySpacing + Self.weekdayHeaderHeight
        let dateAreaHeight = bounds.height - dateAreaTop
        let dayHeight = dateAreaHeight / 6.0
        
        // 1. 绘制月份标题
        let monthTitle = Date.shortMonthSymbol(ofMonth: monthInfo.month)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: Self.monthTitleFont,
            .foregroundColor: monthInfo.containsToday ? CalendarYearConfig.currentMonthColor : UIColor.label
        ]
        
        let titleSize = monthTitle.size(withAttributes: titleAttributes)
        let titleX = (width - titleSize.width) / 2
        let titleY = (Self.monthTitleHeight - titleSize.height) / 2
        monthTitle.draw(at: CGPoint(x: titleX, y: titleY), withAttributes: titleAttributes)
        
        // 2. 绘制星期头
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
        
        // 计算该月1号在调整后网格中的起始位置
        let firstDayAdjustedCol = (monthInfo.firstWeekday - firstWeekday + 7) % 7
        for day in 1...monthInfo.daysCount {
            let position = day - 1 + firstDayAdjustedCol
            let col = position % 7
            let row = position / 7
            
            let cellX = CGFloat(col) * dayWidth
            let cellY = dateAreaTop + CGFloat(row) * dayHeight
            
            let dayString = "\(day)"
            let daySize = dayString.size(withAttributes: dayAttributes)
            let dayX = cellX + (dayWidth - daySize.width) / 2
            let dayY = cellY + (dayHeight - daySize.height) / 2
            
            // 计算该天真实的星期几（1=周日, 2=周一...7=周六）
            let realWeekday = ((day - 1) + monthInfo.firstWeekday - 1) % 7 + 1
            let isWeekend = (realWeekday == 1 || realWeekday == 7)
            
            // 判断是否今天
            if monthInfo.containsToday && day == todayDay {
                let circleDiameter = min(dayWidth, dayHeight) * 0.75
                let circleX = cellX + (dayWidth - circleDiameter) / 2
                let circleY = cellY + (dayHeight - circleDiameter) / 2
                let circleRect = CGRect(x: circleX, y: circleY, width: circleDiameter, height: circleDiameter)
                context.setFillColor(CalendarYearConfig.todayColor.cgColor)
                context.fillEllipse(in: circleRect)
                
                dayString.draw(at: CGPoint(x: dayX, y: dayY), withAttributes: todayAttributes)
            } else {
                let attributes: [NSAttributedString.Key: Any]
                if isWeekend {
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
                
                let lineHeight: CGFloat = isLunarNewYear ? CalendarYearConfig.lunarNewYearLineHeight : CalendarYearConfig.lunarFirstDayLineHeight
                let lineY = cellY + dayHeight - lineHeight / 2
                let lineWidth = dayWidth * 0.6
                let lineX = cellX + (dayWidth - lineWidth) / 2
                
                context.setStrokeColor(CalendarYearConfig.lunarFirstLineColor.cgColor)
                context.setLineWidth(lineHeight)
                context.move(to: CGPoint(x: lineX, y: lineY))
                context.addLine(to: CGPoint(x: lineX + lineWidth, y: lineY))
                context.strokePath()
            }
        }
    }
}

// MARK: - 月视图Cell
class CalendarYearMonthCell: UICollectionViewCell {
    
    var firstWeekday: Int = 1 {
        didSet {
            eventIndicatorView.firstWeekday = firstWeekday
            dayContentView.firstWeekday = firstWeekday
        }
    }
    
    private let dayContentView = CalendarDayContentView()
    private let eventIndicatorView = CalendarEventIndicatorView()
    
    // 当前请求标识
    private var currentRequestYear: Int = 0
    private var currentRequestMonth: Int = 0
    private var requestToken: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 添加内容视图
        dayContentView.frame = contentView.bounds
        dayContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(dayContentView)
        
        // 添加事项指示视图（覆盖在内容视图上方）
        eventIndicatorView.frame = contentView.bounds
        eventIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        eventIndicatorView.backgroundColor = .clear
        eventIndicatorView.isUserInteractionEnabled = false // 不拦截触摸事件
        contentView.addSubview(eventIndicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 取消当前请求
        cancelCurrentRequest()
        
        // 清空事项指示
        eventIndicatorView.clear()
        
        currentRequestYear = 0
        currentRequestMonth = 0
    }
    
    func configure(
        monthInfo: MonthInfo,
        todayDay: Int,
        eventsProvider: CalendarYearEventsProvider?
    ) {
        // 设置基础内容（不包含事项）
        dayContentView.configure(monthInfo: monthInfo, todayDay: todayDay)
        
        // 清空旧的事项指示
        eventIndicatorView.clear()
        
        // 取消之前的请求
        cancelCurrentRequest()
        
        // 记录新的请求信息
        currentRequestYear = monthInfo.year
        currentRequestMonth = monthInfo.month
        
        // 生成新的请求令牌
        requestToken += 1
        let token = requestToken
        
        // 异步获取事项数据
        eventsProvider?.fetchEventsForMonth(year: monthInfo.year, month: monthInfo.month) { [weak self] eventsInfo in
            guard let self = self else { return }
            
            // 检查令牌是否匹配
            guard token == self.requestToken else { return }
            
            // 检查年月是否匹配
            guard eventsInfo.year == self.currentRequestYear,
                  eventsInfo.month == self.currentRequestMonth else { return }
            
            // 构建颜色字典
            var dayEventColors: [Int: [UIColor]] = [:]
            for dayEvent in eventsInfo.dayEvents {
                if !dayEvent.indicatorColors.isEmpty {
                    dayEventColors[dayEvent.day] = dayEvent.indicatorColors
                }
            }
            
            // 只更新事项指示视图
            self.eventIndicatorView.configure(monthInfo: monthInfo, dayEventColors: dayEventColors)
        }
    }
    
    private func cancelCurrentRequest() {
        if currentRequestYear > 0 && currentRequestMonth > 0 {
            requestToken += 1
        }
    }
}
