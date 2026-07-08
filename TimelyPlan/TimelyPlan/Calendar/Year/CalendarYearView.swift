//
//  CalendarYearView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/4.
//

import Foundation
import UIKit

protocol CalendarYearViewDelegate: AnyObject {
    
    func calendarYearView(_ view: CalendarYearView, didChangeYearTo year: Int)
    
    func calendarYearView(_ view: CalendarYearView,
                          didSelectYear year: Int,
                          month: Int)
}

// MARK: - 年日历View
class CalendarYearView: UIView {
    
    weak var delegate: CalendarYearViewDelegate?
    
    // 事项数据提供者
    weak var eventsProvider: CalendarYearEventsProvider?
    
    // 周开始日，默认周日
    private(set) var firstWeekday: Weekday
    
    private var collectionView: UICollectionView!
    private let baseYear = CalendarYearConfig.baseYear
    private let totalSections = CalendarYearConfig.displayYears
    
    // 当前显示的年份
    private(set) var currentDisplayYear: Int = 0 {
        didSet {
            if currentDisplayYear != oldValue {
                delegate?.calendarYearView(self, didChangeYearTo: currentDisplayYear)
            }
        }
    }
    
    // 用于节流回调的频率控制
    private var lastCallbackTime: TimeInterval = 0
    private let callbackThrottleInterval: TimeInterval = 0.3 // 300ms节流
    
    
    init(frame: CGRect, firstWeekday: Weekday = .sunday) {
        self.firstWeekday = firstWeekday
        super.init(frame: frame)
        setupCollectionView()
        scrollToCurrentYear(animated: false)
        updateCurrentDisplayYear()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        // 使用自定义布局，所有布局参数都在布局内部
        let collectionLayout = CalendarYearCollectionLayout()
        collectionLayout.minimumItemsPerRow = 2
        collectionLayout.maximumItemsPerRow = 4
        collectionLayout.preferredMinimumSpacing = 4.0
        collectionLayout.preferredSectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        collectionLayout.yearHeaderHeight = 80
        collectionLayout.monthAspectRatio = 1.4
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.decelerationRate = .fast
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarYearMonthCell.self, forCellWithReuseIdentifier: "CalendarYearMonthCell")
        collectionView.register(CalendarYearHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "YearHeader")
        addSubview(collectionView)
        
        /// 跳转到今年
        DispatchQueue.main.async { [weak self] in
            self?.scrollToCurrentYear(animated: false)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        
        // 布局变化后更新当前年份
        updateCurrentDisplayYear()
    }
    
    // MARK: - 获取和更新当前显示年份
    
    /// 更新当前显示的年份
    private func updateCurrentDisplayYear() {
        let newYear = calculateCurrentDisplayYear()
        if newYear != currentDisplayYear {
            currentDisplayYear = newYear
        }
    }
    
    /// 计算当前显示的年份
    private func calculateCurrentDisplayYear() -> Int {
        let topEdge = collectionView.contentOffset.y
        let visibleRect = CGRect(
            x: 0,
            y: topEdge,
            width: collectionView.bounds.width,
            height: collectionView.bounds.height
        )
        
        // 获取所有可见的 items
        let visibleItems = collectionView.indexPathsForVisibleItems
        
        // 找出第一个完全或部分在可见区域内的 item
        var firstVisibleItem: IndexPath?
        var minY: CGFloat = .greatestFiniteMagnitude
        
        for indexPath in visibleItems {
            guard let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
                continue
            }
            
            let itemFrame = attributes.frame
            
            // 检查 item 是否与可见区域有交集
            if itemFrame.intersects(visibleRect) {
                // 找最靠上的 item
                if itemFrame.minY < minY {
                    minY = itemFrame.minY
                    firstVisibleItem = indexPath
                }
            }
        }
        
        // 返回第一个可见 item 对应的年份
        if let firstItem = firstVisibleItem {
            return baseYear + firstItem.section
        }
        
        // 兜底方案
        let sortedItems = visibleItems.sorted { $0.section < $1.section }
        if let firstItem = sortedItems.first {
            return baseYear + firstItem.section
        }
        
        return Date().year
    }
    
    func scrollToYear(year: Int, animated: Bool) {
        let section = year - baseYear
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
        
        // 更新当前年份
        if !animated {
            currentDisplayYear = year
        }
    }
    
    func scrollToCurrentYear(animated: Bool) {
        let currentYear = Date().year
        scrollToYear(year: currentYear, animated: animated)
    }
    
    func goToToday() {
        scrollToCurrentYear(animated: true)
    }
    
    // 刷新当前可见月份的事项
    func refreshVisibleEvents() {
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as? CalendarYearMonthCell {
                let year = baseYear + indexPath.section
                let month = indexPath.item + 1
                let monthInfo = CalendarYearCache.shared.getMonthInfo(year: year,
                                                                      month: month,
                                                                      firstWeekday: firstWeekday.rawValue)
                let todayDay = Calendar.current.component(.day, from: Date())
                cell.configure(monthInfo: monthInfo,
                               todayDay: todayDay,
                               eventsProvider: eventsProvider)
            }
        }
    }
    
    // MARK: - 设置周开始日
    func setFirstWeekday(_ firstWeekday: Weekday) {
        guard self.firstWeekday != firstWeekday else {
            return
        }

        self.firstWeekday = firstWeekday
        reloadCalendar()
    }
    
    private func reloadCalendar() {
        CalendarYearCache.shared.clearCache()
        let currentYear = currentDisplayYear
        collectionView.reloadData()
        // 保持当前年份位置
        DispatchQueue.main.async { [weak self] in
            self?.scrollToYear(year: currentYear, animated: false)
        }
    }
    
    func cellForYear(_ year: Int, month: Int) -> CalendarYearMonthCell? {
        let section = year - baseYear
        let item = month - 1
        let indexPath = IndexPath(item: item, section: section)
        return collectionView.cellForItem(at: indexPath) as? CalendarYearMonthCell
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension CalendarYearView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return totalSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MONTHS_PER_YEAR
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarYearMonthCell", for: indexPath) as! CalendarYearMonthCell
        cell.firstWeekday = firstWeekday.rawValue
        let year = baseYear + indexPath.section
        let month = indexPath.item + 1
        let monthInfo = CalendarYearCache.shared.getMonthInfo(year: year,
                                                              month: month,
                                                              firstWeekday: firstWeekday.rawValue)
        let todayDay = Date().day
        cell.configure(monthInfo: monthInfo, todayDay: todayDay, eventsProvider: eventsProvider)
        
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
        delegate?.calendarYearView(self, didSelectYear: year, month: month)
    }
}

// MARK: - UIScrollViewDelegate 预加载和年份检测
extension CalendarYearView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCenter = CGPoint(
            x: collectionView.bounds.midX,
            y: collectionView.bounds.midY
        )
        
        if let indexPath = collectionView.indexPathForItem(at: visibleCenter) {
            let year = baseYear + indexPath.section
            if year >= baseYear && year < baseYear + totalSections {
                CalendarYearCache.shared.preloadNearbyYears(currentYear: year,
                                                            firstWeekday: firstWeekday.rawValue)
            }
        }
        
        throttleUpdateYear()
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 滚动结束时立即更新年份
        updateCurrentDisplayYear()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 如果没有惯性滚动，立即更新
            updateCurrentDisplayYear()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 动画滚动结束后更新
        updateCurrentDisplayYear()
    }
    
    // 节流更新年份，避免频繁回调
    private func throttleUpdateYear() {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastCallbackTime >= callbackThrottleInterval else { return }
        
        lastCallbackTime = currentTime
        updateCurrentDisplayYear()
    }
}
