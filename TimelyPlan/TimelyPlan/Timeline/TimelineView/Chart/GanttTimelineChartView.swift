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
    var tasks: [GanttEvent] = []
    
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
        
        let count = itemCount()
        totalHeight = CGFloat(count) * rowHeight
        
        for index in 0..<count {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let y = CGFloat(index) * rowHeight
            attributes.frame = CGRect(x: 0, y: y, width: totalWidth, height: rowHeight)
            cachedAttributes[indexPath] = attributes
        }
    }
    
    /// 无任务时生成的占位行数量（固定值，覆盖常见可视高度）
    private static let placeholderRowCount = 20
    
    /// 实际 item 数量（与数据源 numberOfItems 保持一致）。
    /// 无任务时返回固定占位行数量，填满可视区域，避免空白页。
    func itemCount() -> Int {
        guard tasks.isEmpty else {
            return tasks.count
        }
        return Self.placeholderRowCount
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
    
    func taskAtIndex(_ index: Int) -> GanttEvent? {
        guard index < tasks.count else { return nil }
        return tasks[index]
    }
    
    var visibleTaskCount: Int {
        return itemCount()
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
    private var titleLabel: TPLabel!
    
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
        
        titleLabel = TPLabel()
        titleLabel.font = .boldSystemFont(ofSize: 12.0)
        titleLabel.edgeInsets = UIEdgeInsets(horizontal: 8.0)
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
    
    /// bar 布局所需的几何信息（裁剪到内容区域后）
    private struct BarLayout {
        let barLeft: CGFloat
        let barRight: CGFloat
        let barWidth: CGFloat
        let barHeight: CGFloat
        let barY: CGFloat
        let visibleLeft: CGFloat
        let visibleRight: CGFloat
        let visibleBarWidth: CGFloat
    }
    
    func configure(task: GanttEvent,
                   x: CGFloat,
                   width: CGFloat,
                   rowHeight: CGFloat,
                   visibleRect: CGRect,
                   contentMaxX: CGFloat) {
        // 裁剪到内容区域；若完全越界则不绘制
        guard let layout = makeBarLayout(x: x,
                                         width: width,
                                         rowHeight: rowHeight,
                                         visibleRect: visibleRect,
                                         contentMaxX: contentMaxX) else {
            resetBarViews(taskName: task.name)
            return
        }
        
        layoutBar(task: task, layout: layout)
        layoutIndicators(layout: layout)
        layoutTitle(task: task, layout: layout)
    }
    
    /// 计算并裁剪 bar 的几何信息；返回 nil 表示 bar 完全在内容区域之外
    private func makeBarLayout(x: CGFloat,
                               width: CGFloat,
                               rowHeight: CGFloat,
                               visibleRect: CGRect,
                               contentMaxX: CGFloat) -> BarLayout? {
        var barWidth = max(width, GanttTimelineConfig.barMinWidth)
        var barLeft = x
        var barRight = x + barWidth
        
        // 左边界越界（任务早于 startDate）：裁剪到 0
        if barLeft < 0 {
            barRight -= barLeft
            barLeft = 0
        }
        // 右边界越界（任务晚于 endDate）：裁剪到 contentMaxX
        if barRight > contentMaxX {
            barRight = contentMaxX
        }
        barWidth = max(barRight - barLeft, 0)
        guard barWidth > 0 else { return nil }
        
        // 计算 bar 高度：默认 rowHeight - 上下间距，超过最大高度则以最大高度显示
        let defaultHeight = rowHeight - GanttTimelineConfig.barVerticalInset * 2
        let barHeight = min(defaultHeight, GanttTimelineConfig.barMaxHeight)
        let barY = (rowHeight - barHeight) / 2
        
        let visibleLeft = visibleRect.minX
        let visibleRight = visibleRect.maxX
        let barVisibleLeft = max(barLeft, visibleLeft)
        let barVisibleRight = min(barRight, visibleRight)
        let visibleBarWidth = max(barVisibleRight - barVisibleLeft, 0)
        
        return BarLayout(barLeft: barLeft,
                         barRight: barRight,
                         barWidth: barWidth,
                         barHeight: barHeight,
                         barY: barY,
                         visibleLeft: visibleLeft,
                         visibleRight: visibleRight,
                         visibleBarWidth: visibleBarWidth)
    }
    
    /// 设置甘特条及进度视图
    private func layoutBar(task: GanttEvent, layout: BarLayout) {
        barView.frame = CGRect(x: layout.barLeft,
                               y: layout.barY,
                               width: layout.barWidth,
                               height: layout.barHeight)
        barView.backgroundColor = task.color.withAlphaComponent(0.3)
        
        progressView.frame = CGRect(x: 0,
                                    y: 0,
                                    width: layout.barWidth * task.progress,
                                    height: layout.barHeight)
        progressView.backgroundColor = task.color
    }
    
    /// 更新左右边缘指示器的显示与位置
    private func layoutIndicators(layout: BarLayout) {
        let indicatorSize = GanttTimelineConfig.indicatorSize
        let indicatorMargin = 10.0
        let indicatorY = (layout.barY * 2 + layout.barHeight - indicatorSize) / 2
        
        // 左侧指示器
        if layout.barLeft < layout.visibleLeft {
            leftEdgeIndicator.isHidden = false
            leftEdgeIndicator.frame = CGRect(
                x: layout.visibleLeft + indicatorMargin,
                y: indicatorY,
                width: indicatorSize,
                height: indicatorSize
            )
            leftEdgeIndicator.alpha = 1.0
        } else {
            leftEdgeIndicator.isHidden = true
            leftEdgeIndicator.alpha = 0.0
        }
        
        // 右侧指示器
        if layout.barRight > layout.visibleRight {
            rightEdgeIndicator.isHidden = false
            rightEdgeIndicator.frame = CGRect(
                x: layout.visibleRight - indicatorSize - indicatorMargin,
                y: indicatorY,
                width: indicatorSize,
                height: indicatorSize
            )
            rightEdgeIndicator.alpha = 1.0
        } else {
            rightEdgeIndicator.isHidden = true
            rightEdgeIndicator.alpha = 0.0
        }
    }
    
    /// 根据 bar 与可视区域的关系定位标题
    private func layoutTitle(task: GanttEvent, layout: BarLayout) {
        titleLabel.text = task.name
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        
        // 标题可以显示在 bar 中的最小宽度
        if layout.barWidth < 240.0 {
            layoutTitleBesideBar(layout: layout)
            return
        }
        layoutTitleInBar(layout: layout)
    }
    
    /// 标题显示在 bar 两侧（bar 过窄时）
    private func layoutTitleBesideBar(layout: BarLayout) {
        let titleMaxWidth = 180.0
        var titleWidth = titleLabel.sizeThatFits(.unlimited).width
        titleWidth = min(titleWidth, titleMaxWidth)
        
        let labelX: CGFloat
        if layout.visibleRight - layout.barRight < titleWidth {
            if rightEdgeIndicator.isHidden {
                labelX = layout.barLeft - titleWidth
            } else {
                labelX = min(layout.barLeft, rightEdgeIndicator.left) - titleWidth
            }
        } else {
            if leftEdgeIndicator.isHidden {
                labelX = layout.barRight
            } else {
                labelX = max(layout.barRight, leftEdgeIndicator.right)
            }
        }
        
        titleLabel.frame = CGRect(x: labelX,
                                  y: layout.barY,
                                  width: titleWidth,
                                  height: layout.barHeight)
        titleLabel.textColor = .label
    }
    
    /// 标题显示在 bar 中
    private func layoutTitleInBar(layout: BarLayout) {
        let titleMaxWidth = min((layout.visibleRight - layout.visibleLeft) / 2.0, layout.barWidth)
        var titleWidth = titleLabel.sizeThatFits(.unlimited).width
        titleWidth = min(titleWidth, titleMaxWidth)
        
        let applyTitleFrame: (CGFloat) -> Void = { labelX in
            self.titleLabel.frame = CGRect(x: labelX,
                                           y: layout.barY,
                                           width: titleWidth,
                                           height: layout.barHeight)
            let labelRight = labelX + titleWidth
            let onBar = labelRight >= layout.barLeft && labelX <= layout.barRight
            self.titleLabel.textColor = onBar ? .white : .label
        }
        
        // 标题能完整容纳在可见 bar 内，默认在可见区域居中
        if titleWidth <= layout.visibleBarWidth {
            let barVisibleLeft = max(layout.barLeft, layout.visibleLeft)
            applyTitleFrame(barVisibleLeft + (layout.visibleBarWidth - titleWidth) / 2)
            return
        }
        
        let indicatorLength = GanttTimelineConfig.indicatorSize + 10.0
        
        // bar 从左侧消失，标题固定在左侧指示器右侧
        if layout.barRight <= layout.visibleLeft + indicatorLength {
            applyTitleFrame(leftEdgeIndicator.right)
            return
        }
        
        // bar 从右侧消失，标题固定在右侧指示器左侧
        if layout.barLeft >= layout.visibleRight - indicatorLength {
            applyTitleFrame(rightEdgeIndicator.left - titleWidth)
            return
        }
        
        // bar 左端越过可视区域左边缘附近，标题贴在 bar 右端
        if layout.visibleLeft + indicatorLength > layout.barLeft,
           layout.visibleLeft + indicatorLength < layout.barRight {
            applyTitleFrame(layout.barRight - titleWidth)
            return
        }
        
        // bar 右端越过可视区域右边缘附近，标题贴在 bar 左端
        if layout.visibleRight - indicatorLength > layout.barLeft,
           layout.visibleRight - indicatorLength < layout.barRight {
            applyTitleFrame(layout.barLeft)
            return
        }
        
        // 兜底：bar 整体可见但宽度不足以容纳标题，以 bar 整体居中
        applyTitleFrame(layout.barLeft + (layout.barWidth - titleWidth) / 2)
    }
    
    /// bar 完全越界时重置子视图
    private func resetBarViews(taskName: String) {
        barView.frame = .zero
        progressView.frame = .zero
        titleLabel.text = taskName
        titleLabel.frame = .zero
        leftEdgeIndicator.isHidden = true
        rightEdgeIndicator.isHidden = true
    }

    /// 重置为占位行（无任务），仅显示背景色
    func resetAsPlaceholder() {
        barView.frame = .zero
        progressView.frame = .zero
        titleLabel.text = nil
        titleLabel.frame = .zero
        leftEdgeIndicator.isHidden = true
        rightEdgeIndicator.isHidden = true
        onLeftIndicatorTapped = nil
        onRightIndicatorTapped = nil
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
    private var rowHeight: CGFloat = GanttRowHeightType.medium.rowHeight
    
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
    var tasks: [GanttEvent] = [] {
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
    
    // MARK: - 行高设置

    /// 设置行高类型（宽松/中等/紧凑）
    func setRowHeightType(_ type: GanttRowHeightType) {
        setRowHeight(type.rowHeight)
    }

    /// 设置行高
    func setRowHeight(_ height: CGFloat) {
        guard rowHeight != height else { return }
        rowHeight = height
        timelineLayout.rowHeight = height
        timelineLayout.invalidateLayout()
        collectionView.reloadData()
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
    
    func taskAtIndex(_ index: Int) -> GanttEvent? {
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

    func scrollToTaskStart(_ task: GanttEvent) {
        let xPos = timelineLayout.xPositionForDate(task.startDate)
        let targetX = max(0, xPos - 20)
        performHorizontalScroll(to: targetX, animated: true)
    }

    func scrollToTaskEnd(_ task: GanttEvent) {
        let xPos = timelineLayout.xPositionForDate(task.endDate)
        let visibleWidth = collectionView.bounds.width
        let targetX = max(0, xPos - visibleWidth + 20)
        performHorizontalScroll(to: targetX, animated: true)
    }

    /// 将目标 X 偏移限制在合法的滚动范围内，避免滚动到内容之外的空白位置
    private func clampHorizontalOffset(_ x: CGFloat) -> CGFloat {
        let maxOffsetX = max(0, collectionView.contentSize.width - collectionView.bounds.width)
        return max(0, min(x, maxOffsetX))
    }

    private func performHorizontalScroll(to targetX: CGFloat, animated: Bool, syncToOthers: Bool = true) {
        isIndicatorScrolling = true
        
        // 通知滚动开始
        if syncToOthers {
            notifyHorizontalScrollWillBegin()
        }
        
        // 将偏移限制在内容范围内，避免任务日期超出 scale 范围时滚动到空白位置
        let clampedX = clampHorizontalOffset(targetX)
        
        // 使用 setXOffset 设置偏移（会自动重置锁定状态）
        setXOffset(clampedX, animated: animated)
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
                    visibleRect: visibleRect,
                    contentMaxX: collectionView.contentSize.width
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
                visibleRect: visibleRect,
                contentMaxX: collectionView.contentSize.width
            )
            
            // 使用 weak self 避免循环引用
            cell.onLeftIndicatorTapped = { [weak self] in
                self?.scrollToTaskStart(task)
            }
            cell.onRightIndicatorTapped = { [weak self] in
                self?.scrollToTaskEnd(task)
            }
        } else {
            // 占位行：仅显示奇偶相间背景色
            cell.resetAsPlaceholder()
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
