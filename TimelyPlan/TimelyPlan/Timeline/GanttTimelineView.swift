//
//  GanttTimelineView.swift
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
    
    private var flattenedTasks: [(task: GanttTask, indent: Int)] = []
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
        flattenTasks()
        
        totalWidth = calculateTimeAxisWidth()
        totalHeight = CGFloat(flattenedTasks.count) * rowHeight
        
        for (index, _) in flattenedTasks.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let y = CGFloat(index) * rowHeight
            attributes.frame = CGRect(x: 0, y: y, width: totalWidth, height: rowHeight)
            cachedAttributes[indexPath] = attributes
        }
    }
    
    private func flattenTasks() {
        flattenedTasks.removeAll()
        for task in tasks {
            addTask(task, indent: 0)
        }
    }
    
    private func addTask(_ task: GanttTask, indent: Int) {
        flattenedTasks.append((task: task, indent: indent))
        if task.isExpanded, let children = task.children {
            for child in children {
                addTask(child, indent: indent + 1)
            }
        }
    }
    
    private func calculateTimeAxisWidth() -> CGFloat {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: timeScale.startDate, to: timeScale.endDate).day ?? 30
        
        switch timeScale.scale {
        case .day:
            return CGFloat(days) * timeScale.scale.pixelsPerUnit
        case .week:
            let weeks = ceil(Double(days) / 7.0)
            return CGFloat(weeks) * timeScale.scale.pixelsPerUnit
        case .month:
            let months = calendar.dateComponents([.month], from: timeScale.startDate, to: timeScale.endDate).month ?? 1
            return CGFloat(months + 1) * timeScale.scale.pixelsPerUnit
        }
    }
    
    func taskAtIndex(_ index: Int) -> GanttTask? {
        guard index < flattenedTasks.count else { return nil }
        return flattenedTasks[index].task
    }
    
    var visibleTaskCount: Int {
        return flattenedTasks.count
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
        button.cornerRadius = 8.0
        button.normalBackgroundColor = .secondarySystemBackground
        button.normalImage = resGetImage("chevron_left_24")
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.addTarget(self, action: #selector(leftIndicatorTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var rightEdgeIndicator: TPImageButton = {
        let button = TPImageButton()
        button.cornerRadius = 8.0
        button.normalBackgroundColor = .secondarySystemBackground
        button.normalImage = resGetImage("chevron_right_24")
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
        barView.addSubview(titleLabel)
        contentView.addSubview(leftEdgeIndicator)
        contentView.addSubview(rightEdgeIndicator)
    }
    
    func configure(task: GanttTask,
                   x: CGFloat,
                   width: CGFloat,
                   rowHeight: CGFloat,
                   visibleRect: CGRect) {
        let y: CGFloat = 6
        let height: CGFloat = rowHeight - 12
        
        // 设置甘特条
        barView.frame = CGRect(x: x, y: y, width: max(width, 2), height: height)
        barView.backgroundColor = task.color.withAlphaComponent(0.3)
        
        progressView.frame = CGRect(x: 0, y: 0, width: max(width, 2) * task.progress, height: height)
        progressView.backgroundColor = task.color
        
        titleLabel.frame = CGRect(x: 4, y: 0, width: max(width, 2) - 8, height: height)
        titleLabel.text = task.name
        
        // 计算甘特条与可视区域的关系
        let barLeft = x
        let barRight = x + max(width, 2)
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
class GanttTimelineView: UIView {
    
    // 布局
    private var collectionView: UICollectionView!
    private var timelineLayout: GanttTimelineLayout!
    
    // 布局常量
    private let rowHeight: CGFloat = 44
    
    // 滚动方向锁定
    private var initialOffset: CGPoint = .zero
    private var isHorizontalLocked = false
    private var isVerticalLocked = false
    
    // 指示器动画标志
    private var isIndicatorScrolling = false
    
    // 滚动同步回调
    var onVerticalScroll: ((CGFloat) -> Void)?
    
    // 展开/折叠回调
    var onExpandTapped: ((Int) -> Void)?
    
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
        backgroundColor = .white
        clipsToBounds = true
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        timelineLayout = GanttTimelineLayout(timeScale: timeScale)
        timelineLayout.tasks = []
        timelineLayout.rowHeight = rowHeight
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: timelineLayout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        
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
    
    func scrollToToday(animated: Bool = true) {
        let xPos = timelineLayout.xPositionForDate(Date())
        let targetX = max(0, xPos - 100)
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
    
    // MARK: - 修复：使用专门的滚动方法
    
    private func performHorizontalScroll(to targetX: CGFloat, animated: Bool) {
        // 设置标志，暂时禁用方向锁定
        isIndicatorScrolling = true
        
        let currentY = collectionView.contentOffset.y
        let targetOffset = CGPoint(x: targetX, y: currentY)
        
        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                options: [.curveEaseInOut, .allowUserInteraction],
                animations: { [weak self] in
                    self?.collectionView.setContentOffset(targetOffset, animated: false)
                },
                completion: { [weak self] _ in
                    self?.isIndicatorScrolling = false
                    self?.resetScrollLock()
                }
            )
        } else {
            collectionView.setContentOffset(targetOffset, animated: false)
            isIndicatorScrolling = false
            resetScrollLock()
        }
    }
    
    private func resetScrollLock() {
        initialOffset = collectionView.contentOffset
        isHorizontalLocked = false
        isVerticalLocked = false
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
extension GanttTimelineView: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        
        cell.backgroundColor = indexPath.item % 2 == 0 ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension GanttTimelineView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 用户手动拖动时重置状态
        if !isIndicatorScrolling {
            initialOffset = scrollView.contentOffset
            isHorizontalLocked = false
            isVerticalLocked = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 如果是指示器触发的滚动，跳过方向锁定
        if isIndicatorScrolling {
            updateVisibleCellIndicators()
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
        } else if isVerticalLocked {
            if scrollView.contentOffset.x != initialOffset.x {
                scrollView.contentOffset = CGPoint(x: initialOffset.x, y: scrollView.contentOffset.y)
            }
            
            // 通知外部垂直滚动
            onVerticalScroll?(scrollView.contentOffset.y)
        }
        
        updateVisibleCellIndicators()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !isIndicatorScrolling {
            isHorizontalLocked = false
            isVerticalLocked = false
        }
        updateVisibleCellIndicators()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && !isIndicatorScrolling {
            isHorizontalLocked = false
            isVerticalLocked = false
            updateVisibleCellIndicators()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 动画滚动结束后重置状态
        isIndicatorScrolling = false
        resetScrollLock()
        updateVisibleCellIndicators()
    }
}
