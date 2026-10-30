//
//  WSTimelineChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 甘特图滚动视图

/// 甘特图内部的滚动视图。
///
/// 内容不足以纵向滚动时，纵向拖动不拦截，交给外层面板滚动视图；
/// 横向拖动始终由自身处理，用于浏览时间轴。
final class WSTimelineChartScrollView: UICollectionView {

    /// 是否允许纵向滚动
    var allowsVerticalScroll = false

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGestureRecognizer, !allowsVerticalScroll {
            let velocity = panGestureRecognizer.velocity(in: self)
            return abs(velocity.x) > abs(velocity.y)
        }

        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}

// MARK: - 甘特图视图

/// 甘特图组件的事项区域：横向为时间轴，纵向为事项行
final class WSTimelineChartView: UIView {

    /// 点击甘特条回调
    var onEventTap: ((GanttEvent) -> Void)?

    /// 水平偏移变化回调，用于同步顶部刻度
    var onContentOffsetChange: ((CGFloat) -> Void)?

    /// 左侧可见日期变化回调
    var onDateChanged: ((Date) -> Void)?

    /// 上次通知的左侧可见日期
    private var lastNotifiedDate: Date?

    /// 当前水平偏移
    var contentOffsetX: CGFloat {
        return collectionView.contentOffset.x
    }

    private let layout: WSTimelineChartLayout
    private let collectionView: WSTimelineChartScrollView

    /// 今天指示线，固定在可视区域上方覆盖显示
    private let todayLine = GanttTimelineNowLineView()

    /// 今天指示线宽度（容纳顶部圆点）
    private let todayLineWidth: CGFloat = 6.0

    private var timeScale: GanttTimeScale

    /// 是否已经绑定过数据
    private var hasConfigured = false

    /// 等待布局完成后滚动到今天
    private var needsScrollToToday = false

    // MARK: 滚动方向锁定

    private var initialOffset: CGPoint = .zero
    private var isHorizontalLocked = false
    private var isVerticalLocked = false

    /// 锁定判定阈值
    private let scrollLockThreshold: CGFloat = 5.0

    init(timeScale: GanttTimeScale) {
        let layout = WSTimelineChartLayout(timeScale: timeScale)
        self.timeScale = timeScale
        self.layout = layout
        self.collectionView = WSTimelineChartScrollView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 视图设置

    private func setupViews() {
        clipsToBounds = true
        backgroundColor = WSTimelineChartConfig.chartBackgroundColor

        collectionView.backgroundColor = WSTimelineChartConfig.chartBackgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: TimelineCell.reuseIdentifier)
        addSubview(collectionView)

        todayLine.isUserInteractionEnabled = false
        addSubview(todayLine)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.frame = bounds

        let minimumItemCount = Int(ceil(Double(bounds.height / layout.rowHeight)))
        if layout.minimumItemCount != minimumItemCount {
            layout.minimumItemCount = minimumItemCount
            layout.invalidateLayout()
            collectionView.reloadData()
        }

        collectionView.layoutIfNeeded()

        /// 只有事项确实超过可视高度时才响应纵向滚动，空占位行不占用纵向手势
        collectionView.allowsVerticalScroll = CGFloat(layout.events.count) * layout.rowHeight > bounds.height

        updateTodayLine()

        if needsScrollToToday, bounds.width > 0.0 {
            needsScrollToToday = false
            scrollToToday(animated: false)
        }

        updateVisibleCells()
    }

    // MARK: - 数据

    func configure(timeScale: GanttTimeScale, events: [GanttEvent]) {
        let scaleChanged = self.timeScale.scale != timeScale.scale
            || !Calendar.current.isDate(self.timeScale.startDate, inSameDayAs: timeScale.startDate)

        self.timeScale = timeScale
        layout.timeScale = timeScale
        layout.events = events
        layout.invalidateLayout()
        collectionView.reloadData()

        lastNotifiedDate = nil

        if !hasConfigured || scaleChanged {
            hasConfigured = true
            needsScrollToToday = true
        }

        setNeedsLayout()
    }

    // MARK: - 滚动

    /// 滚动到今天附近
    func scrollToToday(animated: Bool) {
        scroll(to: Date(), anchorRatio: 0.35, animated: animated)
    }

    /// 将指定日期滚动到可视区域左侧
    func scroll(to date: Date, animated: Bool) {
        scrollHorizontally(to: layout.xPosition(for: date), animated: animated)
    }

    /// 将指定日期滚动到可视区域指定比例处
    private func scroll(to date: Date, anchorRatio: CGFloat, animated: Bool) {
        guard bounds.width > 0.0 else {
            needsScrollToToday = true
            return
        }

        let x = layout.xPosition(for: date)
        scrollHorizontally(to: x - bounds.width * anchorRatio, animated: animated)
    }

    /// 将事项起始位置滚动到可视区域
    func scrollToEventStart(_ event: GanttEvent) {
        scrollHorizontally(to: layout.xPosition(for: event.startDate) - 20.0, animated: true)
    }

    /// 将事项结束位置滚动到可视区域
    func scrollToEventEnd(_ event: GanttEvent) {
        let x = layout.xPosition(for: event.endDate) - bounds.width + 20.0
        scrollHorizontally(to: x, animated: true)
    }

    /// 横向滚动到指定偏移，自动裁剪到合法范围并重置方向锁定
    private func scrollHorizontally(to offsetX: CGFloat, animated: Bool) {
        needsScrollToToday = false

        let maxOffsetX = max(collectionView.contentSize.width - bounds.width, 0.0)
        let targetX = min(max(offsetX, 0.0), maxOffsetX)

        resetScrollLock(offset: CGPoint(x: targetX, y: collectionView.contentOffset.y))
        collectionView.setContentOffset(CGPoint(x: targetX, y: collectionView.contentOffset.y),
                                        animated: animated)
        updateTodayLine()
    }

    private func resetScrollLock(offset: CGPoint) {
        initialOffset = offset
        isHorizontalLocked = false
        isVerticalLocked = false
    }

    /// 与甘特图主视图一致：一次拖动只允许一个方向滚动，避免斜向滚动
    private func applyScrollLockIfNeeded(_ scrollView: UIScrollView) {
        guard scrollView.isDragging || scrollView.isDecelerating else { return }

        if !isHorizontalLocked && !isVerticalLocked {
            let dx = abs(scrollView.contentOffset.x - initialOffset.x)
            let dy = abs(scrollView.contentOffset.y - initialOffset.y)
            guard dx > scrollLockThreshold || dy > scrollLockThreshold else { return }

            if dx > dy {
                isHorizontalLocked = true
            } else {
                isVerticalLocked = true
            }
        }

        if isHorizontalLocked, scrollView.contentOffset.y != initialOffset.y {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: initialOffset.y)
        } else if isVerticalLocked, scrollView.contentOffset.x != initialOffset.x {
            scrollView.contentOffset = CGPoint(x: initialOffset.x, y: scrollView.contentOffset.y)
        }
    }

    /// 左侧可见日期变化时通知外部（仅当天变化时触发）
    private func notifyDateChangedIfNeeded() {
        let date = layout.date(forX: collectionView.contentOffset.x)

        if let last = lastNotifiedDate, Calendar.current.isDate(last, inSameDayAs: date) {
            return
        }

        lastNotifiedDate = date
        onDateChanged?(date)
    }

    /// 更新今天指示线位置
    private func updateTodayLine() {
        let now = Date()
        guard now >= timeScale.startDate, now <= timeScale.endDate else {
            todayLine.isHidden = true
            return
        }

        let x = layout.xPosition(for: now) - collectionView.contentOffset.x
        todayLine.isHidden = x < -todayLineWidth || x > bounds.width + todayLineWidth
        todayLine.frame = CGRect(x: x - todayLineWidth / 2.0,
                                 y: 0.0,
                                 width: todayLineWidth,
                                 height: bounds.height)
    }

    // MARK: - 事项

    /// 按当前可视区域刷新行内容（标题位置依赖可视区域）
    private func updateVisibleCells() {
        for cell in collectionView.visibleCells {
            guard let timelineCell = cell as? TimelineCell,
                  let indexPath = collectionView.indexPath(for: cell),
                  let event = layout.event(at: indexPath.item) else {
                continue
            }

            configure(timelineCell, with: event)
        }
    }

    private func configure(_ cell: TimelineCell, with event: GanttEvent) {
        let x = layout.xPosition(for: event.startDate)
        let width = layout.width(from: event.startDate, to: event.endDate)
        let visibleRect = CGRect(x: collectionView.contentOffset.x,
                                 y: 0.0,
                                 width: collectionView.bounds.width,
                                 height: layout.rowHeight)

        cell.configure(event: event,
                       x: x,
                       width: width,
                       rowHeight: layout.rowHeight,
                       visibleRect: visibleRect,
                       contentMaxX: collectionView.contentSize.width)
    }
}

// MARK: - UICollectionViewDataSource

extension WSTimelineChartView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layout.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TimelineCell.reuseIdentifier,
            for: indexPath
        ) as! TimelineCell

        cell.backgroundColor = indexPath.item % 2 == 0
            ? WSTimelineChartConfig.rowBackgroundColor
            : WSTimelineChartConfig.alternateRowBackgroundColor
        /// 组件内甘特条与边缘指示器使用全圆角
        cell.isBarFullyRounded = true
        cell.isIndicatorFullyRounded = true

        if let event = layout.event(at: indexPath.item) {
            configure(cell, with: event)

            cell.onBarTapped = { [weak self] event in
                self?.onEventTap?(event)
            }
            cell.onLeftIndicatorTapped = { [weak self] in
                self?.scrollToEventStart(event)
            }
            cell.onRightIndicatorTapped = { [weak self] in
                self?.scrollToEventEnd(event)
            }
        } else {
            cell.resetAsPlaceholder()
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension WSTimelineChartView: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        resetScrollLock(offset: scrollView.contentOffset)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        applyScrollLockIfNeeded(scrollView)

        updateTodayLine()
        onContentOffsetChange?(scrollView.contentOffset.x)
        notifyDateChangedIfNeeded()
        updateVisibleCells()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resetScrollLock(offset: scrollView.contentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        resetScrollLock(offset: scrollView.contentOffset)
    }
}
