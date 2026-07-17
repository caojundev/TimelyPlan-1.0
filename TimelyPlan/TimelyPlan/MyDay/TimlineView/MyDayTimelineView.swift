//
//  MyDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation
import UIKit

// MARK: - 数据模型

enum TimelineItemType: Equatable {
    case point(icon: UIImage?)
    case short(icon: UIImage?)
    case long(icon: UIImage?)
    case gap
    
    static func == (lhs: TimelineItemType, rhs: TimelineItemType) -> Bool {
        switch (lhs, rhs) {
        case (.point, .point), (.short, .short), (.long, .long), (.gap, .gap):
            return true
        default:
            return false
        }
    }
}

/// 连接线样式
enum TimelineConnectionStyle {
    case solid          // 实线
    case dashed         // 虚线
    case dotted         // 点线
    case gradient       // 渐变线（从上节点颜色过渡到下节点颜色）
}

/// 连接线数据模型
struct TimelineConnectionItem {
    let id = UUID()
    let style: TimelineConnectionStyle
    let topColor: UIColor
    let bottomColor: UIColor
    let height: CGFloat        // 连接线高度 = 相邻节点中心 Y 的差值
    let isAfterGap: Bool       // 是否紧跟 Gap 之后（可能影响样式）
    
    /// 连接线 cell 的固定高度
    static let cellHeight: CGFloat = 20 // 连接线 cell 的最小高度
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
    let event: MyDayEvent?
}

// MARK: - 统一的 Timeline 数据项协议

/// 用于 CollectionView 数据源的统一类型
enum TimelineDataItem {
    case event(TimelineItem)
    case connection(TimelineConnectionItem)
}

// MARK: - 布局管理器

struct TimelineLayoutManager {
    static let blueColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0)
    static let yellowColor = UIColor.systemYellow
    static let greenColor = UIColor.systemGreen
    
    static func cellHeight(for item: TimelineItem) -> CGFloat {
        switch item.type {
        case .long: return 140
        case .point, .short: return 80
        case .gap: return 40
        }
    }
    
    /// 连接线 cell 的高度（实际绘制高度由数据决定，这里返回固定值用于布局）
    static let connectionCellHeight: CGFloat = 2
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
    
    /// 将 MyDayEvent 数组转换为包含事件和连接线的统一数据源
    static func convert(events: [MyDayEvent]) -> [TimelineDataItem] {
        let timelineItems = events.map { convertToTimelineItem(event: $0) }
        return insertConnections(items: timelineItems)
    }
    
    /// 在事件项之间插入连接线
    private static func insertConnections(items: [TimelineItem]) -> [TimelineDataItem] {
        var result: [TimelineDataItem] = []
        let nonGapIndices = items.enumerated().compactMap { index, item -> Int? in
            item.type != .gap ? index : nil
        }
        
        for (index, item) in items.enumerated() {
            // 添加事件项
            result.append(.event(item))
            
            // 判断是否需要在此事件后插入连接线
            guard let currentNonGapIndex = nonGapIndices.firstIndex(of: index) else { continue }
            let nextNonGapIndex = currentNonGapIndex + 1
            guard nextNonGapIndex < nonGapIndices.count else { continue }
            
            let nextIndex = nonGapIndices[nextNonGapIndex]
            let nextItem = items[nextIndex]
            
            // 检查中间是否有 Gap
            let hasGapBetween = (nextIndex - index) > 1
            
            // 计算连接线高度（两个节点中心 Y 的差值）
            let height = calculateConnectionHeight(
                from: item,
                to: nextItem,
                intermediateItems: Array(items[(index + 1)..<nextIndex])
            )
            
            // 确定连接线样式
            let style = determineConnectionStyle(
                from: item,
                to: nextItem,
                hasGapBetween: hasGapBetween
            )
            
            let connection = TimelineConnectionItem(
                style: style,
                topColor: item.nodeColor,
                bottomColor: nextItem.nodeColor,
                height: height,
                isAfterGap: hasGapBetween
            )
            
            result.append(.connection(connection))
        }
        
        return result
    }
    
    /// 计算两个节点中心之间的高度差
    private static func calculateConnectionHeight(
        from topItem: TimelineItem,
        to bottomItem: TimelineItem,
        intermediateItems: [TimelineItem]
    ) -> CGFloat {
        // 上方节点的下半部分：从节点中心到 cell 底部
        let topHalfHeight = TimelineLayoutManager.cellHeight(for: topItem) / 2
        
        // 下方节点的上半部分：从 cell 顶部到节点中心
        let bottomHalfHeight = TimelineLayoutManager.cellHeight(for: bottomItem) / 2
        
        // 中间项的总高度
        let intermediateHeight = intermediateItems.reduce(0) { $0 + TimelineLayoutManager.cellHeight(for: $1) }
        
        return topHalfHeight + intermediateHeight + bottomHalfHeight
    }
    
    /// 根据事件特征确定连接线样式
    private static func determineConnectionStyle(
        from topItem: TimelineItem,
        to bottomItem: TimelineItem,
        hasGapBetween: Bool
    ) -> TimelineConnectionStyle {
        // 如果中间有 Gap，使用虚线
        if hasGapBetween {
            return .dashed
        }
        
        // 如果两个事件颜色不同，使用渐变
        if topItem.nodeColor != bottomItem.nodeColor {
            return .gradient
        }
        
        return .solid
    }
    
    /// 转换单个事件
    static func convertToTimelineItem(event: MyDayEvent) -> TimelineItem {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let timeStart = formatter.string(from: event.startDate)
        let timeEnd: String? = event.isAllDay ? nil : formatter.string(from: event.endDate)
        
        let durationText = calculateDuration(from: event.startDate, to: event.endDate, isAllDay: event.isAllDay)
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
            event: event
        )
    }
    
    private static func calculateDuration(from startDate: Date, to endDate: Date, isAllDay: Bool) -> String? {
        if isAllDay { return "All Day" }
        
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
        if event.isAllDay { return .gap }
        
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
        
        if event.isCompleted {
            subtitle += " · ✓ 已完成"
        } else {
            subtitle += " · ⏳ 进行中"
        }
        
        return subtitle
    }
}

// MARK: - 自定义布局（简化版，移除装饰视图管理）

class TimelineLayout: UICollectionViewFlowLayout {
    
    var dataSource: [TimelineDataItem] = []
    
    private var cellAttributes: [UICollectionViewLayoutAttributes] = []
    
    private let leftTimeWidth: CGFloat = 60
    private let padding: CGFloat = 16
    private let centerNodeWidth: CGFloat = 40
    
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
            
            let frame = CGRect(x: 0, y: currentY, width: width, height: height)
            
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attrs.frame = frame
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

// MARK: - 连接线 Cel
class TimelineConnectionCell: UICollectionViewCell {
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    // 与 TimelineCell 保持一致的布局常量
    private let leftTimeWidth: CGFloat = 60
    private let margin: CGFloat = 16
    private let centerNodeWidth: CGFloat = 40
    
    private var currentItem: TimelineConnectionItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeLayer
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with item: TimelineConnectionItem) {
        self.currentItem = item
        
        switch item.style {
        case .solid:
            gradientLayer.colors = [item.topColor.cgColor, item.topColor.cgColor]
            shapeLayer.lineDashPattern = nil
            
        case .dashed:
            gradientLayer.colors = [item.topColor.cgColor, item.topColor.cgColor]
            shapeLayer.lineDashPattern = [4, 4]
            
        case .dotted:
            gradientLayer.colors = [item.topColor.cgColor, item.topColor.cgColor]
            shapeLayer.lineDashPattern = [1, 3]
            
        case .gradient:
            gradientLayer.colors = [item.topColor.cgColor, item.bottomColor.cgColor]
            shapeLayer.lineDashPattern = nil
        }
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
        // 与 TimelineCell 中 centerIconContainer 的中心 X 对齐
        // centerIconContainer.minX = leftTimeWidth + padding + 8
        // centerIconContainer.centerX = leftTimeWidth + padding + 8 + centerNodeWidth / 2
        let lineCenterX = leftTimeWidth + margin + 8 + centerNodeWidth / 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineCenterX, y: 0))
        path.addLine(to: CGPoint(x: lineCenterX, y: bounds.height))
        shapeLayer.path = path.cgPath
    }
}

// MARK: - 事件 Cell（保持不变）

class TimelineCell: UICollectionViewCell {
    // 布局常量
    private let leftTimeWidth: CGFloat = 60
    private let margin: CGFloat = 16
    private let centerNodeWidth: CGFloat = 40
    private let rightCircleSize: CGFloat = 20
    
    private let startTimeLabel = UILabel()
    private let endTimeLabel = UILabel()
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
        
        endTimeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        endTimeLabel.textColor = .gray
        endTimeLabel.textAlignment = .right
        
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
        
        [startTimeLabel, endTimeLabel, centerIconContainer, titleLabel, subtitleLabel, durationLabel, rightCircleView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func configure(with item: TimelineItem) {
        self.currentItem = item
        
        startTimeLabel.text = item.timeStart
        endTimeLabel.text = item.timeEnd
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        durationLabel.text = item.durationText
        durationLabel.isHidden = item.durationText == nil
        endTimeLabel.isHidden = (item.timeEnd == nil)
        
        centerIconContainer.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
        centerIconImageView.image = nil
        
        switch item.type {
        case .point(let icon):
            centerIconContainer.backgroundColor = item.nodeColor
            centerIconContainer.layer.cornerRadius = centerNodeWidth / 2  // 保持圆形
            centerIconImageView.image = icon
        case .short(let icon):
            centerIconContainer.backgroundColor = item.nodeColor
            centerIconContainer.layer.cornerRadius = centerNodeWidth / 2  // 保持圆形
            centerIconImageView.image = icon
        case .long(let icon):
            centerIconContainer.backgroundColor = item.nodeColor
            centerIconContainer.layer.cornerRadius = centerNodeWidth / 2  // 胶囊形
            centerIconImageView.image = icon
        case .gap:
            centerIconContainer.backgroundColor = .clear
            centerIconContainer.layer.cornerRadius = 0
        }
        
        rightCircleView.layer.borderColor = item.isCompleted ? item.nodeColor.cgColor : UIColor.gray.cgColor
        rightCircleView.layer.borderWidth = 2
        rightCircleView.layer.cornerRadius = 10
        rightCircleView.backgroundColor = item.isCompleted ? item.nodeColor.withAlphaComponent(0.2) : .clear
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let verticalCenterY = bounds.height / 2
        let centerX = leftTimeWidth + margin + 8
        
        startTimeLabel.sizeToFit()
        startTimeLabel.frame = CGRect(x: 0, y: verticalCenterY - startTimeLabel.bounds.height / 2, width: leftTimeWidth, height: startTimeLabel.bounds.height)
        
        if !endTimeLabel.isHidden {
            endTimeLabel.sizeToFit()
            endTimeLabel.frame = CGRect(x: 0, y: verticalCenterY + 20, width: leftTimeWidth, height: endTimeLabel.bounds.height)
        }
        
        // centerIconContainer 从 cell 顶部延伸到底部
        centerIconContainer.frame = CGRect(x: centerX, y: 0, width: centerNodeWidth, height: bounds.height)
        centerIconImageView.frame = CGRect(x: 0, y: (bounds.height - 24) / 2, width: centerNodeWidth, height: 24)
        
        // 背景色和圆角保持不变（在 configure 中设置）
        
        let textStartX = centerX + centerNodeWidth + 12
        let textMaxWidth = bounds.width - textStartX - margin - rightCircleSize - margin
        
        if !durationLabel.isHidden {
            durationLabel.sizeToFit()
            durationLabel.frame = CGRect(x: textStartX, y: verticalCenterY - 30, width: durationLabel.bounds.width + 12, height: durationLabel.bounds.height + 4)
        }
        
        let titleY = durationLabel.isHidden ? verticalCenterY - 10 : verticalCenterY - 8
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(x: textStartX, y: titleY, width: min(titleSize.width, textMaxWidth), height: titleSize.height)
        
        if let _ = currentItem?.subtitle, !(currentItem?.subtitle?.isEmpty ?? true) {
            subtitleLabel.isHidden = false
            subtitleLabel.sizeToFit()
            subtitleLabel.frame = CGRect(x: textStartX, y: titleLabel.frame.maxY + 4, width: min(textMaxWidth, subtitleLabel.bounds.width), height: subtitleLabel.bounds.height)
        } else {
            subtitleLabel.isHidden = true
        }
        
        rightCircleView.frame = CGRect(x: bounds.width - rightCircleSize - margin, y: verticalCenterY - rightCircleSize / 2, width: rightCircleSize, height: rightCircleSize)
    }
}

// MARK: - 主视图

class MyDayTimelineView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: [TimelineDataItem] = []
    
    weak var delegate: MyDayTimelineViewDelegate?
    
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
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: "TimelineCell")
        collectionView.register(TimelineConnectionCell.self, forCellWithReuseIdentifier: "TimelineConnectionCell")
        addSubview(collectionView)
    }
    
    // MARK: - Public Methods
    
    /// 刷新时间线数据
    func reloadData() {
        guard let delegate = delegate else { return }
        
        let events = delegate.timelineViewEvents(self)
        dataSource = TimelineEventConverter.convert(events: events)
        
        if let layout = collectionView.collectionViewLayout as? TimelineLayout {
            layout.dataSource = dataSource
        }
        
        collectionView.reloadData()
    }
    
    /// 获取指定位置的原始事件
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
            cell.configure(with: connectionItem)
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let event = event(at: indexPath) else { return }
        delegate?.timelineView(self, didSelectEvent: event)
    }
}
