//
//  GanttTimelineChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation
import UIKit

// MARK: - 右侧时间轴 Layout
class GanttTimelineLayout: UICollectionViewLayout {
    
    var rowHeight: CGFloat = 44
    var timeScale: GanttTimeScale
    var tasks: [GanttTask] = []
    
    private var cachedAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var cachedHeaderAttributes: UICollectionViewLayoutAttributes?
    private var totalWidth: CGFloat = 0
    private var totalHeight: CGFloat = 0
    
    init(timeScale: GanttTimeScale) {
        self.timeScale = timeScale
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        cachedAttributes.removeAll()
        
        totalWidth = calculateTimeAxisWidth()
        totalHeight = CGFloat(tasks.count) * rowHeight
        
        for (index, _) in tasks.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let y = CGFloat(index) * rowHeight
            attributes.frame = CGRect(x: 0, y: y, width: totalWidth, height: rowHeight)
            cachedAttributes[indexPath] = attributes
        }
    }
    
    private func calculateTimeAxisWidth() -> CGFloat {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: timeScale.startDate, to: timeScale.endDate).day ?? 30
        switch timeScale.scale {
        case .day:
            return CGFloat(days + 1) * timeScale.scale.pixelsPerUnit
        case .week:
            let weeks = ceil(Double(days + 1) / 7.0)
            return CGFloat(weeks) * timeScale.scale.pixelsPerUnit
        case .month:
            let months = calendar.dateComponents([.month], from: timeScale.startDate, to: timeScale.endDate).month ?? 1
            return CGFloat(months + 1) * timeScale.scale.pixelsPerUnit
        }
    }
    
    func taskAtIndex(_ index: Int) -> GanttTask? {
        guard index < tasks.count else { return nil }
        return tasks[index]
    }
    
    var visibleTaskCount: Int {
        return tasks.count
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result: [UICollectionViewLayoutAttributes] = []
        
        if let header = cachedHeaderAttributes, header.frame.intersects(rect) {
            result.append(header)
        }
        
        for (_, attributes) in cachedAttributes {
            if attributes.frame.intersects(rect) {
                result.append(attributes)
            }
        }
        
        return result
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedHeaderAttributes
    }
    
    func xPositionForDate(_ date: Date) -> CGFloat {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: timeScale.startDate, to: date).day ?? 0
        
        switch timeScale.scale {
        case .day:
            return CGFloat(days) * timeScale.scale.pixelsPerUnit
        case .week:
            return (CGFloat(days) / 7.0) * timeScale.scale.pixelsPerUnit
        case .month:
            let months = calendar.dateComponents([.month], from: timeScale.startDate, to: date).month ?? 0
            let dayInMonth = calendar.component(.day, from: date) - 1
            let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
            return (CGFloat(months) + CGFloat(dayInMonth) / CGFloat(daysInMonth)) * timeScale.scale.pixelsPerUnit
        }
    }
    
    func widthForDuration(from start: Date, to end: Date) -> CGFloat {
        return max(xPositionForDate(end) - xPositionForDate(start), 2)
    }
    
    /// 根据 X 坐标反推对应的日期（与 xPositionForDate 对称）
    func dateForXPosition(_ x: CGFloat) -> Date {
        let calendar = Calendar.current
        let clampedX = max(0, x)
        
        switch timeScale.scale {
        case .day:
            let days = Int(round(clampedX / timeScale.scale.pixelsPerUnit))
            return calendar.date(byAdding: .day, value: days, to: timeScale.startDate) ?? timeScale.startDate
        case .week:
            let weeks = clampedX / timeScale.scale.pixelsPerUnit
            let days = Int(round(weeks * 7.0))
            return calendar.date(byAdding: .day, value: days, to: timeScale.startDate) ?? timeScale.startDate
        case .month:
            let totalMonths = calendar.dateComponents([.month], from: timeScale.startDate, to: timeScale.endDate).month ?? 1
            guard totalMonths > 0 else { return timeScale.startDate }
            let unitIndex = clampedX / timeScale.scale.pixelsPerUnit
            let monthIndex = Int(floor(unitIndex))
            let clampedMonth = max(0, min(monthIndex, totalMonths))
            let fraction = unitIndex - CGFloat(clampedMonth)
            
            let monthStart = calendar.date(byAdding: .month, value: clampedMonth, to: timeScale.startDate) ?? timeScale.startDate
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
            let dayInMonth = Int(round(fraction * CGFloat(daysInMonth)))
            return calendar.date(byAdding: .day, value: dayInMonth, to: monthStart) ?? monthStart
        }
    }
}

// MARK: - 右侧时间轴 Cell（完善指示器显示逻辑）
class TimelineCell: UICollectionViewCell {
    static let reuseIdentifier = "TimelineCell"
    
    private var barView: UIView!
    private var progressView: UIView!
    private var titleLabel: UILabel!
    
    // 可视区域边缘指示器
    private lazy var leftEdgeIndicator: TPImageButton = {
        let button = TPImageButton()
        button.cornerRadius = 6.0
        button.normalImage = resGetImage("triangle_left_12")
        button.normalBackgroundColor = GanttTimelineConfig.edgeIndicatorBackgroundColor
        button.normalImageColor = GanttTimelineConfig.edgeIndicatorImageColor
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.addTarget(self, action: #selector(leftIndicatorTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var rightEdgeIndicator: TPImageButton = {
        let button = TPImageButton()
        button.cornerRadius = 6.0
        button.normalImage = resGetImage("triangle_right_12")
        button.normalBackgroundColor = GanttTimelineConfig.edgeIndicatorBackgroundColor
        button.normalImageColor = GanttTimelineConfig.edgeIndicatorImageColor
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.addTarget(self, action: #selector(rightIndicatorTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    var onLeftIndicatorTapped: (() -> Void)?
    var onRightIndicatorTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        // 关键：允许子视图超出边界
        contentView.clipsToBounds = false
        clipsToBounds = false
        
        barView = UIView()
        barView.layer.cornerRadius = 8
        barView.layer.masksToBounds = true
        barView.layer.borderWidth = 1
        barView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        
        progressView = UIView()
        progressView.layer.cornerRadius = 8
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 10)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        contentView.addSubview(barView)
        barView.addSubview(progressView)
        // 标题标签作为 contentView 子视图，避免被 barView 的 masksToBounds 裁剪，
        // 从而在滚动固定到可视区域左边缘时可以定位到 bar 之外
        contentView.addSubview(titleLabel)
        contentView.addSubview(leftEdgeIndicator)
        contentView.addSubview(rightEdgeIndicator)
    }
    
    func configure(task: GanttTask,
                   x: CGFloat,
                   width: CGFloat,
                   rowHeight: CGFloat,
                   visibleRect: CGRect) {
        let barWidth = max(width, 2)
        
        // 计算 bar 高度：默认 rowHeight - 上下间距，超过最大高度则以最大高度显示
        let defaultHeight = rowHeight - GanttTimelineConfig.barVerticalInset * 2
        let height = min(defaultHeight, GanttTimelineConfig.barMaxHeight)
        let y = (rowHeight - height) / 2
        
        // 设置甘特条
        barView.frame = CGRect(x: x, y: y, width: barWidth, height: height)
        barView.backgroundColor = task.color.withAlphaComponent(0.3)
        
        progressView.frame = CGRect(x: 0, y: 0, width: barWidth * task.progress, height: height)
        progressView.backgroundColor = task.color
        
        titleLabel.text = task.name
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        
        // 计算甘特条与可视区域的关系
        let barLeft = x
        let barRight = x + barWidth
        let visibleLeft = visibleRect.minX
        let visibleRight = visibleRect.maxX
        
        // 指示器
        let indicatorSize: CGFloat = 24
        let indicatorY = (rowHeight - indicatorSize) / 2
        
        // 左侧指示器 - 直接显示/隐藏，无动画
        let showLeftIndicator = barLeft < visibleLeft
        if showLeftIndicator {
            leftEdgeIndicator.isHidden = false
            leftEdgeIndicator.frame = CGRect(
                x: visibleLeft + 10.0,
                y: indicatorY,
                width: indicatorSize,
                height: indicatorSize
            )
            leftEdgeIndicator.alpha = 1.0 // 确保完全显示
        } else {
            leftEdgeIndicator.isHidden = true
            leftEdgeIndicator.alpha = 0.0 // 立即隐藏
        }
        
        // 右侧指示器 - 直接显示/隐藏，无动画
        let showRightIndicator = barRight > visibleRight
        if showRightIndicator {
            rightEdgeIndicator.isHidden = false
            rightEdgeIndicator.frame = CGRect(
                x: visibleRight - indicatorSize - 10.0,
                y: indicatorY,
                width: indicatorSize,
                height: indicatorSize
            )
            rightEdgeIndicator.alpha = 1.0 // 确保完全显示
        } else {
            rightEdgeIndicator.isHidden = true
            rightEdgeIndicator.alpha = 0.0 // 立即隐藏
        }
        
        /// 标题可以显示在 bar 中的最小宽度
        let minDisplayTitleInBarWidth = 240.0
        if barWidth < minDisplayTitleInBarWidth {
            let titleMaxWidth = 180.0
            let titleMargin = 5.0
            /// 小于最小显示宽度，标题显示在 bar 的两侧
            var titleWidth = titleLabel.sizeThatFits(.unlimited).width
            if titleWidth > titleMaxWidth {
                titleWidth = titleMaxWidth
            }
            
            let labelX: CGFloat
            if visibleRight - barRight < titleWidth {
                
                if rightEdgeIndicator.isHidden {
                    labelX = barLeft - titleMargin - titleWidth
                } else {
                    labelX = min(barLeft, rightEdgeIndicator.left) - titleMargin - titleWidth
                }
            } else {
                if leftEdgeIndicator.isHidden {
                    labelX = barRight + titleMargin
                } else {
                    labelX = max(barRight, leftEdgeIndicator.right) + titleMargin
                }
            }
            
            titleLabel.frame = CGRect(x: labelX,
                                      y: y,
                                      width: titleWidth,
                                      height: height)
            return
        }
        
        /// 标题可以显示在 bar 中
        
        let barVisibleLeft = max(barLeft, visibleLeft)
        let barVisibleRight = min(barRight, visibleRight)
        let visibleBarWidth = max(barVisibleRight - barVisibleLeft, 0)
        
        
        
        
        
        
        
        
//        1. 两个都不显示
//        2. 仅显示左侧
//        3. 仅显示右侧
//        4. 两个都显示
    
        /*
        
        let barVisibleLeft = max(barLeft, visibleLeft)
        let barVisibleRight = min(barRight, visibleRight)
        let visibleBarWidth = max(barVisibleRight - barVisibleLeft, 0)
        var labelX: CGFloat
        var labelWidth: CGFloat
        if visibleBarWidth >= labelMinWidth {
            // bar 的可见宽度足够显示标签
            if barLeft < visibleLeft {
                // bar 左侧已滚出可视区域，标签固定在可视区域左边缘
                labelX = visibleLeft + labelHorizontalInset
                labelWidth = visibleBarWidth - labelHorizontalInset * 2
            } else {
                // bar 左侧仍在可视区域内，标签跟随 bar 左边缘
                labelX = barLeft + labelHorizontalInset
                labelWidth = min(barWidth - labelHorizontalInset * 2, barRight - visibleLeft - labelHorizontalInset)
            }
        } else {
            // bar 可见区域不足以显示标签，标签固定在 bar 最右侧（可视区域内）
            labelX = barVisibleRight - labelHorizontalInset - labelMinWidth
            labelWidth = labelMinWidth
        }
        
        titleLabel.frame = CGRect(x: labelX, y: y, width: max(labelWidth, 0), height: height)
        */
    }
    
    @objc private func leftIndicatorTapped() {
        TPImpactFeedback.impactWithSoftStyle()
        onLeftIndicatorTapped?()
    }
    
    @objc private func rightIndicatorTapped() {
        TPImpactFeedback.impactWithSoftStyle()
        onRightIndicatorTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        barView.frame = .zero
        progressView.frame = .zero
        titleLabel.frame = .zero
        titleLabel.text = nil
        leftEdgeIndicator.isHidden = true
        rightEdgeIndicator.isHidden = true
    }
}

// MARK: - 右侧时间轴视图（修复指示器点击问题）
class GanttTimelineChartView: UIView {

    /// 内部 collectionView（只读，供外部同步滚动等操作）
    var internalCollectionView: UICollectionView {
        return collectionView
    }

    // 布局
    private var collectionView: UICollectionView!
    private var timelineLayout: GanttTimelineLayout!
    
    // 布局常量
    private let rowHeight: CGFloat = GanttTimelineConfig.taskListRowHeight
    
    // 滚动方向锁定
    private var initialOffset: CGPoint = .zero
    private var isHorizontalLocked = false
    private var isVerticalLocked = false
    
    // 指示器动画标志
    private var isIndicatorScrolling = false
    
    // 滚动同步回调
    var onVerticalScroll: ((CGFloat) -> Void)?

    /// 最左侧（contentOffset.x）对应日期改变时回调（仅当「天」发生变化时触发）
    var onDateChanged: ((Date) -> Void)?

    /// 上次通知的日期（用于判断是否改变）
    private var lastNotifiedDate: Date?
    
    // 数据
    var tasks: [GanttTask] = [] {
        didSet {
            timelineLayout.tasks = tasks
            timelineLayout.invalidateLayout()
            collectionView.reloadData()
        }
    }
    
    var timeScale: GanttTimeScale {
        didSet {
            timelineLayout.timeScale = timeScale
            timelineLayout.invalidateLayout()
            collectionView.reloadData()
        }
    }
    
    // 对外暴露的滚动方法
    var contentOffset: CGPoint {
        get { return collectionView.contentOffset }
        set { collectionView.contentOffset = newValue }
    }
    
    var contentSize: CGSize {
        return collectionView.contentSize
    }
    
    // 初始化
    init(timeScale: GanttTimeScale) {
        self.timeScale = timeScale
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 视图设置
    
    private func setupViews() {
        backgroundColor = GanttTimelineConfig.taskListBackgroundColor
        clipsToBounds = true
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        timelineLayout = GanttTimelineLayout(timeScale: timeScale)
        timelineLayout.tasks = []
        timelineLayout.rowHeight = rowHeight
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: timelineLayout)
        collectionView.backgroundColor = GanttTimelineConfig.taskListBackgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(bottom: GanttTimelineConfig.insetBottom)
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: TimelineCell.reuseIdentifier)
        
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    // MARK: - 公共方法
    
    func xPositionForDate(_ date: Date) -> CGFloat {
        return timelineLayout.xPositionForDate(date)
    }
    
    func dateForXPosition(_ x: CGFloat) -> Date {
        return timelineLayout.dateForXPosition(x)
    }
    
    func widthForDuration(from start: Date, to end: Date) -> CGFloat {
        return timelineLayout.widthForDuration(from: start, to: end)
    }
    
    func taskAtIndex(_ index: Int) -> GanttTask? {
        return timelineLayout.taskAtIndex(index)
    }
    
    var visibleTaskCount: Int {
        return timelineLayout.visibleTaskCount
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    // MARK: - 公共方法
    func scrollToToday(animated: Bool = true) {
        let xPos = timelineLayout.xPositionForDate(Date())
        let targetX = max(0, xPos - 100)
        performHorizontalScroll(to: targetX, animated: animated)
    }

    /// 滚动到指定日期位置（将该日期置于可视区域最左侧）
    func scrollToDate(_ date: Date, animated: Bool = false) {
        let xPos = timelineLayout.xPositionForDate(date)
        let targetX = max(0, xPos)
        performHorizontalScroll(to: targetX, animated: animated)
    }

    func scrollToTaskStart(_ task: GanttTask) {
        let xPos = timelineLayout.xPositionForDate(task.startDate)
        let targetX = max(0, xPos - 20)
        performHorizontalScroll(to: targetX, animated: true)
    }

    func scrollToTaskEnd(_ task: GanttTask) {
        let xPos = timelineLayout.xPositionForDate(task.endDate)
        let visibleWidth = collectionView.bounds.width
        let targetX = max(0, xPos - visibleWidth + 20)
        performHorizontalScroll(to: targetX, animated: true)
    }

    private func performHorizontalScroll(to targetX: CGFloat, animated: Bool, syncToOthers: Bool = true) {
        isIndicatorScrolling = true
        
        // 通知滚动开始
        if syncToOthers {
            notifyHorizontalScrollWillBegin()
        }
        
        // 使用 setXOffset 设置偏移（会自动重置锁定状态）
        setXOffset(targetX, animated: animated)
        if syncToOthers {
            notifyHorizontalContentOffsetChanged()
        }
        
        isIndicatorScrolling = false
        resetScrollLock()
        updateVisibleCellIndicators()
        
        if syncToOthers {
            notifyHorizontalScrollDidEnd()
        }
    }
   
    private func resetScrollLock() {
        initialOffset = collectionView.contentOffset
        isHorizontalLocked = false
        isVerticalLocked = false
    }

    /// 检测最左侧日期是否改变，改变则回调 onDateChanged
    func checkAndNotifyDateChanged() {
        let date = timelineLayout.dateForXPosition(collectionView.contentOffset.x)

        // 仅当「天」发生变化时通知
        if let last = lastNotifiedDate, Calendar.current.isDate(last, inSameDayAs: date) {
            return
        }

        lastNotifiedDate = date
        onDateChanged?(date)
    }
    
    // MARK: - 内部方法
    
    private func updateVisibleCellIndicators() {
        for cell in collectionView.visibleCells {
            if let timelineCell = cell as? TimelineCell,
               let indexPath = collectionView.indexPath(for: cell),
               let task = timelineLayout.taskAtIndex(indexPath.item) {
                
                let x = timelineLayout.xPositionForDate(task.startDate)
                let width = timelineLayout.widthForDuration(from: task.startDate, to: task.endDate)
                
                let visibleRect = CGRect(
                    x: collectionView.contentOffset.x,
                    y: 0,
                    width: collectionView.bounds.width,
                    height: rowHeight
                )
                
                timelineCell.configure(
                    task: task,
                    x: x,
                    width: width,
                    rowHeight: rowHeight,
                    visibleRect: visibleRect
                )
            }
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension GanttTimelineChartView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timelineLayout.visibleTaskCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TimelineCell.reuseIdentifier,
            for: indexPath
        ) as! TimelineCell
        
        if let task = timelineLayout.taskAtIndex(indexPath.item) {
            let x = timelineLayout.xPositionForDate(task.startDate)
            let width = timelineLayout.widthForDuration(from: task.startDate, to: task.endDate)
            
            let visibleRect = CGRect(
                x: collectionView.contentOffset.x,
                y: 0,
                width: collectionView.bounds.width,
                height: rowHeight
            )
            
            cell.configure(
                task: task,
                x: x,
                width: width,
                rowHeight: rowHeight,
                visibleRect: visibleRect
            )
            
            // 使用 weak self 避免循环引用
            cell.onLeftIndicatorTapped = { [weak self] in
                self?.scrollToTaskStart(task)
            }
            cell.onRightIndicatorTapped = { [weak self] in
                self?.scrollToTaskEnd(task)
            }
        }
        
        cell.backgroundColor = indexPath.item % 2 == 0
            ? GanttTimelineConfig.taskListOddRowColor
            : GanttTimelineConfig.taskListEvenRowColor
        
        return cell
    }
}

// MARK: - 修改后的 UIScrollViewDelegate 扩展

extension GanttTimelineChartView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 用户手动拖动时重置状态
        if !isIndicatorScrolling {
            initialOffset = scrollView.contentOffset
            isHorizontalLocked = false
            isVerticalLocked = false
            
            // 通知滚动同步代理
            notifyHorizontalScrollWillBegin()
            notifyVerticalScrollWillBegin()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 如果是指示器触发的滚动，跳过方向锁定
        if isIndicatorScrolling {
            updateVisibleCellIndicators()
            checkAndNotifyDateChanged()
            return
        }
        
        // 方向锁定
        if !isHorizontalLocked && !isVerticalLocked {
            let dx = abs(scrollView.contentOffset.x - initialOffset.x)
            let dy = abs(scrollView.contentOffset.y - initialOffset.y)
            
            if dx > 5 || dy > 5 {
                if dx > dy {
                    isHorizontalLocked = true
                } else {
                    isVerticalLocked = true
                }
            }
        }
        
        if isHorizontalLocked {
            if scrollView.contentOffset.y != initialOffset.y {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: initialOffset.y)
            }
            
            // 通知横向滚动同步
            notifyHorizontalContentOffsetChanged()

            // 检测最左侧日期是否改变
            checkAndNotifyDateChanged()
        } else if isVerticalLocked {
            if scrollView.contentOffset.x != initialOffset.x {
                scrollView.contentOffset = CGPoint(x: initialOffset.x, y: scrollView.contentOffset.y)
            }
            
            // 通知外部垂直滚动
            onVerticalScroll?(scrollView.contentOffset.y)
            
            // 通知垂直滚动同步
            notifyVerticalContentOffsetChanged()
        }
        
        updateVisibleCellIndicators()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !isIndicatorScrolling {
            isHorizontalLocked = false
            isVerticalLocked = false
            
            // 通知滚动结束
            notifyHorizontalScrollDidEnd()
            notifyVerticalScrollDidEnd()
        }
        updateVisibleCellIndicators()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && !isIndicatorScrolling {
            isHorizontalLocked = false
            isVerticalLocked = false
            updateVisibleCellIndicators()
            
            // 通知滚动结束
            notifyHorizontalScrollDidEnd()
            notifyVerticalScrollDidEnd()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 动画滚动结束后重置状态
        isIndicatorScrolling = false
        resetScrollLock()
        updateVisibleCellIndicators()
        
        // 通知滚动结束
        notifyHorizontalScrollDidEnd()
        notifyVerticalScrollDidEnd()
    }
}


// MARK: - GanttTimelineChartView 滚动同步扩展

extension GanttTimelineChartView: HorizontalScrollSyncable, VerticalScrollSyncable {
    
    // MARK: - 横向滚动同步
    
    var xOffset: CGFloat {
        get {
            return collectionView.contentOffset.x
        }
        set {
            // 重置方向锁定
            isHorizontalLocked = false
            isVerticalLocked = false
            initialOffset = CGPoint(x: newValue, y: collectionView.contentOffset.y)
            
            collectionView.contentOffset = CGPoint(
                x: newValue,
                y: collectionView.contentOffset.y
            )
            
            checkAndNotifyDateChanged()
        }
    }
    
    func setXOffset(_ xOffset: CGFloat, animated: Bool) {
        // 重置方向锁定
        isHorizontalLocked = false
        isVerticalLocked = false
        initialOffset = CGPoint(x: xOffset, y: collectionView.contentOffset.y)
        
        collectionView.setContentOffset(
            CGPoint(x: xOffset, y: collectionView.contentOffset.y),
            animated: animated
        )
    }

    var horizontalScrollSyncDelegate: HorizontalScrollSyncDelegate? {
        get {
            return collectionView.horizontalScrollSyncDelegate
        }
        set {
            collectionView.horizontalScrollSyncDelegate = newValue
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
    
    // MARK: - 垂直滚动同步
    
    var yOffset: CGFloat {
        get {
            return collectionView.contentOffset.y
        }
        set {
            // 重置方向锁定
            isHorizontalLocked = false
            isVerticalLocked = false
            initialOffset = CGPoint(x: collectionView.contentOffset.x, y: newValue)
            
            collectionView.contentOffset = CGPoint(
                x: collectionView.contentOffset.x,
                y: newValue
            )
        }
    }
    
    func setYOffset(_ yOffset: CGFloat, animated: Bool) {
        // 重置方向锁定
        isHorizontalLocked = false
        isVerticalLocked = false
        initialOffset = CGPoint(x: collectionView.contentOffset.x, y: yOffset)
        
        collectionView.setContentOffset(
            CGPoint(x: collectionView.contentOffset.x, y: yOffset),
            animated: animated
        )
    }
    
    var verticalScrollSyncDelegate: VerticalScrollSyncDelegate? {
        get {
            return collectionView.verticalScrollSyncDelegate
        }
        set {
            collectionView.verticalScrollSyncDelegate = newValue
        }
    }
    
    func notifyVerticalScrollWillBegin() {
        verticalScrollSyncDelegate?.verticalScrollSyncViewWillBeginScrolling(self)
    }
    
    func notifyVerticalScrollDidEnd() {
        verticalScrollSyncDelegate?.verticalScrollSyncViewDidEndScrolling(self)
    }
    
    func notifyVerticalContentOffsetChanged() {
        verticalScrollSyncDelegate?.verticalScrollSyncView(self, didChangeYOffset: yOffset)
    }
}
