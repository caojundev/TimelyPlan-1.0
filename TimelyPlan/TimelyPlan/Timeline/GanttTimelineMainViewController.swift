//
//  GanttTimelineMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/23.
//

import Foundation
import UIKit

// MARK: - 数据模型
struct GanttTask {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date
    let progress: CGFloat
    let color: UIColor
    let level: Int
    var isExpanded: Bool = true
    var children: [GanttTask]? = nil
    var isGroup: Bool { return children != nil && !children!.isEmpty }
}

struct GanttTimeScale {
    enum Scale {
        case day, week, month
        
        var pixelsPerUnit: CGFloat {
            switch self {
            case .day: return 60
            case .week: return 100
            case .month: return 150
            }
        }
    }
    
    var scale: Scale = .day
    let startDate: Date
    let endDate: Date
}

// MARK: - 左侧任务名称 Cell
class TaskNameCell: UICollectionViewCell {
    static let reuseIdentifier = "TaskNameCell"
    
    private let nameLabel = UILabel()
    private let expandButton = UIButton(type: .system)
    private let separatorLine = UIView()
    
    var onExpandTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        expandButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        expandButton.tintColor = .gray
        expandButton.addTarget(self, action: #selector(expandTapped), for: .touchUpInside)
        expandButton.isHidden = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.textColor = .darkText
        nameLabel.numberOfLines = 2
        
        separatorLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        contentView.addSubview(expandButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(separatorLine)
    }
    
    func configure(task: GanttTask, indent: Int) {
        nameLabel.text = task.name
        
        let baseX: CGFloat = task.isGroup ? 28 : 8
        let xPosition = baseX + CGFloat(indent) * 16
        
        nameLabel.frame = CGRect(
            x: xPosition,
            y: 0,
            width: bounds.width - xPosition - 8,
            height: bounds.height
        )
        
        expandButton.isHidden = !task.isGroup
        expandButton.frame = CGRect(
            x: 4 + CGFloat(indent) * 16,
            y: (bounds.height - 20) / 2,
            width: 20,
            height: 20
        )
        let imageName = task.isExpanded ? "chevron.down" : "chevron.right"
        expandButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        separatorLine.frame = CGRect(x: bounds.width - 1, y: 0, width: 1, height: bounds.height)
    }
    
    @objc private func expandTapped() {
        onExpandTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        expandButton.isHidden = true
    }
}

// MARK: - 右侧时间轴 Cell（完善指示器显示逻辑）
class TimelineCell: UICollectionViewCell {
    static let reuseIdentifier = "TimelineCell"
    
    private var barView: UIView!
    private var progressView: UIView!
    private var titleLabel: UILabel!
    
    // 可视区域边缘指示器
    private var leftEdgeIndicator: UIButton!
    private var rightEdgeIndicator: UIButton!
    
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
        
        // 左侧边缘指示器
        leftEdgeIndicator = UIButton(type: .custom)
        leftEdgeIndicator.backgroundColor = .white
        leftEdgeIndicator.layer.cornerRadius = 12
        leftEdgeIndicator.layer.borderWidth = 1
        leftEdgeIndicator.layer.borderColor = UIColor.systemBlue.cgColor
        leftEdgeIndicator.layer.shadowColor = UIColor.black.cgColor
        leftEdgeIndicator.layer.shadowOffset = CGSize(width: 1, height: 1)
        leftEdgeIndicator.layer.shadowRadius = 2
        leftEdgeIndicator.layer.shadowOpacity = 0.3
        leftEdgeIndicator.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        leftEdgeIndicator.tintColor = .systemBlue
        leftEdgeIndicator.addTarget(self, action: #selector(leftIndicatorTapped), for: .touchUpInside)
        leftEdgeIndicator.isHidden = true
        
        // 右侧边缘指示器
        rightEdgeIndicator = UIButton(type: .custom)
        rightEdgeIndicator.backgroundColor = .white
        rightEdgeIndicator.layer.cornerRadius = 12
        rightEdgeIndicator.layer.borderWidth = 1
        rightEdgeIndicator.layer.borderColor = UIColor.systemBlue.cgColor
        rightEdgeIndicator.layer.shadowColor = UIColor.black.cgColor
        rightEdgeIndicator.layer.shadowOffset = CGSize(width: -1, height: 1)
        rightEdgeIndicator.layer.shadowRadius = 2
        rightEdgeIndicator.layer.shadowOpacity = 0.3
        rightEdgeIndicator.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightEdgeIndicator.tintColor = .systemBlue
        rightEdgeIndicator.addTarget(self, action: #selector(rightIndicatorTapped), for: .touchUpInside)
        rightEdgeIndicator.isHidden = true
        
        contentView.addSubview(barView)
        barView.addSubview(progressView)
        barView.addSubview(titleLabel)
        contentView.addSubview(leftEdgeIndicator)
        contentView.addSubview(rightEdgeIndicator)
    }
    
    func configure(task: GanttTask, x: CGFloat, width: CGFloat, rowHeight: CGFloat,
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
        
        // 指示器尺寸和位置
        let indicatorSize: CGFloat = 24
        let indicatorY = (rowHeight - indicatorSize) / 2
        
        // 左侧指示器：甘特条左端超出可视区域左边界（部分或完全在左侧不可见）
        let showLeftIndicator = barLeft < visibleLeft
        leftEdgeIndicator.isHidden = !showLeftIndicator
        if showLeftIndicator {
            // 固定在可视区域左边缘
            leftEdgeIndicator.frame = CGRect(
                x: visibleLeft + 2,
                y: indicatorY,
                width: indicatorSize,
                height: indicatorSize
            )
            // 使用向左的箭头表示任务左端在左侧不可见
            leftEdgeIndicator.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        }
        
        // 右侧指示器：甘特条右端超出可视区域右边界（部分或完全在右侧不可见）
        let showRightIndicator = barRight > visibleRight
        rightEdgeIndicator.isHidden = !showRightIndicator
        if showRightIndicator {
            // 固定在可视区域右边缘
            rightEdgeIndicator.frame = CGRect(
                x: visibleRight - indicatorSize - 2,
                y: indicatorY,
                width: indicatorSize,
                height: indicatorSize
            )
            // 使用向右的箭头表示任务右端在右侧不可见
            rightEdgeIndicator.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    
    @objc private func leftIndicatorTapped() {
        onLeftIndicatorTapped?()
    }
    
    @objc private func rightIndicatorTapped() {
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

// MARK: - 左侧 Header View（改为 UIView 子类）
class TaskHeaderView: UIView {
    static let reuseIdentifier = "TaskHeaderView"
    
    private let titleLabel = UILabel()
    private let separatorLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
        
        titleLabel.text = "任务名称"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        
        separatorLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        addSubview(titleLabel)
        addSubview(separatorLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
        separatorLine.frame = CGRect(x: bounds.width - 1, y: 0, width: 1, height: bounds.height)
    }
}


// MARK: - 右侧时间轴 Header View
class TimelineHeaderView: UIView {
    static let reuseIdentifier = "TimelineHeaderView"
    
    private var timeScale: GanttTimeScale!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        isOpaque = true
        contentMode = .redraw // 重要：内容变化时重绘
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(timeScale: GanttTimeScale) {
        self.timeScale = timeScale
        setNeedsDisplay()
    }
    
    // 当 frame 变化时触发重绘
    override var frame: CGRect {
        didSet {
            if oldValue.size != frame.size {
                setNeedsDisplay()
            }
        }
    }
    
    // 当 bounds 变化时触发重绘
    override var bounds: CGRect {
        didSet {
            if oldValue.size != bounds.size {
                setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext(),
              let timeScale = timeScale else { return }
        
        // 清空背景
        context.clear(rect)
        
        // 设置背景色
        context.setFillColor(UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0).cgColor)
        context.fill(rect)
        
        let calendar = Calendar.current
        
        // 绘制今天的红线
        let now = Date()
        if let todayStart = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) {
            let todayX = xPositionForDate(todayStart, timeScale: timeScale)
            
            var adjustedX = todayX
            switch timeScale.scale {
            case .day:
                let startOfDay = calendar.startOfDay(for: now)
                let elapsedTime = now.timeIntervalSince(startOfDay)
                let dayDuration: TimeInterval = 86400
                let dayProgress = CGFloat(elapsedTime / dayDuration)
                adjustedX = todayX + timeScale.scale.pixelsPerUnit * dayProgress
            case .week:
                adjustedX = todayX + timeScale.scale.pixelsPerUnit / 2
            case .month:
                adjustedX = todayX + timeScale.scale.pixelsPerUnit / 2
            }
            
            if adjustedX >= 0 && adjustedX <= rect.width {
                context.setStrokeColor(UIColor.red.cgColor)
                context.setLineWidth(2)
                context.move(to: CGPoint(x: adjustedX, y: 0))
                context.addLine(to: CGPoint(x: adjustedX, y: rect.height))
                context.strokePath()
                
                let todayLabel = "今天" as NSString
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.red
                ]
                todayLabel.draw(at: CGPoint(x: adjustedX - 12, y: 2), withAttributes: attributes)
            }
        }
        
        // 绘制时间刻度
        switch timeScale.scale {
        case .day:
            drawDayScale(context: context, rect: rect, timeScale: timeScale)
        case .week:
            drawWeekScale(context: context, rect: rect, timeScale: timeScale)
        case .month:
            drawMonthScale(context: context, rect: rect, timeScale: timeScale)
        }
    }
    
    private func xPositionForDate(_ date: Date, timeScale: GanttTimeScale) -> CGFloat {
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
    
    private func drawDayScale(context: CGContext, rect: CGRect, timeScale: GanttTimeScale) {
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: timeScale.startDate, to: timeScale.endDate).day ?? 30
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        var currentDate = timeScale.startDate
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "yyyy年M月"
        
        for day in 0...totalDays {
            let x = CGFloat(day) * timeScale.scale.pixelsPerUnit
            
            context.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: x, y: rect.height * 0.3))
            context.addLine(to: CGPoint(x: x, y: rect.height))
            context.strokePath()
            
            if calendar.component(.day, from: currentDate) == 1 || day == 0 {
                context.setStrokeColor(UIColor.gray.cgColor)
                context.setLineWidth(1)
                context.move(to: CGPoint(x: x, y: 0))
                context.addLine(to: CGPoint(x: x, y: rect.height))
                context.strokePath()
                
                let monthStr = monthFormatter.string(from: currentDate) as NSString
                monthStr.draw(
                    at: CGPoint(x: x + 2, y: 4),
                    withAttributes: [.font: UIFont.boldSystemFont(ofSize: 11)]
                )
            }
            
            let dateStr = dateFormatter.string(from: currentDate) as NSString
            dateStr.draw(
                at: CGPoint(x: x + 2, y: rect.height * 0.3 + 4),
                withAttributes: [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.gray]
            )
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
    }
    
    private func drawWeekScale(context: CGContext, rect: CGRect, timeScale: GanttTimeScale) {
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: timeScale.startDate, to: timeScale.endDate).day ?? 30
        let totalWeeks = Int(ceil(Double(totalDays) / 7.0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        
        for week in 0...totalWeeks {
            let x = CGFloat(week) * timeScale.scale.pixelsPerUnit
            
            context.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: x, y: rect.height * 0.3))
            context.addLine(to: CGPoint(x: x, y: rect.height))
            context.strokePath()
            
            if let weekStart = calendar.date(byAdding: .weekOfYear, value: week, to: timeScale.startDate) {
                let weekStr = "W\(calendar.component(.weekOfYear, from: weekStart))" as NSString
                weekStr.draw(
                    at: CGPoint(x: x + 2, y: 4),
                    withAttributes: [.font: UIFont.boldSystemFont(ofSize: 10)]
                )
                
                let dateStr = dateFormatter.string(from: weekStart) as NSString
                dateStr.draw(
                    at: CGPoint(x: x + 2, y: rect.height * 0.3 + 4),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.gray]
                )
            }
        }
    }
    
    private func drawMonthScale(context: CGContext, rect: CGRect, timeScale: GanttTimeScale) {
        let calendar = Calendar.current
        let totalMonths = (calendar.dateComponents([.month], from: timeScale.startDate, to: timeScale.endDate).month ?? 1) + 1
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月"
        
        for month in 0...totalMonths {
            let x = CGFloat(month) * timeScale.scale.pixelsPerUnit
            
            context.setStrokeColor(UIColor.gray.cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
            context.strokePath()
            
            if let monthDate = calendar.date(byAdding: .month, value: month, to: timeScale.startDate) {
                let monthStr = dateFormatter.string(from: monthDate) as NSString
                monthStr.draw(
                    at: CGPoint(x: x + 4, y: rect.height / 2 - 8),
                    withAttributes: [.font: UIFont.boldSystemFont(ofSize: 11)]
                )
            }
        }
    }
}




// MARK: - 右侧时间轴 Layout
class GanttTimelineLayout: UICollectionViewLayout {
    
    var rowHeight: CGFloat = 44
    var headerHeight: CGFloat = 0
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

// MARK: - 主视图控制器
class GanttChartViewController: UIViewController {
    
    // 左侧任务列表
    private var leftCollectionView: UICollectionView!
    private var leftLayout: UICollectionViewFlowLayout!
    
    // 右侧甘特图
    private var rightCollectionView: UICollectionView!
    private var rightLayout: GanttTimelineLayout!
    
    // 固定的顶部视图
    private var fixedLeftHeaderView: TaskHeaderView!
    private var fixedTimelineHeaderView: TimelineHeaderView!
    
    // 顶部时间轴的滚动容器
    private var timelineHeaderScrollView: UIScrollView!
    
    // 数据
    private var tasks: [GanttTask] = []
    private var timeScale: GanttTimeScale!
    private var allTasks: [GanttTask] = []
    
    // 滚动同步
    private var isSyncingScroll = false
    private var leftOffsetObservation: NSKeyValueObservation?
    private var rightOffsetObservation: NSKeyValueObservation?
    
    // 滚动方向锁定
    private var initialOffset: CGPoint = .zero
    private var isHorizontalLocked = false
    private var isVerticalLocked = false
    
    // 布局常量
    private let leftColumnWidth: CGFloat = 180
    private let headerHeight: CGFloat = 60
    private let rowHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTimeScale()
        setupTestData()
        setupFixedHeaders()
        setupLeftCollectionView()
        setupRightCollectionView()
        setupScrollSync()
        setupToolbar()
        
        // 延迟布局
        DispatchQueue.main.async { [weak self] in
            self?.layoutAllViews()
            self?.scrollToToday(animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutAllViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutAllViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutAllViews()
    }
    
    // MARK: - 布局方法
    
    private func layoutAllViews() {
        guard rightLayout != nil,
              leftCollectionView != nil,
              rightCollectionView != nil,
              fixedLeftHeaderView != nil,
              fixedTimelineHeaderView != nil,
              timelineHeaderScrollView != nil else { return }
        
        let safeAreaTop = view.safeAreaInsets.top
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        // 计算 toolbar 实际高度
        var toolbarHeight: CGFloat = 0
        if let toolbar = navigationController?.toolbar, !toolbar.isHidden {
            toolbarHeight = toolbar.frame.height
        }
        
        // 固定头部布局
        fixedLeftHeaderView.frame = CGRect(
            x: 0,
            y: safeAreaTop,
            width: leftColumnWidth,
            height: headerHeight
        )
        
        // 时间轴头部滚动容器
        timelineHeaderScrollView.frame = CGRect(
            x: leftColumnWidth,
            y: safeAreaTop,
            width: view.bounds.width - leftColumnWidth,
            height: headerHeight
        )
        
        // 更新头部内容
        updateHeaderContent()
        
        // CollectionView 布局
        let collectionViewTop = safeAreaTop + headerHeight
        let availableHeight = view.bounds.height - collectionViewTop - safeAreaBottom - toolbarHeight
        let collectionViewHeight = max(0, availableHeight)
        
        leftCollectionView.frame = CGRect(
            x: 0,
            y: collectionViewTop,
            width: leftColumnWidth,
            height: collectionViewHeight
        )
        
        rightCollectionView.frame = CGRect(
            x: leftColumnWidth,
            y: collectionViewTop,
            width: view.bounds.width - leftColumnWidth,
            height: collectionViewHeight
        )
        
        // 确保内容偏移正确
        leftCollectionView.contentInset = .zero
        rightCollectionView.contentInset = .zero
    }
    
    private func updateHeaderContent() {
        guard rightLayout != nil,
              timelineHeaderScrollView != nil,
              fixedTimelineHeaderView != nil else { return }
        
        // 获取内容宽度
        let layoutWidth = rightLayout.collectionViewContentSize.width
        let containerWidth = timelineHeaderScrollView.bounds.width
        let contentWidth = max(layoutWidth, containerWidth)
        
        // 关键：只有当宽度变化时才更新 frame，避免不必要的拉伸
        if fixedTimelineHeaderView.frame.width != contentWidth {
            fixedTimelineHeaderView.frame = CGRect(
                x: 0,
                y: 0,
                width: contentWidth,
                height: headerHeight
            )
            
            // 设置滚动容器内容大小
            timelineHeaderScrollView.contentSize = CGSize(
                width: contentWidth,
                height: headerHeight
            )
            
            // 重新配置并触发重绘
            fixedTimelineHeaderView.configure(timeScale: timeScale)
        }
        
        // 同步水平滚动位置
        if let rightCV = rightCollectionView {
            timelineHeaderScrollView.contentOffset.x = rightCV.contentOffset.x
        }
    }
    
    // MARK: - 初始化设置
    
    private func setupTimeScale() {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .month, value: -2, to: today)!
        let endDate = calendar.date(byAdding: .month, value: 3, to: today)!
        
        timeScale = GanttTimeScale(scale: .day, startDate: startDate, endDate: endDate)
    }
    
    private func setupTestData() {
        let calendar = Calendar.current
        let today = Date()
        
        var allTasksArray: [GanttTask] = []
        
        for phase in 1...10 {
            let phaseColor = UIColor(hue: CGFloat(phase) / 10.0, saturation: 0.6, brightness: 0.8, alpha: 1.0)
            
            var children: [GanttTask] = []
            for i in 1...5 {
                let child = GanttTask(
                    id: "\(phase).\(i)",
                    name: "阶段\(phase) - 任务\(i)",
                    startDate: calendar.date(byAdding: .day, value: (phase - 1) * 30 + i * 3, to: today)!,
                    endDate: calendar.date(byAdding: .day, value: (phase - 1) * 30 + i * 3 + 15, to: today)!,
                    progress: CGFloat(i) / 5.0,
                    color: phaseColor,
                    level: 1
                )
                children.append(child)
            }
            
            let group = GanttTask(
                id: "\(phase)",
                name: "阶段 \(phase)",
                startDate: calendar.date(byAdding: .day, value: (phase - 1) * 30, to: today)!,
                endDate: calendar.date(byAdding: .day, value: (phase - 1) * 30 + 25, to: today)!,
                progress: CGFloat(phase % 5) / 5.0,
                color: phaseColor,
                level: 0,
                children: children
            )
            allTasksArray.append(group)
        }
        
        allTasks = allTasksArray
        tasks = allTasksArray
    }
    
    private func setupFixedHeaders() {
        // 左侧固定头部
        fixedLeftHeaderView = TaskHeaderView(frame: .zero)
        view.addSubview(fixedLeftHeaderView)
        
        // 创建时间轴头部的滚动容器
        timelineHeaderScrollView = UIScrollView(frame: .zero)
        timelineHeaderScrollView.showsHorizontalScrollIndicator = false
        timelineHeaderScrollView.showsVerticalScrollIndicator = false
        timelineHeaderScrollView.bounces = false
        timelineHeaderScrollView.isScrollEnabled = false
        timelineHeaderScrollView.contentInsetAdjustmentBehavior = .never
        timelineHeaderScrollView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        timelineHeaderScrollView.clipsToBounds = true
        view.addSubview(timelineHeaderScrollView)
        
        // 创建时间轴头部视图
        fixedTimelineHeaderView = TimelineHeaderView(frame: .zero)
        fixedTimelineHeaderView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        fixedTimelineHeaderView.configure(timeScale: timeScale)
        timelineHeaderScrollView.addSubview(fixedTimelineHeaderView)
    }
    
    private func setupLeftCollectionView() {
        leftLayout = UICollectionViewFlowLayout()
        leftLayout.itemSize = CGSize(width: leftColumnWidth, height: rowHeight)
        leftLayout.minimumLineSpacing = 0
        leftLayout.minimumInteritemSpacing = 0
        leftLayout.headerReferenceSize = .zero
        
        leftCollectionView = UICollectionView(frame: .zero, collectionViewLayout: leftLayout)
        leftCollectionView.backgroundColor = .white
        leftCollectionView.delegate = self
        leftCollectionView.dataSource = self
        leftCollectionView.showsVerticalScrollIndicator = false
        leftCollectionView.showsHorizontalScrollIndicator = false
        leftCollectionView.bounces = false
        leftCollectionView.alwaysBounceVertical = false
        leftCollectionView.contentInsetAdjustmentBehavior = .never
        
        leftCollectionView.register(TaskNameCell.self, forCellWithReuseIdentifier: TaskNameCell.reuseIdentifier)
        
        view.addSubview(leftCollectionView)
    }
    
    private func setupRightCollectionView() {
        rightLayout = GanttTimelineLayout(timeScale: timeScale)
        rightLayout.tasks = tasks
        rightLayout.rowHeight = rowHeight
        rightLayout.headerHeight = 0
        
        rightCollectionView = UICollectionView(frame: .zero, collectionViewLayout: rightLayout)
        rightCollectionView.backgroundColor = .white
        rightCollectionView.delegate = self
        rightCollectionView.dataSource = self
        rightCollectionView.showsVerticalScrollIndicator = true
        rightCollectionView.showsHorizontalScrollIndicator = true
        rightCollectionView.bounces = true
        rightCollectionView.alwaysBounceHorizontal = true
        rightCollectionView.alwaysBounceVertical = true
        rightCollectionView.contentInsetAdjustmentBehavior = .never
        
        rightCollectionView.register(TimelineCell.self, forCellWithReuseIdentifier: TimelineCell.reuseIdentifier)
        
        view.addSubview(rightCollectionView)
    }
    
    private func setupScrollSync() {
        // 监听左侧滚动
        leftOffsetObservation = leftCollectionView.observe(\.contentOffset, options: [.new]) { [weak self] (scrollView, change) in
            guard let self = self, !self.isSyncingScroll else { return }
            
            self.isSyncingScroll = true
            self.rightCollectionView.contentOffset.y = scrollView.contentOffset.y
            self.isSyncingScroll = false
        }
        
        // 监听右侧滚动
        rightOffsetObservation = rightCollectionView.observe(\.contentOffset, options: [.new]) { [weak self] (scrollView, change) in
            guard let self = self, !self.isSyncingScroll else { return }
            
            self.isSyncingScroll = true
            self.leftCollectionView.contentOffset.y = scrollView.contentOffset.y
            self.isSyncingScroll = false
        }
        
        // 监听水平滚动
        rightCollectionView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                              change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset", let scrollView = object as? UICollectionView {
            if scrollView == rightCollectionView {
                // 同步时间轴头部的水平滚动
                timelineHeaderScrollView.contentOffset.x = scrollView.contentOffset.x
            }
        }
    }
    
    private func setupToolbar() {
        navigationController?.setToolbarHidden(false, animated: false)
        
        let dayButton = UIBarButtonItem(title: "日", style: .plain, target: self, action: #selector(switchToDayView))
        let weekButton = UIBarButtonItem(title: "周", style: .plain, target: self, action: #selector(switchToWeekView))
        let monthButton = UIBarButtonItem(title: "月", style: .plain, target: self, action: #selector(switchToMonthView))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let todayButton = UIBarButtonItem(title: "今天", style: .plain, target: self, action: #selector(scrollToToday))
        
        toolbarItems = [dayButton, weekButton, monthButton, flexibleSpace, todayButton]
    }
    
    // MARK: - 工具栏操作
    
    @objc private func switchToDayView() {
        timeScale.scale = .day
        refreshLayout()
    }
    
    @objc private func switchToWeekView() {
        timeScale.scale = .week
        refreshLayout()
    }
    
    @objc private func switchToMonthView() {
        timeScale.scale = .month
        refreshLayout()
    }
    
    @objc private func scrollToToday(animated: Bool = true) {
        guard rightLayout != nil, rightCollectionView != nil else { return }
        
        let xPos = rightLayout.xPositionForDate(Date())
        let targetX = max(0, xPos - 100)
        
        rightCollectionView.setContentOffset(
            CGPoint(x: targetX, y: rightCollectionView.contentOffset.y),
            animated: animated
        )
        
        // 同步头部
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.timelineHeaderScrollView.contentOffset.x = targetX
            }
        } else {
            timelineHeaderScrollView.contentOffset.x = targetX
        }
    }
    
    private func refreshLayout() {
        let currentYOffset = rightCollectionView.contentOffset.y
        let currentXOffset = rightCollectionView.contentOffset.x
        
        rightLayout.timeScale = timeScale
        rightLayout.tasks = tasks
        rightLayout.invalidateLayout()
        rightCollectionView.reloadData()
        leftCollectionView.reloadData()
        
        // 先更新头部视图的配置
        fixedTimelineHeaderView.configure(timeScale: timeScale)
        
        // 然后更新头部内容尺寸
        updateHeaderContent()
        
        // 恢复滚动位置
        rightCollectionView.contentOffset = CGPoint(x: currentXOffset, y: currentYOffset)
        leftCollectionView.contentOffset = CGPoint(x: 0, y: currentYOffset)
        
        // 同步头部滚动位置
        timelineHeaderScrollView.contentOffset.x = currentXOffset
        
        DispatchQueue.main.async { [weak self] in
            self?.updateVisibleCellIndicators()
        }
    }
    
    private func toggleExpand(at index: Int) {
        guard let task = rightLayout.taskAtIndex(index) else { return }
        
        if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[taskIndex].isExpanded.toggle()
        }
        if let allIndex = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[allIndex].isExpanded.toggle()
        }
        
        let currentOffset = rightCollectionView.contentOffset
        
        rightLayout.tasks = tasks
        rightLayout.invalidateLayout()
        rightCollectionView.reloadData()
        leftCollectionView.reloadData()
        
        rightCollectionView.contentOffset = currentOffset
        leftCollectionView.contentOffset = CGPoint(x: 0, y: currentOffset.y)
        
        DispatchQueue.main.async { [weak self] in
            self?.updateVisibleCellIndicators()
            self?.updateHeaderContent()
        }
    }
    
    // MARK: - 指示器滚动方法
    
    private func scrollToTaskStart(_ task: GanttTask) {
        let xPos = rightLayout.xPositionForDate(task.startDate)
        rightCollectionView.setContentOffset(
            CGPoint(x: max(0, xPos - 20), y: rightCollectionView.contentOffset.y),
            animated: true
        )
    }
    
    private func scrollToTaskEnd(_ task: GanttTask) {
        let xPos = rightLayout.xPositionForDate(task.endDate)
        let visibleWidth = rightCollectionView.bounds.width
        rightCollectionView.setContentOffset(
            CGPoint(x: max(0, xPos - visibleWidth + 20), y: rightCollectionView.contentOffset.y),
            animated: true
        )
    }
    
    private func updateVisibleCellIndicators() {
        for cell in rightCollectionView.visibleCells {
            if let timelineCell = cell as? TimelineCell,
               let indexPath = rightCollectionView.indexPath(for: cell),
               let task = rightLayout.taskAtIndex(indexPath.item) {
                
                let x = rightLayout.xPositionForDate(task.startDate)
                let width = rightLayout.widthForDuration(from: task.startDate, to: task.endDate)
                
                let visibleRect = CGRect(
                    x: rightCollectionView.contentOffset.x,
                    y: 0,
                    width: rightCollectionView.bounds.width,
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
    
    deinit {
        leftOffsetObservation?.invalidate()
        rightOffsetObservation?.invalidate()
        rightCollectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension GanttChartViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rightLayout.visibleTaskCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == leftCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TaskNameCell.reuseIdentifier,
                for: indexPath
            ) as! TaskNameCell
            
            if let task = rightLayout.taskAtIndex(indexPath.item) {
                let indent = getIndentForTask(task)
                cell.configure(task: task, indent: indent)
                cell.onExpandTapped = { [weak self] in
                    self?.toggleExpand(at: indexPath.item)
                }
            }
            
            cell.backgroundColor = indexPath.item % 2 == 0 ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TimelineCell.reuseIdentifier,
                for: indexPath
            ) as! TimelineCell
            
            if let task = rightLayout.taskAtIndex(indexPath.item) {
                let x = rightLayout.xPositionForDate(task.startDate)
                let width = rightLayout.widthForDuration(from: task.startDate, to: task.endDate)
                
                let visibleRect = CGRect(
                    x: rightCollectionView.contentOffset.x,
                    y: 0,
                    width: rightCollectionView.bounds.width,
                    height: rowHeight
                )
                
                cell.configure(
                    task: task,
                    x: x,
                    width: width,
                    rowHeight: rowHeight,
                    visibleRect: visibleRect
                )
                
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
    
    private func getIndentForTask(_ task: GanttTask) -> Int {
        func findIndent(_ tasks: [GanttTask], targetId: String, currentIndent: Int) -> Int? {
            for t in tasks {
                if t.id == targetId {
                    return currentIndent
                }
                if let children = t.children {
                    if let indent = findIndent(children, targetId: targetId, currentIndent: currentIndent + 1) {
                        return indent
                    }
                }
            }
            return nil
        }
        
        return findIndent(tasks, targetId: task.id, currentIndent: 0) ?? 0
    }
}

// MARK: - UIScrollViewDelegate
extension GanttChartViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialOffset = scrollView.contentOffset
        isHorizontalLocked = false
        isVerticalLocked = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == rightCollectionView else { return }
        
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
        }
        
        updateVisibleCellIndicators()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isHorizontalLocked = false
        isVerticalLocked = false
        updateVisibleCellIndicators()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isHorizontalLocked = false
            isVerticalLocked = false
            updateVisibleCellIndicators()
        }
    }
}
