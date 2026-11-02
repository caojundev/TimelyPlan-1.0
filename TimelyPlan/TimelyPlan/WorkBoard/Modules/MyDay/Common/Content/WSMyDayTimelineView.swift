//
//  WSMyDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 布局管理

/// 插件时间线的布局尺寸。
///
/// 组件高度有限，事项行与连接线高度都在 `TimelineLayoutManager` 的基础上缩小，
/// 连接样式与顺序仍由 `TimelineTimedEventConverter` 决定。
struct WSMyDayTimelineLayoutManager {
    
    /// 节点与连接线的底色
    ///
    /// 插件内的节点与连接线固定使用深色，避免浅色模式下取到未来日期的浅灰底色
    static let trackColor = Color(0x262626)
    
    /// 事项行高度
    static func cellHeight(for item: TimelineItem) -> CGFloat {
        switch item.type {
        case .point:
            return 48.0
        case .short:
            return 64.0
        case .long:
            return 84.0
        }
    }
    
    /// 连接线行高度：按原高度等比缩小，并保证最小高度
    static func connectionHeight(for item: TimelineConnectionItem) -> CGFloat {
        return max(item.height * 0.5, 12.0)
    }
}

// MARK: - 时间线视图

/// 我的一天时间线视图，中、大尺寸组件共用。
///
/// 数据由 `TimelineTimedEventConverter` 转换为事项与连接线，因此事项顺序、
/// 实线 / 虚线 / 重叠连接线的样式与当前时间进度都与时间线一致；
/// 行视图为组件专用的简化版本，不使用时间列，超出可见范围的最后一项由外层裁剪。
class WSMyDayTimelineView: UIView {
    
    /// 最多展示的数据项数（事项与连接线合计）
    var maximumItemCount: Int = Int.max {
        didSet {
            guard maximumItemCount != oldValue else {
                return
            }
            
            setNeedsLayout()
        }
    }
    
    /// 时间线数据项，顺序与展示顺序一致
    private var dataItems: [TimelineDataItem] = []
    
    /// 已创建的数据项视图
    private var itemViews: [UIView] = []
    
    /// 已展示事项的标识，内容未变化时跳过重复转换
    private var displayedEvents: [ObjectIdentifier] = []
    
    /// 分钟刷新，用于更新节点与连接线的当前时间进度
    private let minuteUpdater = TPMinuteUpdater()
    
    deinit {
        minuteUpdater.stop()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window == nil {
            minuteUpdater.stop()
        } else {
            startUpdating()
        }
    }
    
    // MARK: - 渲染
    /// 更新展示的事项
    func update(with events: [MyDayEvent]) {
        let identifiers = events.map { ObjectIdentifier($0) }
        guard identifiers != displayedEvents else {
            return
        }
        
        displayedEvents = identifiers
        dataItems = TimelineTimedEventConverter.convert(events: events)
        removeItemViews()
        
        setNeedsLayout()
    }
    
    /// 按可用高度计算可展示的数据项数
    ///
    /// 允许最后一项跨出可见区域，因此返回第一个使累计高度超过可见高度的项
    func visibleItemCount(forHeight height: CGFloat) -> Int {
        guard height > 0.0, !dataItems.isEmpty else {
            return 0
        }
        
        var usedHeight: CGFloat = 0.0
        for (index, item) in dataItems.enumerated() {
            usedHeight += itemHeight(of: item)
            if usedHeight >= height {
                return index + 1
            }
        }
        
        return dataItems.count
    }
    
    /// 数据项高度
    private func itemHeight(of item: TimelineDataItem) -> CGFloat {
        switch item {
        case .event(let eventItem):
            return WSMyDayTimelineLayoutManager.cellHeight(for: eventItem)
        case .connection(let connectionItem):
            return WSMyDayTimelineLayoutManager.connectionHeight(for: connectionItem)
        }
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0.0 else {
            return
        }
        
        let itemCount = min(maximumItemCount, dataItems.count)
        prepareItemViews(count: itemCount)
        
        var originY: CGFloat = 0.0
        for (index, itemView) in itemViews.enumerated() {
            let height = itemHeight(of: dataItems[index])
            itemView.frame = CGRect(x: 0.0, y: originY, width: bounds.width, height: height)
            originY += height
        }
        
        updateTimeProgress()
    }
    
    // MARK: - 视图管理
    /// 移除全部数据项视图
    private func removeItemViews() {
        itemViews.forEach { $0.removeFromSuperview() }
        itemViews = []
    }
    
    /// 按需创建或移除数据项视图
    private func prepareItemViews(count: Int) {
        if itemViews.count > count {
            itemViews[count...].forEach { $0.removeFromSuperview() }
            itemViews.removeSubrange(count...)
        }
        
        while itemViews.count < count {
            let itemView = makeItemView(for: dataItems[itemViews.count])
            addSubview(itemView)
            itemViews.append(itemView)
        }
    }
    
    /// 创建数据项视图并绑定数据
    private func makeItemView(for item: TimelineDataItem) -> UIView {
        switch item {
        case .event(let eventItem):
            let rowView = WSMyDayTimelineEventRowView()
            rowView.update(with: eventItem)
            return rowView
        case .connection(let connectionItem):
            let connectionView = WSMyDayTimelineConnectionView()
            connectionView.configure(with: connectionItem)
            return connectionView
        }
    }
    
    // MARK: - 时间进度
    private func startUpdating() {
        minuteUpdater.start { [weak self] in
            self?.updateTimeProgress()
        }
    }
    
    /// 更新节点与连接线的当前时间进度
    private func updateTimeProgress() {
        for itemView in itemViews {
            (itemView as? TimelineProgressUpdatable)?.updateTimeProgress()
        }
    }
}

// MARK: - 事项行视图

/// 插件时间线的事项行：左侧节点（图标或表情）、右侧名称与详情
class WSMyDayTimelineEventRowView: UIView, TimelineProgressUpdatable {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 节点列宽度，与连接线一致
        static let nodeColumnWidth: CGFloat = TimelineConfig.centerNodeWidth
        
        /// 节点与内容的间距
        static let nodeContentSpacing: CGFloat = 12.0
        
        /// 名称字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
        
        /// 详情字体
        static let subtitleFont = UIFont.systemFont(ofSize: 11.0, weight: .medium)
        
        /// 名称与详情的间距
        static let subtitleTopMargin: CGFloat = 2.0
    }
    
    /// 节点
    private let nodeView = WSMyDayTimelineNodeView()
    
    /// 名称与详情
    private let infoView: TPInfoView = {
        let view = TPInfoView()
        view.padding = .zero
        view.titleConfig = .withFont(Metrics.titleFont,
                                     numberOfLines: 1,
                                     textColor: .label,
                                     adjustsFontSizeToFitWidth: true,
                                     minimumScaleFactor: 0.8)
        view.subtitleConfig = .withFont(Metrics.subtitleFont,
                                        numberOfLines: 2,
                                        textColor: .secondaryLabel,
                                        adjustsFontSizeToFitWidth: true,
                                        minimumScaleFactor: 0.8)
        view.subtitleLabel.alpha = 0.8
        view.subtitleTopMargin = Metrics.subtitleTopMargin
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(nodeView)
        addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 渲染
    /// 更新展示的事项
    func update(with item: TimelineItem) {
        nodeView.configure(with: item)
        nodeView.configureIcon(item.event.sourceIcon)
        infoView.title = item.event.displayTitle
        infoView.subtitle = item.event.displaySubtitle
        
        setNeedsLayout()
    }
    
    // MARK: - TimelineProgressUpdatable
    func updateTimeProgress() {
        nodeView.updateTimeProgress()
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        nodeView.frame = CGRect(x: 0.0,
                                y: 0.0,
                                width: Metrics.nodeColumnWidth,
                                height: bounds.height)
        
        layoutInfoView()
    }
    
    /// 名称与详情按内容高度居中展示
    private func layoutInfoView() {
        let infoLeft = Metrics.nodeColumnWidth + Metrics.nodeContentSpacing
        let infoWidth = max(bounds.width - infoLeft, 0.0)
        guard infoWidth > 0.0 else {
            return
        }
        
        let titleHeight = TPLabelLayout(content: infoView.titleContent, config: infoView.titleConfig)
            .boundingSize(with: infoWidth).height
        let subtitleHeight = TPLabelLayout(content: infoView.subtitleContent, config: infoView.subtitleConfig)
            .boundingSize(with: infoWidth).height
        
        var infoHeight = titleHeight
        if subtitleHeight > 0.0 {
            infoHeight += infoView.subtitleTopMargin + subtitleHeight
        }
        
        infoHeight = min(infoHeight, bounds.height)
        infoView.frame = CGRect(x: infoLeft,
                                y: (bounds.height - infoHeight) / 2.0,
                                width: infoWidth,
                                height: infoHeight)
    }
}

// MARK: - 事项节点视图

/// 插件时间线的事项节点：在 `TimelineNodeView` 的节点上叠加图标或表情
class WSMyDayTimelineNodeView: TimelineNodeView {
    
    /// 图标尺寸
    private let iconSize = CGSize(width: 20.0, height: 20.0)
    
    /// 图标
    private let iconView = TPIconView()
    
    override func setupView() {
        super.setupView()
        
        iconView.borderWidth = 0.0
        iconView.foreColor = .white
        iconView.font = .systemFont(ofSize: 11.0)
        addSubview(iconView)
    }
    
    /// 节点底色固定使用深色，浅色模式下同样如此
    override func nodeBackgroundColor(for item: TimelineItem) -> UIColor {
        return WSMyDayTimelineLayoutManager.trackColor
    }
    
    /// 配置图标或表情
    func configureIcon(_ icon: TPIcon?) {
        iconView.icon = icon
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.size = iconSize
        iconView.center = CGPoint(x: contentView.frame.midX, y: contentView.frame.midY)
    }
}

// MARK: - 连接线行视图

/// 插件时间线的连接线行，移植自 `TimelineSolidConnectionCell`、
/// `TimelineDashedConnectionCell` 与 `TimelineOverlappingConnectionCell`，
/// 去掉添加 / 绑定按钮，仅保留线条、当前时间进度与重叠渐变。
class WSMyDayTimelineConnectionView: UIView, TimelineProgressUpdatable {
    
    /// 背景渐变层，负责连接线的底色
    private let backgroundGradientLayer = CAGradientLayer()
    
    /// 背景线条遮罩
    private let backgroundShapeLayer = CAShapeLayer()
    
    /// 进度渐变层
    private let progressGradientLayer = CAGradientLayer()
    
    /// 进度线条遮罩
    private let progressShapeLayer = CAShapeLayer()
    
    /// 连接线数据
    private var item: TimelineConnectionItem?
    
    /// 连接线样式
    private var style: TimelineConnectionStyle = .solid
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        backgroundGradientLayer.mask = backgroundShapeLayer
        layer.addSublayer(backgroundGradientLayer)
        
        progressGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        progressGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        progressGradientLayer.mask = progressShapeLayer
        layer.addSublayer(progressGradientLayer)
        
        for shapeLayer in [backgroundShapeLayer, progressShapeLayer] {
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.black.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 配置
    /// 配置连接线
    func configure(with item: TimelineConnectionItem) {
        self.item = item
        self.style = item.style
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let lineWidth: CGFloat
        let dashPattern: [NSNumber]?
        switch item.style {
        case .solid:
            lineWidth = TimelineConfig.solidLineWidth
            dashPattern = nil
        case .dashed:
            lineWidth = TimelineConfig.dashedLineWidth
            dashPattern = TimelineConfig.dashedPattern
        case .overlapping:
            lineWidth = TimelineConfig.overlappingLineWidth
            dashPattern = nil
        }
        
        backgroundShapeLayer.lineWidth = lineWidth
        backgroundShapeLayer.lineDashPattern = dashPattern
        progressShapeLayer.lineWidth = lineWidth
        progressShapeLayer.lineDashPattern = dashPattern
        
        CATransaction.commit()
        
        setNeedsLayout()
    }
    
    // MARK: - TimelineProgressUpdatable
    func updateTimeProgress() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateBackgroundColors()
        updateProgressLayer()
        CATransaction.commit()
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        backgroundGradientLayer.frame = bounds
        progressGradientLayer.frame = bounds
        
        let lineCenterX = TimelineConfig.centerNodeWidth / 2.0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineCenterX, y: 0.0))
        path.addLine(to: CGPoint(x: lineCenterX, y: bounds.height))
        backgroundShapeLayer.path = path.cgPath
        
        updateBackgroundColors()
        updateProgressLayer()
        
        CATransaction.commit()
    }
    
    /// 更新背景颜色
    private func updateBackgroundColors() {
        guard let item = item else {
            return
        }
        
        /// 底色固定为深色，避免浅色模式下未开始事项取到浅灰底色
        let backColor = WSMyDayTimelineLayoutManager.trackColor
        
        guard style == .overlapping else {
            backgroundGradientLayer.colors = [backColor.cgColor, backColor.cgColor]
            return
        }
        
        /// 重叠连接线按当前时间切换上下两段的颜色
        let currentDate = Date()
        let colors: [CGColor]
        if currentDate >= item.topDate && currentDate >= item.bottomDate {
            colors = [item.topColor.cgColor, item.bottomColor.cgColor]
        } else if currentDate >= item.topDate {
            colors = [item.topColor.cgColor, backColor.cgColor]
        } else if currentDate >= item.bottomDate {
            colors = [backColor.cgColor, item.bottomColor.cgColor]
        } else {
            colors = [backColor.cgColor, backColor.cgColor]
        }
        
        backgroundGradientLayer.colors = colors
    }
    
    /// 更新进度线条。重叠连接线只展示底色渐变，不再叠加进度
    private func updateProgressLayer() {
        guard style != .overlapping, let item = item else {
            progressShapeLayer.path = nil
            return
        }
        
        let currentDate = Date()
        let totalHeight = bounds.height
        let lineCenterX = TimelineConfig.centerNodeWidth / 2.0
        
        let progressEndY: CGFloat
        if currentDate >= item.bottomDate {
            progressEndY = totalHeight
        } else if currentDate <= item.topDate {
            progressShapeLayer.path = nil
            return
        } else {
            let totalDuration = item.bottomDate.timeIntervalSince(item.topDate)
            guard totalDuration > 0.0 else {
                progressShapeLayer.path = nil
                return
            }
            
            progressEndY = totalHeight * CGFloat(currentDate.timeIntervalSince(item.topDate) / totalDuration)
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineCenterX, y: 0.0))
        path.addLine(to: CGPoint(x: lineCenterX, y: progressEndY))
        progressShapeLayer.path = path.cgPath
        
        progressGradientLayer.colors = [item.topColor.cgColor, item.bottomColor.cgColor]
    }
}
