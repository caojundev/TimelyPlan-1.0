//
//  MyDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation
import UIKit

// MARK: - 配置

struct TimelineConfig {
    // MARK: 布局常量
    static let leftTimeWidth: CGFloat = 36
    static let margin: CGFloat = 16
    static let centerNodeWidth: CGFloat = 40
    static let rightCircleSize: CGFloat = 20
    
    // MARK: Cell 高度
    static let pointCellHeight: CGFloat = 60
    static let shortCellHeight: CGFloat = 80
    static let longCellHeight: CGFloat = 140
    
    // MARK: 连接线配置
    static let solidLineWidth: CGFloat = 2
    static let dashedLineWidth: CGFloat = 2
    static let overlappingLineWidth: CGFloat = 40
    
    static let dashedPattern: [NSNumber] = [4, 4]
    
    /// 实线连接线最小高度
    static let solidConnectionMinHeight: CGFloat = 20.0
    /// 实线连接线最大高度
    static let solidConnectionMaxHeight: CGFloat = 60.0
    
    /// 虚线连接线高度
    static let dashedConnectionHeight: CGFloat = 120.0
    
    /// 重叠样式连接线默认高度
    static let overlappingConnectionHeight: CGFloat = 30.0
    
    /// 时间间隔阈值（分钟）：大于等于此值为虚线，小于此值为实线
    static let dashedThresholdMinutes: TimeInterval = 30 * 60
    
    // MARK: 图标配置
    static let iconSize: CGFloat = 24
    
    // MARK: 字体配置
    static let timeFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    static let timeColor = UIColor.lightGray
}

// MARK: - 数据模型

enum TimeLineNodeStyle {
    case independent
    case connectToPrevious
    case connectToNext
    case connectToBoth
}

enum TimelineItemType: Equatable {
    case point(icon: UIImage?)
    case short(icon: UIImage?)
    case long(icon: UIImage?)
    
    static func == (lhs: TimelineItemType, rhs: TimelineItemType) -> Bool {
        switch (lhs, rhs) {
        case (.point, .point), (.short, .short), (.long, .long):
            return true
        default:
            return false
        }
    }
}

enum TimelineConnectionStyle {
    case solid
    case dashed
    case overlapping
}

struct TimelineConnectionItem {
    let id = UUID()
    let style: TimelineConnectionStyle
    let topColor: UIColor
    let bottomColor: UIColor
    let height: CGFloat
    let timeInterval: TimeInterval?
}

struct TimelineItem {
    let id = UUID()
    let timeStart: String
    let timeEnd: String?
    let title: String
    let subtitle: String?
    let type: TimelineItemType
    let isCompleted: Bool
    let durationText: String?
    let nodeColor: UIColor
    let nodeStyle: TimeLineNodeStyle
    let event: MyDayEvent?
    
    let startDate: Date
    let endDate: Date
}

enum TimelineDataItem {
    case event(TimelineItem)
    case connection(TimelineConnectionItem)
}

// MARK: - 布局管理器

struct TimelineLayoutManager {
    static func cellHeight(for item: TimelineItem) -> CGFloat {
        switch item.type {
        case .long: return TimelineConfig.longCellHeight
        case .point: return TimelineConfig.pointCellHeight
        case .short: return TimelineConfig.shortCellHeight
        }
    }
}

// MARK: - 事件转换器

struct TimelineEventConverter {
    
    static func convert(events: [MyDayEvent]) -> [TimelineDataItem] {
        let nonAllDayEvents = events.filter { !$0.isAllDay }
        guard !nonAllDayEvents.isEmpty else { return [] }
        
        let nodeStyles = calculateNodeStyles(events: nonAllDayEvents)
        let timelineItems = nonAllDayEvents.enumerated().map { index, event in
            convertToTimelineItem(event: event, nodeStyle: nodeStyles[index])
        }
        
        return insertConnections(items: timelineItems)
    }
    
    private static func calculateNodeStyles(events: [MyDayEvent]) -> [TimeLineNodeStyle] {
        var styles: [TimeLineNodeStyle] = []
        
        for (index, event) in events.enumerated() {
            let currentStart = event.startDate
            let currentEnd = event.endDate
            
            var overlapsWithPrevious = false
            var overlapsWithNext = false
            
            if index > 0 {
                for prevIndex in (0..<index).reversed() {
                    let prevEvent = events[prevIndex]
                    
                    if (currentStart >= prevEvent.startDate && currentStart < prevEvent.endDate) ||
                       (prevEvent.endDate > currentStart && prevEvent.endDate <= currentEnd) {
                        overlapsWithPrevious = true
                        break
                    }
                }
            }
            
            if index < events.count - 1 {
                for nextIndex in (index + 1)..<events.count {
                    let nextEvent = events[nextIndex]
                    
                    if (currentEnd > nextEvent.startDate && currentEnd <= nextEvent.endDate) ||
                       (nextEvent.startDate >= currentStart && nextEvent.startDate < currentEnd) {
                        overlapsWithNext = true
                        break
                    }
                }
            }
            
            let style: TimeLineNodeStyle
            switch (overlapsWithPrevious, overlapsWithNext) {
            case (false, false): style = .independent
            case (true, false): style = .connectToPrevious
            case (false, true): style = .connectToNext
            case (true, true): style = .connectToBoth
            }
            
            styles.append(style)
        }
        
        return styles
    }
    
    private static func insertConnections(items: [TimelineItem]) -> [TimelineDataItem] {
        var result: [TimelineDataItem] = []
        
        for (index, item) in items.enumerated() {
            result.append(.event(item))
            
            guard index + 1 < items.count else { continue }
            
            let nextItem = items[index + 1]
            let timeInterval = nextItem.startDate.timeIntervalSince(item.endDate)
            
            let style = determineConnectionStyle(
                from: item,
                to: nextItem,
                timeInterval: timeInterval
            )
            
            let height = calculateConnectionHeight(
                style: style,
                timeInterval: timeInterval
            )
            
            let connection = TimelineConnectionItem(
                style: style,
                topColor: item.nodeColor,
                bottomColor: nextItem.nodeColor,
                height: height,
                timeInterval: timeInterval
            )
            
            result.append(.connection(connection))
        }
        
        return result
    }
    
    private static func calculateConnectionHeight(
        style: TimelineConnectionStyle,
        timeInterval: TimeInterval
    ) -> CGFloat {
        switch style {
        case .overlapping:
            return TimelineConfig.overlappingConnectionHeight
            
        case .solid:
            return calculateProportionalHeight(timeInterval: timeInterval)
            
        case .dashed:
            return TimelineConfig.dashedConnectionHeight
        }
    }
    
    private static func calculateProportionalHeight(timeInterval: TimeInterval) -> CGFloat {
        let threshold = TimelineConfig.dashedThresholdMinutes
        let minHeight = TimelineConfig.solidConnectionMinHeight
        let maxHeight = TimelineConfig.solidConnectionMinHeight
        let ratio = CGFloat(min(timeInterval, threshold) / threshold)
        return minHeight + (maxHeight - minHeight) * ratio
    }
    
    private static func determineConnectionStyle(
        from topItem: TimelineItem,
        to bottomItem: TimelineItem,
        timeInterval: TimeInterval
    ) -> TimelineConnectionStyle {
        if (topItem.nodeStyle == .connectToNext || topItem.nodeStyle == .connectToBoth) &&
           (bottomItem.nodeStyle == .connectToPrevious || bottomItem.nodeStyle == .connectToBoth) {
            return .overlapping
        }
        
        if timeInterval >= TimelineConfig.dashedThresholdMinutes {
            return .dashed
        }
        
        return .solid
    }
    
    static func convertToTimelineItem(event: MyDayEvent, nodeStyle: TimeLineNodeStyle) -> TimelineItem {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let timeStart = formatter.string(from: event.startDate)
        let timeEnd = formatter.string(from: event.endDate)
        
        let durationText = calculateDuration(from: event.startDate, to: event.endDate)
        let type = determineTimelineType(for: event)
        let icon = generateIcon(for: event)
        let subtitle = generateSubtitle(for: event)
        
        return TimelineItem(
            timeStart: timeStart,
            timeEnd: timeEnd,
            title: event.title ?? "No Title",
            subtitle: subtitle,
            type: type,
            isCompleted: event.isCompleted,
            durationText: durationText,
            nodeColor: event.color,
            nodeStyle: nodeStyle,
            event: event,
            startDate: event.startDate,
            endDate: event.endDate
        )
    }
    
    private static func calculateDuration(from startDate: Date, to endDate: Date) -> String? {
        let interval = endDate.timeIntervalSince(startDate)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours) hr, \(minutes) min"
        } else if hours > 0 {
            return "\(hours) hr"
        } else if minutes > 0 {
            return "\(minutes) min"
        }
        return nil
    }
    
    private static func determineTimelineType(for event: MyDayEvent) -> TimelineItemType {
        let interval = event.endDate.timeIntervalSince(event.startDate)
        let hours = interval / 3600
        let icon = generateIcon(for: event)
        
        switch hours {
        case ..<0.5: return .point(icon: icon)
        case 0.5..<1: return .short(icon: icon)
        default: return .long(icon: icon)
        }
    }
    
    private static func generateIcon(for event: MyDayEvent) -> UIImage? {
        switch event.source {
        case .todo:
            return UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        case .habit:
            return UIImage(systemName: "repeat.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        case .focus:
            return UIImage(systemName: "timer.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
    
    private static func generateSubtitle(for event: MyDayEvent) -> String? {
        var subtitle = ""
        
        switch event.source {
        case .todo: subtitle += "📋 待办任务"
        case .habit: subtitle += "🔄 习惯追踪"
        case .focus: subtitle += "⏱️ 专注计时"
        }
        
        subtitle += event.isCompleted ? " · ✓ 已完成" : " · ⏳ 进行中"
        
        return subtitle
    }
}

// MARK: - 自定义布局

class TimelineLayout: UICollectionViewFlowLayout {
    
    var dataSource: [TimelineDataItem] = []
    private var cellAttributes: [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView, !dataSource.isEmpty else { return }
        
        cellAttributes.removeAll()
        
        let width = collectionView.bounds.width
        var currentY: CGFloat = 0
        
        for (index, item) in dataSource.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            let height: CGFloat
            
            switch item {
            case .event(let eventItem):
                height = TimelineLayoutManager.cellHeight(for: eventItem)
            case .connection(let connectionItem):
                height = connectionItem.height
            }
            
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attrs.frame = CGRect(x: 0, y: currentY, width: width, height: height)
            cellAttributes.append(attrs)
            
            currentY += height
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        return cellAttributes.filter { rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < cellAttributes.count else { return nil }
        return cellAttributes[indexPath.item]
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let totalHeight = cellAttributes.last?.frame.maxY ?? 0
        return CGSize(width: collectionView.bounds.width, height: totalHeight)
    }
}

// MARK: - 连接线基类 Cell

class TimelineConnectionCell: UICollectionViewCell {
    
    let gradientLayer = CAGradientLayer()
    let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        layer.speed = 0
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeLayer
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.speed = 0
        shapeLayer.speed = 0
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    /// 配置连接线（子类可重写）
    func configure(with item: TimelineConnectionItem) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.colors = [item.topColor.cgColor, item.bottomColor.cgColor]
        
        CATransaction.commit()
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.frame = bounds
        
        let lineCenterX = TimelineConfig.leftTimeWidth + TimelineConfig.margin + 8 + TimelineConfig.centerNodeWidth / 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineCenterX, y: 0))
        path.addLine(to: CGPoint(x: lineCenterX, y: bounds.height))
        shapeLayer.path = path.cgPath
        
        CATransaction.commit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.colors = nil
        shapeLayer.path = nil
        
        CATransaction.commit()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        super.apply(layoutAttributes)
        CATransaction.commit()
    }
}

// MARK: - 实线连接线 Cell

class TimelineSolidConnectionCell: TimelineConnectionCell {
    
    override func configure(with item: TimelineConnectionItem) {
        super.configure(with: item)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.lineWidth = TimelineConfig.solidLineWidth
        shapeLayer.lineDashPattern = nil
        
        CATransaction.commit()
    }
}

// MARK: - 虚线连接线 Cell

class TimelineDashedConnectionCell: TimelineConnectionCell {
    
    override func configure(with item: TimelineConnectionItem) {
        super.configure(with: item)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.lineWidth = TimelineConfig.dashedLineWidth
        shapeLayer.lineDashPattern = TimelineConfig.dashedPattern
        
        CATransaction.commit()
    }
}

// MARK: - 重叠连接线 Cell

class TimelineOverlappingConnectionCell: TimelineConnectionCell {
    
    override func configure(with item: TimelineConnectionItem) {
        super.configure(with: item)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.lineWidth = TimelineConfig.overlappingLineWidth
        shapeLayer.lineDashPattern = nil
        
        CATransaction.commit()
    }
}

// MARK: - 时间线基类 Cell

class TimelineCell: UICollectionViewCell {
    
    // MARK: 基类控件
    let startTimeLabel = UILabel()
    let centerIconContainer = UIView()
    let centerIconImageView = UIImageView()
    
    // MARK: 事件内容容器（子类在此添加内容）
    let eventContentView = UIView()
    
    private var currentItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupBaseUI() {
        backgroundColor = .clear
        
        startTimeLabel.font = TimelineConfig.timeFont
        startTimeLabel.textColor = TimelineConfig.timeColor
        startTimeLabel.textAlignment = .right
        
        centerIconImageView.contentMode = .center
        centerIconContainer.addSubview(centerIconImageView)
        
        eventContentView.backgroundColor = .clear
        
        contentView.addSubview(startTimeLabel)
        contentView.addSubview(centerIconContainer)
        contentView.addSubview(eventContentView)
    }
    
    /// 配置基类公共属性
    func configure(with item: TimelineItem) {
        self.currentItem = item
        
        startTimeLabel.text = item.timeStart
        centerIconContainer.backgroundColor = item.nodeColor
        
        centerIconImageView.image = nil
        if case .point(let icon) = item.type {
            centerIconImageView.image = icon
        } else if case .short(let icon) = item.type {
            centerIconImageView.image = icon
        } else if case .long(let icon) = item.type {
            centerIconImageView.image = icon
        }
        
        applyNodeStyle(to: centerIconContainer, style: item.nodeStyle)
        
        setNeedsLayout()
    }
    
    private func applyNodeStyle(to view: UIView, style: TimeLineNodeStyle) {
        view.layer.maskedCorners = []
        
        switch style {
        case .independent:
            view.layer.cornerRadius = TimelineConfig.centerNodeWidth / 2
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                       .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .connectToPrevious:
            view.layer.cornerRadius = TimelineConfig.centerNodeWidth / 2
            view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .connectToNext:
            view.layer.cornerRadius = TimelineConfig.centerNodeWidth / 2
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .connectToBoth:
            view.layer.cornerRadius = 0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let verticalCenterY = bounds.height / 2
        let centerX = TimelineConfig.leftTimeWidth + TimelineConfig.margin + 8
        
        // 时间标签
        startTimeLabel.sizeToFit()
        startTimeLabel.frame = CGRect(
            x: 0,
            y: verticalCenterY - startTimeLabel.bounds.height / 2,
            width: TimelineConfig.leftTimeWidth,
            height: startTimeLabel.bounds.height
        )
        
        // 中心图标容器
        centerIconContainer.frame = CGRect(
            x: centerX,
            y: 0,
            width: TimelineConfig.centerNodeWidth,
            height: bounds.height
        )
        centerIconImageView.frame = CGRect(
            x: 0,
            y: (bounds.height - TimelineConfig.iconSize) / 2,
            width: TimelineConfig.centerNodeWidth,
            height: TimelineConfig.iconSize
        )
        
        // 事件内容区域
        let eventContentX = centerX + TimelineConfig.centerNodeWidth + 12
        let eventContentWidth = bounds.width - eventContentX - TimelineConfig.margin
        eventContentView.frame = CGRect(
            x: eventContentX,
            y: 0,
            width: eventContentWidth,
            height: bounds.height
        )
    }
}

// MARK: - Todo 事件 Cell

class MyDayTodoTimelineCell: TimelineCell {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let durationLabel = UILabel()
    private let rightCircleView = UIView()
    
    private var todoItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTodoUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupTodoUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        
        durationLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        durationLabel.textColor = .lightGray
        durationLabel.textAlignment = .center
        durationLabel.layer.cornerRadius = 4
        durationLabel.layer.masksToBounds = true
        durationLabel.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        
        rightCircleView.layer.borderWidth = 2
        rightCircleView.backgroundColor = .clear
        
        eventContentView.addSubview(titleLabel)
        eventContentView.addSubview(subtitleLabel)
        eventContentView.addSubview(durationLabel)
        eventContentView.addSubview(rightCircleView)
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.todoItem = item
        
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        durationLabel.text = item.durationText
        durationLabel.isHidden = item.durationText == nil
        
        rightCircleView.layer.borderColor = item.isCompleted ? item.nodeColor.cgColor : UIColor.gray.cgColor
        rightCircleView.layer.cornerRadius = TimelineConfig.rightCircleSize / 2
        rightCircleView.backgroundColor = item.isCompleted ? item.nodeColor.withAlphaComponent(0.2) : .clear
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = eventContentView.bounds
        let verticalCenterY = bounds.height / 2
        
        if !durationLabel.isHidden {
            durationLabel.sizeToFit()
            durationLabel.frame = CGRect(
                x: 0,
                y: verticalCenterY - 30,
                width: durationLabel.bounds.width + 12,
                height: durationLabel.bounds.height + 4
            )
        }
        
        let titleY = durationLabel.isHidden ? verticalCenterY - 10 : verticalCenterY - 8
        let textMaxWidth = bounds.width - TimelineConfig.rightCircleSize - 8
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(
            x: 0,
            y: titleY,
            width: min(titleSize.width, textMaxWidth),
            height: titleSize.height
        )
        
        if let subtitle = todoItem?.subtitle, !subtitle.isEmpty {
            subtitleLabel.isHidden = false
            subtitleLabel.sizeToFit()
            subtitleLabel.frame = CGRect(
                x: 0,
                y: titleLabel.frame.maxY + 4,
                width: min(textMaxWidth, subtitleLabel.bounds.width),
                height: subtitleLabel.bounds.height
            )
        } else {
            subtitleLabel.isHidden = true
        }
        
        rightCircleView.frame = CGRect(
            x: bounds.width - TimelineConfig.rightCircleSize,
            y: verticalCenterY - TimelineConfig.rightCircleSize / 2,
            width: TimelineConfig.rightCircleSize,
            height: TimelineConfig.rightCircleSize
        )
    }
}

// MARK: - Focus 事件 Cell

class MyDayFocusTimelineCell: TimelineCell {
    
    private let titleLabel = UILabel()
    private let durationLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    private var focusItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFocusUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupFocusUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        durationLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        durationLabel.textColor = .lightGray
        
        progressView.trackTintColor = UIColor(white: 0.3, alpha: 0.5)
        progressView.progressTintColor = .systemGreen
        
        eventContentView.addSubview(titleLabel)
        eventContentView.addSubview(durationLabel)
        eventContentView.addSubview(progressView)
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.focusItem = item
        
        titleLabel.text = item.title
        durationLabel.text = item.durationText
        
        // 根据完成状态设置进度
        progressView.progress = item.isCompleted ? 1.0 : 0.5
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = eventContentView.bounds
        let verticalCenterY = bounds.height / 2
        
        let textMaxWidth = bounds.width
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(
            x: 0,
            y: verticalCenterY - 25,
            width: min(titleSize.width, textMaxWidth),
            height: titleSize.height
        )
        
        durationLabel.sizeToFit()
        durationLabel.frame = CGRect(
            x: 0,
            y: titleLabel.frame.maxY + 4,
            width: durationLabel.bounds.width,
            height: durationLabel.bounds.height
        )
        
        progressView.frame = CGRect(
            x: 0,
            y: durationLabel.frame.maxY + 6,
            width: textMaxWidth,
            height: 4
        )
    }
}

// MARK: - Habit 事件 Cell

class MyDayHabitTimelineCell: TimelineCell {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    private var habitItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHabitUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupHabitUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        
        checkmarkImageView.contentMode = .center
        checkmarkImageView.tintColor = .systemGreen
        
        eventContentView.addSubview(titleLabel)
        eventContentView.addSubview(subtitleLabel)
        eventContentView.addSubview(checkmarkImageView)
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.habitItem = item
        
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        if item.isCompleted {
            checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            checkmarkImageView.image = UIImage(systemName: "circle")
        }
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = eventContentView.bounds
        let verticalCenterY = bounds.height / 2
        
        let checkmarkSize: CGFloat = 24
        checkmarkImageView.frame = CGRect(
            x: bounds.width - checkmarkSize,
            y: verticalCenterY - checkmarkSize / 2,
            width: checkmarkSize,
            height: checkmarkSize
        )
        
        let textMaxWidth = bounds.width - checkmarkSize - 8
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(
            x: 0,
            y: verticalCenterY - 12,
            width: min(titleSize.width, textMaxWidth),
            height: titleSize.height
        )
        
        subtitleLabel.sizeToFit()
        subtitleLabel.frame = CGRect(
            x: 0,
            y: titleLabel.frame.maxY + 2,
            width: min(textMaxWidth, subtitleLabel.bounds.width),
            height: subtitleLabel.bounds.height
        )
    }
}

// MARK: - BaseTimelineView

protocol TimelineViewDelegate: AnyObject {
    func timelineViewEvents(_ timelineView: BaseTimelineView) -> [MyDayEvent]
    func timelineView(_ timelineView: BaseTimelineView, didSelectEvent event: MyDayEvent)

    func timelineViewWillBeginDragging(_ timelineView: BaseTimelineView)
}

extension TimelineViewDelegate {
    func timelineView(_ timelineView: BaseTimelineView, didSelectEvent event: MyDayEvent) {}
    
    func timelineViewWillBeginDragging(_ timelineView: BaseTimelineView) {}
}

// MARK: - BaseTimelineView

class BaseTimelineView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    var dataSource: [TimelineDataItem] = []
    
    weak var delegate: TimelineViewDelegate?
    
    /// 已注册的 Cell 类名集合
    private var registeredCellClassNames: Set<String> = []
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    // MARK: - Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    private func setupCollectionView() {
        let layout = TimelineLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
    }
    
    // MARK: - Cell 注册
    
    /// 根据类名注册 Cell（自动去重）
    private func registerCellIfNeeded(_ cellClass: AnyClass) {
        let className = String(describing: cellClass)
        guard !registeredCellClassNames.contains(className) else { return }
        
        collectionView.register(cellClass, forCellWithReuseIdentifier: className)
        registeredCellClassNames.insert(className)
    }
    
    /// 从类名获取复用标识符
    private func reuseIdentifier(for cellClass: AnyClass) -> String {
        return String(describing: cellClass)
    }
    
    // MARK: - 子类重写方法
    /// 根据 TimelineConnectionItem 返回对应的连接线 Cell 类（子类可重写）
    func connectionCellClass(for item: TimelineConnectionItem) -> AnyClass {
        switch item.style {
        case .solid:
            return TimelineSolidConnectionCell.self
        case .dashed:
            return TimelineDashedConnectionCell.self
        case .overlapping:
            return TimelineOverlappingConnectionCell.self
        }
    }
        
    /// 根据 TimelineItem 返回对应的 Cell 类（子类必须重写）
    func eventCellClass(for item: TimelineItem) -> AnyClass {
        fatalError("Subclasses must override cellClass(for:)")
    }
    
    /// 配置事件 Cell（子类可重写以进行额外配置）
    func configureEventCell(_ cell: TimelineCell, with item: TimelineItem) {
        cell.configure(with: item)
    }
    
    /// 配置连接线 Cell（子类可重写以进行额外配置）
     func configureConnectionCell(_ cell: TimelineConnectionCell, with item: TimelineConnectionItem) {
         cell.configure(with: item)
     }
     
    
    // MARK: - Public Methods
    
    func reloadData() {
        guard let delegate = delegate else { return }
        
        let events = delegate.timelineViewEvents(self)
        dataSource = TimelineEventConverter.convert(events: events)
        
        if let layout = collectionView.collectionViewLayout as? TimelineLayout {
            layout.dataSource = dataSource
        }
        
        collectionView.reloadData()
    }
    
    func event(at indexPath: IndexPath) -> MyDayEvent? {
        guard indexPath.item < dataSource.count else { return nil }
        if case .event(let item) = dataSource[indexPath.item] {
            return item.event
        }
        return nil
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataSource[indexPath.item]
        
        switch item {
        case .event(let eventItem):
            let cellClass: AnyClass = self.eventCellClass(for: eventItem)
            let identifier = reuseIdentifier(for: cellClass)
            
            // 动态注册（自动去重）
            registerCellIfNeeded(cellClass)
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? TimelineCell else {
                fatalError("Cell with identifier \(identifier) is not a TimelineCell subclass")
            }
            
            configureEventCell(cell, with: eventItem)
            return cell
            
        case .connection(let connectionItem):
            let cellClass: AnyClass = self.connectionCellClass(for: connectionItem)
            let identifier = reuseIdentifier(for: cellClass)

            registerCellIfNeeded(cellClass)

            guard let cell =        collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? TimelineConnectionCell else {
                fatalError("Cell with identifier \(identifier) is not a TimelineConnectionCell subclass")
            }

            configureConnectionCell(cell, with: connectionItem)
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let event = event(at: indexPath) else { return }
        delegate?.timelineView(self, didSelectEvent: event)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.timelineViewWillBeginDragging(self)
    }
}

// MARK: - MyDayTimelineView

class MyDayTimelineView: BaseTimelineView {
    
    override func eventCellClass(for item: TimelineItem) -> AnyClass {
        guard let event = item.event else {
            return MyDayTodoTimelineCell.self
        }
        
        switch event.source {
        case .todo:
            return MyDayTodoTimelineCell.self
        case .focus:
            return MyDayFocusTimelineCell.self
        case .habit:
            return MyDayHabitTimelineCell.self
        }
    }
    
    override func configureEventCell(_ cell: TimelineCell, with item: TimelineItem) {
        // 根据不同类型进行特定配置
        if let todoCell = cell as? MyDayTodoTimelineCell {
            todoCell.configure(with: item)
        } else if let focusCell = cell as? MyDayFocusTimelineCell {
            focusCell.configure(with: item)
        } else if let habitCell = cell as? MyDayHabitTimelineCell {
            habitCell.configure(with: item)
        } else {
            cell.configure(with: item)
        }
    }
}
