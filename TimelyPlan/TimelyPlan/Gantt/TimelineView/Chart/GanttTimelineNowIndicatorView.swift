//
//  GanttTimelineNowIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/29.
//

import Foundation
import UIKit

// MARK: - 指示器定时刷新器

/// 指示器定时刷新器，根据时间尺度决定刷新频率：
/// - `.day` 尺度：每小时刷新（对齐整点）
/// - `.week` / `.month` 尺度：每天 0 点刷新一次
///
/// 使用单个 Timer，在每次触发后重新计算下一次触发时刻，确保精确对齐整点 / 零点。
final class GanttNowIndicatorRefresher {

    /// 刷新回调
    var onRefresh: (() -> Void)?

    /// 当前时间尺度
    private var timeScale: GanttTimeScale

    /// 内部定时器
    private var timer: Timer?

    /// 是否已启动
    private var isRunning = false

    init(timeScale: GanttTimeScale) {
        self.timeScale = timeScale
    }

    deinit {
        stop()
    }

    // MARK: - 公开方法

    /// 启动定时刷新
    func start() {
        guard !isRunning else { return }
        isRunning = true
        scheduleNextRefresh()
    }

    /// 停止定时刷新
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    /// 更新时间尺度（切换尺度时重新计算刷新策略）
    func update(timeScale: GanttTimeScale) {
        self.timeScale = timeScale
        // 若正在运行，则重新调度
        if isRunning {
            scheduleNextRefresh()
        }
    }

    // MARK: - 私有方法

    /// 计算下一次刷新时刻，并调度定时器
    private func scheduleNextRefresh() {
        timer?.invalidate()
        timer = nil

        let calendar = Calendar.current
        let now = Date()

        // 下一个整点（.day 尺度）或下一个零点（.week / .month 尺度）
        let nextDate: Date
        switch timeScale.scale {
        case .day:
            // 下一个整点
            nextDate = calendar.nextDate(
                after: now,
                matching: DateComponents(minute: 0, second: 0),
                matchingPolicy: .nextTime
            ) ?? now.addingTimeInterval(3600)
        case .week, .month:
            // 下一个零点
            nextDate = calendar.startOfDay(for: now).addingTimeInterval(86400)
        }

        let interval = max(nextDate.timeIntervalSince(now), 0.1)

        timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.onRefresh?()
            // 触发后调度下一次
            self.scheduleNextRefresh()
        }
        // 加入 RunLoop，保证在滚动时也能触发
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
}

// MARK: - 指示器视图

/// 今天当前时间指示器视图
///
/// 该视图是一个横向滚动的 UIScrollView，其 contentSize 宽度与 chartView 的内容宽度保持一致
/// （均由 timeScale 计算得出），内部绘制一条纵向细线表示「今天当前时间」所在的位置。
/// 不响应任何手势，仅通过参与横向滚动同步跟随 chartView 水平滚动。
final class GanttTimelineNowIndicatorView: UIScrollView {

    // MARK: - 常量

    /// 指示线视图宽度（容纳顶部圆点与竖直线）
    private static let indicatorWidth: CGFloat = 6.0

    // MARK: - 公开属性

    /// 当前时间尺度（用于计算内容宽度与指示线 X 位置）
    var timeScale: GanttTimeScale = GanttTimeScale(scale: .day, date: Date()) {
        didSet {
            updateContentSize()
            refresher.update(timeScale: timeScale)
        }
    }

    // MARK: - 私有属性

    /// 纵向指示线
    private let indicatorLine = GanttTimelineNowLineView()

    /// 定时刷新器（按时间尺度周期刷新指示线位置）
    private let refresher: GanttNowIndicatorRefresher

    // MARK: - 初始化

    override init(frame: CGRect) {
        self.refresher = GanttNowIndicatorRefresher(timeScale: GanttTimeScale(scale: .day, date: Date()))
        super.init(frame: frame)
        setupScrollView()
        setupIndicatorLine()
        setupRefresher()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        refresher.stop()
    }

    // MARK: - 视图设置

    private func setupScrollView() {
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        bounces = false
        alwaysBounceHorizontal = false
        alwaysBounceVertical = false
        contentInsetAdjustmentBehavior = .never
        // 不响应任何手势与交互，仅跟随 chartView 横向滚动
        isScrollEnabled = false
        isUserInteractionEnabled = false
        // 指示线需要完整覆盖内容高度，因此纵向不裁剪
        clipsToBounds = false
    }

    private func setupIndicatorLine() {
        indicatorLine.isUserInteractionEnabled = false
        addSubview(indicatorLine)
    }

    private func setupRefresher() {
        refresher.onRefresh = { [weak self] in
            self?.updateIndicatorPosition()
        }
        refresher.start()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        // 指示线视图宽度固定，纵向占满自身高度，水平定位到当前时间位置
        let lineX = xPositionForDate(Date(), timeScale: timeScale) - Self.indicatorWidth / 2
        indicatorLine.frame = CGRect(
            x: lineX,
            y: 2.0,
            width: Self.indicatorWidth,
            height: bounds.height
        )
    }

    // MARK: - 私有方法

    /// 更新内容尺寸与指示线位置
    private func updateContentSize() {
        contentSize = CGSize(width: GanttTimelineGeometry.contentWidth(timeScale: timeScale),
                             height: bounds.height)
        updateIndicatorPosition()
    }

    /// 重新计算并更新指示线位置
    private func updateIndicatorPosition() {
        let now = Date()
        let x = xPositionForDate(now, timeScale: timeScale)

        // 若当前时间超出时间尺度范围，隐藏指示线
        let inRange = now >= timeScale.startDate && now <= timeScale.endDate
        indicatorLine.isHidden = !inRange

        indicatorLine.frame = CGRect(
            x: x - Self.indicatorWidth / 2,
            y: 0,
            width: Self.indicatorWidth,
            height: bounds.height
        )
    }
    
    
    func xPositionForDate(_ date: Date, timeScale: GanttTimeScale) -> CGFloat {
         return xPositionForDate(date, scale: timeScale.scale, startDate: timeScale.startDate)
     }

     /// 计算指定日期在时间轴上的 X 坐标（低层实现）
     ///
     /// 精确到「当天内的具体时刻」：在整数天/月的基础上，叠加当天已过去时间占整天的比例，
     /// 使指示器能够定位到当前时间（时分秒），而非仅定位到某一天的开头。
     /// - Parameters:
     ///   - date: 目标日期
     ///   - scale: 时间尺度类型
     ///   - startDate: 时间轴起始日期
     /// - Returns: X 坐标（pt）
     func xPositionForDate(_ date: Date, scale: GanttTimeScale.Scale, startDate: Date) -> CGFloat {
         let calendar = Calendar.current
         let days = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0

         // 当天内已过去的时间占整天的比例（0.0 ~ 1.0）
         let dayStart = calendar.startOfDay(for: date)
         let dayElapsed = date.timeIntervalSince(dayStart)
         let dayTotal = calendar.dateInterval(of: .day, for: date)?.duration ?? 86400
         let fractionOfDay = dayTotal > 0 ? dayElapsed / dayTotal : 0

         switch scale {
         case .day:
             return (CGFloat(days) + CGFloat(fractionOfDay)) * scale.pixelsPerUnit
         case .week:
             return ((CGFloat(days) + CGFloat(fractionOfDay)) / 7.0) * scale.pixelsPerUnit
         case .month:
             let months = calendar.dateComponents([.month], from: startDate, to: date).month ?? 0
             let dayInMonth = calendar.component(.day, from: date) - 1
             let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
             let monthFraction = (CGFloat(dayInMonth) + CGFloat(fractionOfDay)) / CGFloat(daysInMonth)
             return (CGFloat(months) + monthFraction) * scale.pixelsPerUnit
         }
     }

}
