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
    static let leftTimeWidth: CGFloat = 60
    static let margin: CGFloat = 16
    static let centerNodeWidth: CGFloat = 40
    static let rightCircleSize: CGFloat = 20
    
    // MARK: Cell 高度
    static let pointCellHeight: CGFloat = 80
    static let shortCellHeight: CGFloat = 80
    static let longCellHeight: CGFloat = 140
    
    // MARK: 连接线配置
    static let solidLineWidth: CGFloat = 2
    static let dashedLineWidth: CGFloat = 2
    static let overlappingLineWidth: CGFloat = 40  // 与 centerNodeWidth 相同
    
    static let dashedPattern: [NSNumber] = [4, 4]
    
    /// 连接线最小高度
    static let connectionMinHeight: CGFloat = 30.0
    /// 连接线最大高度
    static let connectionMaxHeight: CGFloat = 120.0
    /// 重叠样式连接线默认高度
    static let overlappingConnectionHeight: CGFloat = 30.0
    
    /// 时间间隔阈值（分钟）：大于等于此值为虚线，小于此值为实线
    static let dashedThresholdMinutes: TimeInterval = 30 * 60  // 30分钟
    
    // MARK: 图标配置
    static let iconSize: CGFloat = 24
    
    // MARK: 字体配置
    static let timeFont = UIFont.systemFont(ofSize: 13, weight: .medium)
    static let timeColor = UIColor.lightGray
    
    static let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    static let titleColor = UIColor.white
    
    static let subtitleFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    static let subtitleColor = UIColor.gray
    
    static let durationFont = UIFont.systemFont(ofSize: 11, weight: .regular)
    static let durationColor = UIColor.lightGray
    static let durationBackgroundColor = UIColor(white: 0.3, alpha: 0.5)
    static let durationCornerRadius: CGFloat = 4
}

// MARK: - 数据模型

/// 节点样式枚举
enum TimeLineNodeStyle {
    /// 独立的，与其它节点无相交
    case independent
    /// 仅与上一个节点相交（连接上方）
    case connectToPrevious
    /// 仅与下一个节点相交（连接下方）
    case connectToNext
    /// 与上下节点都相交
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

/// 连接线样式
enum TimelineConnectionStyle {
    case solid          // 实线（使用渐变色）
    case dashed         // 虚线（使用渐变色）
    case overlapping    // 重叠样式（线条宽度与centerIconContainer相同）
}

/// 连接线数据模型
struct TimelineConnectionItem {
    let id = UUID()
    let style: TimelineConnectionStyle
    let topColor: UIColor
    let bottomColor: UIColor
    let height: CGFloat
    /// 上下事件之间的时间间隔（秒）
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
    
    /// 原始时间（用于计算时间间隔）
    let startDate: Date
    let endDate: Date
}

// MARK: - 统一的 Timeline 数据项协议

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

// MARK: - 代理协议

protocol MyDayTimelineViewDelegate: AnyObject {
    func timelineViewEvents(_ timelineView: MyDayTimelineView) -> [MyDayEvent]
    func timelineView(_ timelineView: MyDayTimelineView, didSelectEvent event: MyDayEvent)
}

extension MyDayTimelineViewDelegate {
    func timelineView(_ timelineView: MyDayTimelineView, didSelectEvent event: MyDayEvent) {}
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
            
            // 计算两个事件之间的时间间隔
            let timeInterval = nextItem.startDate.timeIntervalSince(item.endDate)
            
            // 根据时间间隔确定连接线样式
            let style = determineConnectionStyle(
                from: item,
                to: nextItem,
                timeInterval: timeInterval
            )
            
            // 根据样式和时间间隔计算连接线高度
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
    
    /// 根据时间间隔计算连接线高度
    private static func calculateConnectionHeight(
        style: TimelineConnectionStyle,
        timeInterval: TimeInterval
    ) -> CGFloat {
        switch style {
        case .overlapping:
            return TimelineConfig.overlappingConnectionHeight
            
        case .solid:
            // 实线（间隔小于30分钟）：根据时间比例计算高度
            return calculateProportionalHeight(timeInterval: timeInterval)
            
        case .dashed:
            // 虚线（间隔大于等于30分钟）：使用最大高度
            return TimelineConfig.connectionMaxHeight
        }
    }
    
    /// 根据时间间隔按比例计算高度（30分钟内）
    private static func calculateProportionalHeight(timeInterval: TimeInterval) -> CGFloat {
        let minHeight = TimelineConfig.connectionMinHeight
        let maxHeight = TimelineConfig.connectionMaxHeight
        let threshold = TimelineConfig.dashedThresholdMinutes
        
        // 计算比例（0 到 1，其中 1 对应 30 分钟）
        let ratio = CGFloat(min(timeInterval, threshold) / threshold)
        
        return minHeight + (maxHeight - minHeight) * ratio
    }
    
    /// 根据事件特征和时间间隔确定连接线样式
    private static func determineConnectionStyle(
        from topItem: TimelineItem,
        to bottomItem: TimelineItem,
        timeInterval: TimeInterval
    ) -> TimelineConnectionStyle {
        // 如果两个节点都连接到彼此（重叠），使用overlapping样式
        if (topItem.nodeStyle == .connectToNext || topItem.nodeStyle == .connectToBoth) &&
           (bottomItem.nodeStyle == .connectToPrevious || bottomItem.nodeStyle == .connectToBoth) {
            return .overlapping
        }
        
        // 根据时间间隔判断：大于等于30分钟为虚线，小于30分钟为实线
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

// MARK: - 连接线 Cell

class TimelineConnectionCell: UICollectionViewCell {
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
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
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with item: TimelineConnectionItem, lineWidth: CGFloat = 2, dashPattern: [NSNumber]? = nil) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.colors = [item.topColor.cgColor, item.bottomColor.cgColor]
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        
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

// MARK: - 事件 Cell

class TimelineCell: UICollectionViewCell {
    
    private let startTimeLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let durationLabel = UILabel()
    private let rightCircleView = UIView()
    private let centerIconContainer = UIView()
    private let centerIconImageView = UIImageView()
    
    private var currentItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        
        startTimeLabel.font = TimelineConfig.timeFont
        startTimeLabel.textColor = TimelineConfig.timeColor
        startTimeLabel.textAlignment = .right
        
        titleLabel.font = TimelineConfig.titleFont
        titleLabel.textColor = TimelineConfig.titleColor
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = TimelineConfig.subtitleFont
        subtitleLabel.textColor = TimelineConfig.subtitleColor
        subtitleLabel.numberOfLines = 0
        
        durationLabel.font = TimelineConfig.durationFont
        durationLabel.textColor = TimelineConfig.durationColor
        durationLabel.textAlignment = .center
        durationLabel.layer.cornerRadius = TimelineConfig.durationCornerRadius
        durationLabel.layer.masksToBounds = true
        durationLabel.backgroundColor = TimelineConfig.durationBackgroundColor
        
        centerIconImageView.contentMode = .center
        centerIconContainer.addSubview(centerIconImageView)
        
        rightCircleView.layer.borderWidth = 2
        rightCircleView.backgroundColor = .clear
        
        [startTimeLabel, centerIconContainer, titleLabel, subtitleLabel, durationLabel, rightCircleView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func configure(with item: TimelineItem) {
        self.currentItem = item
        
        startTimeLabel.text = item.timeStart
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        durationLabel.text = item.durationText
        durationLabel.isHidden = item.durationText == nil
        
        centerIconImageView.image = nil
        
        if case .point(let icon) = item.type {
            centerIconImageView.image = icon
        } else if case .short(let icon) = item.type {
            centerIconImageView.image = icon
        } else if case .long(let icon) = item.type {
            centerIconImageView.image = icon
        }
        
        centerIconContainer.backgroundColor = item.nodeColor
        applyNodeStyle(to: centerIconContainer, style: item.nodeStyle)
        
        rightCircleView.layer.borderColor = item.isCompleted ? item.nodeColor.cgColor : UIColor.gray.cgColor
        rightCircleView.layer.cornerRadius = TimelineConfig.rightCircleSize / 2
        rightCircleView.backgroundColor = item.isCompleted ? item.nodeColor.withAlphaComponent(0.2) : .clear
        
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
        
        startTimeLabel.sizeToFit()
        startTimeLabel.frame = CGRect(
            x: 0,
            y: verticalCenterY - startTimeLabel.bounds.height / 2,
            width: TimelineConfig.leftTimeWidth,
            height: startTimeLabel.bounds.height
        )
        
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
        
        let textStartX = centerX + TimelineConfig.centerNodeWidth + 12
        let textMaxWidth = bounds.width - textStartX - TimelineConfig.margin - TimelineConfig.rightCircleSize - TimelineConfig.margin
        
        if !durationLabel.isHidden {
            durationLabel.sizeToFit()
            durationLabel.frame = CGRect(
                x: textStartX,
                y: verticalCenterY - 30,
                width: durationLabel.bounds.width + 12,
                height: durationLabel.bounds.height + 4
            )
        }
        
        let titleY = durationLabel.isHidden ? verticalCenterY - 10 : verticalCenterY - 8
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(
            x: textStartX,
            y: titleY,
            width: min(titleSize.width, textMaxWidth),
            height: titleSize.height
        )
        
        if let subtitle = currentItem?.subtitle, !subtitle.isEmpty {
            subtitleLabel.isHidden = false
            subtitleLabel.sizeToFit()
            subtitleLabel.frame = CGRect(
                x: textStartX,
                y: titleLabel.frame.maxY + 4,
                width: min(textMaxWidth, subtitleLabel.bounds.width),
                height: subtitleLabel.bounds.height
            )
        } else {
            subtitleLabel.isHidden = true
        }
        
        rightCircleView.frame = CGRect(
            x: bounds.width - TimelineConfig.rightCircleSize - TimelineConfig.margin,
            y: verticalCenterY - TimelineConfig.rightCircleSize / 2,
            width: TimelineConfig.rightCircleSize,
            height: TimelineConfig.rightCircleSize
        )
    }
}

// MARK: - 主视图

class MyDayTimelineView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var collectionView: UICollectionView!
    private var dataSource: [TimelineDataItem] = []
    
    weak var delegate: MyDayTimelineViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
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
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: "TimelineCell")
        collectionView.register(TimelineConnectionCell.self, forCellWithReuseIdentifier: "TimelineConnectionCell")
        addSubview(collectionView)
    }
    
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCell", for: indexPath) as! TimelineCell
            cell.configure(with: eventItem)
            return cell
            
        case .connection(let connectionItem):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineConnectionCell", for: indexPath) as! TimelineConnectionCell
            
            switch connectionItem.style {
            case .solid:
                cell.configure(
                    with: connectionItem,
                    lineWidth: TimelineConfig.solidLineWidth,
                    dashPattern: nil
                )
            case .dashed:
                cell.configure(
                    with: connectionItem,
                    lineWidth: TimelineConfig.dashedLineWidth,
                    dashPattern: TimelineConfig.dashedPattern
                )
            case .overlapping:
                cell.configure(
                    with: connectionItem,
                    lineWidth: TimelineConfig.overlappingLineWidth,
                    dashPattern: nil
                )
            }
            
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let event = event(at: indexPath) else { return }
        delegate?.timelineView(self, didSelectEvent: event)
    }
}

/*
// MARK: - 数据模型

/// 节点样式枚举
enum TimeLineNodeStyle {
    /// 独立的，与其它节点无相交
    case independent
    /// 仅与上一个节点相交（连接上方）
    case connectToPrevious
    /// 仅与下一个节点相交（连接下方）
    case connectToNext
    /// 与上下节点都相交
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

/// 连接线样式
enum TimelineConnectionStyle {
    case solid          // 实线（使用渐变色）
    case dashed         // 虚线（使用渐变色）
    case overlapping    // 重叠样式（线条宽度与centerIconContainer相同）
}

/// 连接线数据模型
struct TimelineConnectionItem {
    let id = UUID()
    let style: TimelineConnectionStyle
    let topColor: UIColor
    let bottomColor: UIColor
    let height: CGFloat
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
}

// MARK: - 统一的 Timeline 数据项协议

enum TimelineDataItem {
    case event(TimelineItem)
    case connection(TimelineConnectionItem)
}

// MARK: - 布局管理器

struct TimelineLayoutManager {
    static func cellHeight(for item: TimelineItem) -> CGFloat {
        switch item.type {
        case .long: return 140
        case .point, .short: return 80
        }
    }
}

// MARK: - 代理协议

protocol MyDayTimelineViewDelegate: AnyObject {
    func timelineViewEvents(_ timelineView: MyDayTimelineView) -> [MyDayEvent]
    func timelineView(_ timelineView: MyDayTimelineView, didSelectEvent event: MyDayEvent)
}

extension MyDayTimelineViewDelegate {
    func timelineView(_ timelineView: MyDayTimelineView, didSelectEvent event: MyDayEvent) {}
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
            
            // 检查与之前事件是否有时间重叠
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
            
            // 检查与之后事件是否有时间重叠
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
            let height = calculateConnectionHeight(from: item, to: nextItem)
            let style = determineConnectionStyle(from: item, to: nextItem)
            
            let connection = TimelineConnectionItem(
                style: style,
                topColor: item.nodeColor,
                bottomColor: nextItem.nodeColor,
                height: height
            )
            
            result.append(.connection(connection))
        }
        
        return result
    }
    
    private static func calculateConnectionHeight(from topItem: TimelineItem, to bottomItem: TimelineItem) -> CGFloat {
        let topHalfHeight = TimelineLayoutManager.cellHeight(for: topItem) / 2
        let bottomHalfHeight = TimelineLayoutManager.cellHeight(for: bottomItem) / 2
        return topHalfHeight + bottomHalfHeight
    }
    
    private static func determineConnectionStyle(from topItem: TimelineItem, to bottomItem: TimelineItem) -> TimelineConnectionStyle {
        if (topItem.nodeStyle == .connectToNext || topItem.nodeStyle == .connectToBoth) &&
           (bottomItem.nodeStyle == .connectToPrevious || bottomItem.nodeStyle == .connectToBoth) {
            return .overlapping
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
            event: event
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

// MARK: - 连接线 Cell

class TimelineConnectionCell: UICollectionViewCell {
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    private let leftTimeWidth: CGFloat = 60
    private let margin: CGFloat = 16
    private let centerNodeWidth: CGFloat = 40
    
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
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with item: TimelineConnectionItem, lineWidth: CGFloat = 2, dashPattern: [NSNumber]? = nil) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.colors = [item.topColor.cgColor, item.bottomColor.cgColor]
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        CATransaction.commit()
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.frame = bounds
        
        let lineCenterX = leftTimeWidth + margin + 8 + centerNodeWidth / 2
        
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

// MARK: - 事件 Cell

class TimelineCell: UICollectionViewCell {
    
    private let leftTimeWidth: CGFloat = 60
    private let margin: CGFloat = 16
    private let centerNodeWidth: CGFloat = 40
    private let rightCircleSize: CGFloat = 20
    
    private let startTimeLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let durationLabel = UILabel()
    private let rightCircleView = UIView()
    private let centerIconContainer = UIView()
    private let centerIconImageView = UIImageView()
    
    private var currentItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        
        startTimeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        startTimeLabel.textColor = .lightGray
        startTimeLabel.textAlignment = .right
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        
        durationLabel.font = .systemFont(ofSize: 11, weight: .regular)
        durationLabel.textColor = .lightGray
        durationLabel.textAlignment = .center
        durationLabel.layer.cornerRadius = 4
        durationLabel.layer.masksToBounds = true
        durationLabel.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        
        centerIconImageView.contentMode = .center
        centerIconContainer.addSubview(centerIconImageView)
        
        rightCircleView.layer.borderWidth = 2
        rightCircleView.backgroundColor = .clear
        
        [startTimeLabel, centerIconContainer, titleLabel, subtitleLabel, durationLabel, rightCircleView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func configure(with item: TimelineItem) {
        self.currentItem = item
        
        startTimeLabel.text = item.timeStart
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        durationLabel.text = item.durationText
        durationLabel.isHidden = item.durationText == nil
        
        centerIconImageView.image = nil
        
        if case .point(let icon) = item.type {
            centerIconImageView.image = icon
        } else if case .short(let icon) = item.type {
            centerIconImageView.image = icon
        } else if case .long(let icon) = item.type {
            centerIconImageView.image = icon
        }
        
        centerIconContainer.backgroundColor = item.nodeColor
        applyNodeStyle(to: centerIconContainer, style: item.nodeStyle)
        
        rightCircleView.layer.borderColor = item.isCompleted ? item.nodeColor.cgColor : UIColor.gray.cgColor
        rightCircleView.layer.cornerRadius = rightCircleSize / 2
        rightCircleView.backgroundColor = item.isCompleted ? item.nodeColor.withAlphaComponent(0.2) : .clear
        
        setNeedsLayout()
    }
    
    private func applyNodeStyle(to view: UIView, style: TimeLineNodeStyle) {
        view.layer.maskedCorners = []
        
        switch style {
        case .independent:
            view.layer.cornerRadius = centerNodeWidth / 2
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                       .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
        case .connectToPrevious:
            view.layer.cornerRadius = centerNodeWidth / 2
            view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
        case .connectToNext:
            view.layer.cornerRadius = centerNodeWidth / 2
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
        case .connectToBoth:
            view.layer.cornerRadius = 0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let verticalCenterY = bounds.height / 2
        let centerX = leftTimeWidth + margin + 8
        
        startTimeLabel.sizeToFit()
        startTimeLabel.frame = CGRect(x: 0, y: verticalCenterY - startTimeLabel.bounds.height / 2,
                                      width: leftTimeWidth, height: startTimeLabel.bounds.height)
        
        centerIconContainer.frame = CGRect(x: centerX, y: 0, width: centerNodeWidth, height: bounds.height)
        centerIconImageView.frame = CGRect(x: 0, y: (bounds.height - 24) / 2,
                                          width: centerNodeWidth, height: 24)
        
        let textStartX = centerX + centerNodeWidth + 12
        let textMaxWidth = bounds.width - textStartX - margin - rightCircleSize - margin
        
        if !durationLabel.isHidden {
            durationLabel.sizeToFit()
            durationLabel.frame = CGRect(x: textStartX, y: verticalCenterY - 30,
                                        width: durationLabel.bounds.width + 12,
                                        height: durationLabel.bounds.height + 4)
        }
        
        let titleY = durationLabel.isHidden ? verticalCenterY - 10 : verticalCenterY - 8
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(x: textStartX, y: titleY,
                                 width: min(titleSize.width, textMaxWidth),
                                 height: titleSize.height)
        
        if let subtitle = currentItem?.subtitle, !subtitle.isEmpty {
            subtitleLabel.isHidden = false
            subtitleLabel.sizeToFit()
            subtitleLabel.frame = CGRect(x: textStartX, y: titleLabel.frame.maxY + 4,
                                        width: min(textMaxWidth, subtitleLabel.bounds.width),
                                        height: subtitleLabel.bounds.height)
        } else {
            subtitleLabel.isHidden = true
        }
        
        rightCircleView.frame = CGRect(x: bounds.width - rightCircleSize - margin,
                                      y: verticalCenterY - rightCircleSize / 2,
                                      width: rightCircleSize, height: rightCircleSize)
    }
}

// MARK: - 主视图

class MyDayTimelineView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var collectionView: UICollectionView!
    private var dataSource: [TimelineDataItem] = []
    
    weak var delegate: MyDayTimelineViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
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
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: "TimelineCell")
        collectionView.register(TimelineConnectionCell.self, forCellWithReuseIdentifier: "TimelineConnectionCell")
        addSubview(collectionView)
    }
    
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCell", for: indexPath) as! TimelineCell
            cell.configure(with: eventItem)
            return cell
            
        case .connection(let connectionItem):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineConnectionCell", for: indexPath) as! TimelineConnectionCell
            
            switch connectionItem.style {
            case .solid:
                cell.configure(with: connectionItem, lineWidth: 2, dashPattern: nil)
            case .dashed:
                cell.configure(with: connectionItem, lineWidth: 2, dashPattern: [4, 4])
            case .overlapping:
                cell.configure(with: connectionItem, lineWidth: 40, dashPattern: nil)
            }
            
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let event = event(at: indexPath) else { return }
        delegate?.timelineView(self, didSelectEvent: event)
    }
}
*/
