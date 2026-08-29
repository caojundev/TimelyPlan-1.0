//
//  GanttTimelineHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation
import UIKit

// MARK: - 时间轴 Header 的数据源

final class GanttTimelineHeaderDataSource: NSObject, UICollectionViewDataSource {

    private let scaleProvider: () -> GanttTimeScale.Scale
    private let unitsProvider: () -> [GanttTimelineScaleUnit]

    init(
        scaleProvider: @escaping () -> GanttTimeScale.Scale,
        unitsProvider: @escaping () -> [GanttTimelineScaleUnit]
    ) {
        self.scaleProvider = scaleProvider
        self.unitsProvider = unitsProvider
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return unitsProvider().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let units = unitsProvider()
        let unit = units[indexPath.item]
        let scale = scaleProvider()

        let cell: GanttTimelineScaleCell
        switch scale {
        case .day:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GanttTimelineDayCell.dayReuseIdentifier,
                for: indexPath
            ) as! GanttTimelineDayCell
        case .week:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GanttTimelineWeekCell.weekReuseIdentifier,
                for: indexPath
            ) as! GanttTimelineWeekCell
        case .month:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GanttTimelineMonthCell.monthReuseIdentifier,
                for: indexPath
            ) as! GanttTimelineMonthCell
        }

        cell.configure(with: unit)
        return cell
    }
}


// MARK: - 时间轴 Header 自定义布局

/// 时间轴 header 的横向流式布局
/// 每个 cell 的宽度 = 对应 scale 的 pixelsPerUnit，高度 = header 高度
final class GanttTimelineHeaderLayout: UICollectionViewLayout {

    var headerHeight: CGFloat = 60
    var units: [GanttTimelineScaleUnit] = []
    var pixelsPerUnit: CGFloat = 60

    private var cachedAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]

    override func prepare() {
        super.prepare()
        cachedAttributes.removeAll()

        for (index, _) in units.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let x = CGFloat(index) * pixelsPerUnit
            attributes.frame = CGRect(x: x, y: 0, width: pixelsPerUnit, height: headerHeight)
            cachedAttributes[indexPath] = attributes
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(units.count) * pixelsPerUnit, height: headerHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.values.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
}

// MARK: - 时间轴 Header 视图

/// 封装横向滚动的 UICollectionView，用于渲染时间轴顶部刻度
final class GanttTimelineHeaderView: UIView {

    // MARK: - 私有属性
    
    /// 内部横向滚动的 collectionView
    private lazy var collectionView: UICollectionView = {
        let layout = GanttTimelineHeaderLayout()
        layout.headerHeight = headerHeight
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = GanttTimelineConfig.headerBackgroundColor
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.contentInsetAdjustmentBehavior = .never
        cv.clipsToBounds = true
        cv.register(GanttTimelineDayCell.self, forCellWithReuseIdentifier: GanttTimelineDayCell.dayReuseIdentifier)
        cv.register(GanttTimelineWeekCell.self, forCellWithReuseIdentifier: GanttTimelineWeekCell.weekReuseIdentifier)
        cv.register(GanttTimelineMonthCell.self, forCellWithReuseIdentifier: GanttTimelineMonthCell.monthReuseIdentifier)
        return cv
    }()
    
    /// 数据源（持有，避免被释放）
    private var timelineDataSource: GanttTimelineHeaderDataSource!
    
    /// 当前时间刻度
    private var currentScale: GanttTimeScale.Scale = .day
    
    /// header 高度
    private let headerHeight: CGFloat
    
    /// 顶部分割线
    private lazy var topSeparator: UIView = makeSeparator()
    
    /// 底部分割线
    private lazy var bottomSeparator: UIView = makeSeparator()
    
    // MARK: - 公开属性
    
    /// 布局对象
    var headerLayout: GanttTimelineHeaderLayout {
        return collectionView.collectionViewLayout as! GanttTimelineHeaderLayout
    }
    
    /// 内部 collectionView（只读，供外部同步滚动等操作）
    var internalCollectionView: UICollectionView {
        return collectionView
    }

    // MARK: - 初始化
    
    init(frame: CGRect, headerHeight: CGFloat, timeScale: GanttTimeScale) {
        self.headerHeight = headerHeight
        super.init(frame: frame)
        
        setupUI()
        setupDataSource()
        configure(timeScale: timeScale)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 私有设置方法
    
    private func setupUI() {
        backgroundColor = GanttTimelineConfig.headerBackgroundColor
        clipsToBounds = true
        addSubview(collectionView)
        addSubview(topSeparator)
        addSubview(bottomSeparator)
    }
    
    /// 创建分割线视图
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = GanttTimelineConfig.headerSeparatorColor
        separator.isUserInteractionEnabled = false
        return separator
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds

        let separatorHeight: CGFloat = 1.0
        topSeparator.frame = CGRect(x: 0, y: 0, width: bounds.width, height: separatorHeight)
        bottomSeparator.frame = CGRect(x: 0, y: bounds.height - separatorHeight, width: bounds.width, height: separatorHeight)
    }
    
    private func setupDataSource() {
        timelineDataSource = GanttTimelineHeaderDataSource(
            scaleProvider: { [weak self] in self?.currentScale ?? .day },
            unitsProvider: { [weak self] in self?.headerLayout.units ?? [] }
        )
        collectionView.dataSource = timelineDataSource
        collectionView.delegate = self
    }

    // MARK: - 公开方法
    
    /// 更新刻度配置
    func configure(timeScale: GanttTimeScale) {
        currentScale = timeScale.scale

        let calculator = GanttTimelineScaleCalculator(timeScale: timeScale)
        
        headerLayout.units = calculator.makeUnits()
        headerLayout.pixelsPerUnit = timeScale.scale.pixelsPerUnit
        headerLayout.invalidateLayout()

        collectionView.reloadData()
    }
    
    /// 设置内容偏移（用于与其他视图同步滚动）
    func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    /// 获取当前内容偏移
    var contentOffset: CGPoint {
        return collectionView.contentOffset
    }
}

extension GanttTimelineHeaderView: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 通知横向滚动开始
        notifyHorizontalScrollWillBegin()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 通知横向内容偏移变化
        notifyHorizontalContentOffsetChanged()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 如果不减速，立即通知滚动结束
            notifyHorizontalScrollDidEnd()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 减速结束后通知滚动结束
        notifyHorizontalScrollDidEnd()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 动画滚动结束后通知滚动结束
        notifyHorizontalScrollDidEnd()
    }
}

// MARK: - GanttTimelineHeaderView 扩展（横向滚动）

extension GanttTimelineHeaderView: HorizontalScrollSyncable {
    var xOffset: CGFloat {
        get {
            return internalCollectionView.contentOffset.x
        }
        set {
            internalCollectionView.contentOffset = CGPoint(x: newValue, y: internalCollectionView.contentOffset.y)
        }
    }
    
    func setXOffset(_ xOffset: CGFloat, animated: Bool) {
        internalCollectionView.setContentOffset(
            CGPoint(x: xOffset, y: internalCollectionView.contentOffset.y),
            animated: animated
        )
    }
    
    var horizontalScrollSyncDelegate: HorizontalScrollSyncDelegate? {
        get {
            return internalCollectionView.horizontalScrollSyncDelegate
        }
        set {
            internalCollectionView.horizontalScrollSyncDelegate = newValue
        }
    }
    
    func notifyHorizontalScrollWillBegin() {
        horizontalScrollSyncDelegate?.horizontalScrollSyncViewWillBeginScrolling(self)
    }
    
    func notifyHorizontalScrollDidEnd() {
        horizontalScrollSyncDelegate?.horizontalScrollSyncViewDidEndScrolling(self)
    }
    
    func notifyHorizontalContentOffsetChanged() {
        horizontalScrollSyncDelegate?.horizontalScrollSyncView(self, didChangeXOffset: xOffset)
    }
}
