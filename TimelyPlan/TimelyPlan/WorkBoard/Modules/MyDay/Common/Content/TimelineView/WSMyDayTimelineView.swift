//
//  WSMyDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 时间线视图

/// 我的一天时间线视图，中、大尺寸组件共用。
///
/// 数据由 `TimelineTimedEventConverter` 转换为事项与连接线，因此事项顺序、
/// 实线 / 虚线 / 重叠连接线的样式与当前时间进度都与时间线一致；
/// 行视图为组件专用的简化版本，不使用时间列，超出可见范围的最后一项由外层裁剪。
class WSMyDayTimelineView: UIView {

    /// 点击事项回调
    var didSelectEventHandler: ((MyDayEvent) -> Void)?
    
    /// 点击更多入口回调
    var didSelectMoreHandler: (() -> Void)?
    
    /// 今天的全部事项
    private(set) var allEvents: [MyDayEvent] = []
    
    /// 待展示的事项：正在进行与将要发生的事项
    private(set) var upcomingEvents: [MyDayEvent] = []
    
    /// 实际展示的事项
    private(set) var displayedEvents: [MyDayEvent] = []
    
    /// 未能展示的事项数
    private(set) var overflowCount: Int = 0
    
    /// 布局数据项，由 `displayedEvents` 转换而来
    private var dataItems: [TimelineDataItem] = []
    
    /// 已创建的数据项视图
    private var itemViews: [UIView] = []
    
    /// 上一次布局的标识，高度与事项未变化时跳过重新布局
    private var lastLayoutKey: LayoutKey?
    
    /// 分钟刷新，用于更新节点与连接线的当前时间进度
    private let minuteUpdater = TPMinuteUpdater()
    
    /// 空白提示：没有正在进行或未结束的事项时展示
    private let emptyView: WSPluginDefaultEmptyPlaceholderView = {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.title = resGetString("No Upcoming Events")
        
        let view = WSPluginDefaultEmptyPlaceholderView(configuration: configuration)
        view.isHidden = true
        return view
    }()
    
    /// 更多入口：事项未展示完时覆盖在底部展示
    private let moreButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.cornerRadius = .greatestFiniteMagnitude
        button.padding = UIEdgeInsets(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0)
        button.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.selectedBackgroundColor = .primary
        button.isHidden = true
        return button
    }()
    
    /// 布局标识
    private struct LayoutKey: Equatable {
        let height: CGFloat
        let eventIdentifiers: [ObjectIdentifier]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(emptyView)
        addSubview(moreButton)
        
        moreButton.didClickHandler = { [weak self] in
            self?.didSelectMoreHandler?()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    /// 更新今天的全部事项
    func update(with events: [MyDayEvent]) {
        let identifiers = events.map { ObjectIdentifier($0) }
        guard identifiers != allEvents.map({ ObjectIdentifier($0) }) else {
            return
        }
        
        allEvents = events
        
        /// 待展示事项变化时才需要重新布局
        if refreshUpcomingEvents() {
            setNeedsLayout()
        }
    }
    
    /// 从全部事项中过滤出正在进行与将要发生的事项
    ///
    /// - Returns: 待展示事项是否发生变化
    @discardableResult
    private func refreshUpcomingEvents() -> Bool {
        let now = Date()
        let upcoming = allEvents.filter { !$0.isAllDay && $0.endDate > now }
        guard upcoming.map({ ObjectIdentifier($0) }) != upcomingEvents.map({ ObjectIdentifier($0) }) else {
            return false
        }
        
        upcomingEvents = upcoming
        lastLayoutKey = nil
        return true
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0.0 else {
            return
        }
        
        prepareLayoutIfNeeded()
        layoutEmptyView()
        layoutItemViews()
        layoutMoreButton()
        updateTimeProgress()
    }
    
    /// 布局空白提示
    private func layoutEmptyView() {
        let isHidden = !upcomingEvents.isEmpty
        if emptyView.isHidden != isHidden {
            emptyView.isHidden = isHidden
        }
        
        guard !isHidden else {
            return
        }
        
        emptyView.frame = bounds
    }
    
    /// 高度与事项未变化时跳过重新计算
    private func prepareLayoutIfNeeded() {
        let key = LayoutKey(height: bounds.height,
                            eventIdentifiers: upcomingEvents.map { ObjectIdentifier($0) })
        guard key != lastLayoutKey else {
            return
        }
        
        lastLayoutKey = key
        
        updateDisplayedEvents()
        prepareItemViews(count: dataItems.count)
        layoutItemViews()
    }
    
    /// 按可见高度确定展示事项，并生成最终用于布局的数据项
    private func updateDisplayedEvents() {
        guard !upcomingEvents.isEmpty else {
            displayedEvents = []
            dataItems = []
            overflowCount = 0
            removeItemViews()
            return
        }
        
        /// 先按全部事项推演一次，确定可见高度内可容纳的事项数，该结果不用于布局
        /// 允许最后一个事项跨出可见区域，因此累计高度达到可用高度时才停止
        let fittingItems = TimelineTimedEventConverter.convert(events: upcomingEvents)
        let limitHeight = max(bounds.height, 1.0)
        var usedHeight: CGFloat = 0.0
        var visibleEventCount = 0
        for item in fittingItems {
            usedHeight += itemHeight(of: item)
            if case .event = item {
                visibleEventCount += 1
            }
            
            if usedHeight >= limitHeight {
                break
            }
        }
        
        visibleEventCount = max(min(visibleEventCount, upcomingEvents.count), 1)
        displayedEvents = Array(upcomingEvents.prefix(visibleEventCount))
        overflowCount = upcomingEvents.count - displayedEvents.count
        
        /// 再按实际展示的事项转换一次，使首尾节点的连接线样式与展示范围一致
        dataItems = TimelineTimedEventConverter.convert(events: displayedEvents)
        removeItemViews()
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
    
    /// 依次堆叠数据项视图
    private func layoutItemViews() {
        /// 高度对齐到像素网格，避免相邻行因取整出现 1px 缝隙
        let scale = max(traitCollection.displayScale, 1.0)
        var originY: CGFloat = 0.0
        for (index, itemView) in itemViews.enumerated() {
            let height = (itemHeight(of: dataItems[index]) * scale).rounded(.up) / scale
            itemView.frame = CGRect(x: 0.0, y: originY, width: bounds.width, height: height)
            originY += height
        }
    }
    
    /// 布局「更多」入口，覆盖在时间线内容上方
    private func layoutMoreButton() {
        let isHidden = overflowCount <= 0
        if moreButton.isHidden != isHidden {
            moreButton.isHidden = isHidden
        }
        
        guard !isHidden else {
            return
        }
        
        moreButton.title = String(format: resGetString("More %ld"), overflowCount)
        
        moreButton.sizeToFit()
        moreButton.right = bounds.width
        moreButton.bottom = bounds.height
        bringSubviewToFront(moreButton)
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
            rowView.didSelectHandler = { [weak self] event in
                self?.didSelectEventHandler?(event)
            }
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
            self?.refreshForCurrentTime()
        }
    }
    
    /// 时间流逝后的刷新：事项列表变化时整体重排，否则只更新进度
    private func refreshForCurrentTime() {
        if refreshUpcomingEvents() {
            setNeedsLayout()
        } else {
            updateTimeProgress()
        }
    }
    
    /// 更新节点与连接线的当前时间进度
    private func updateTimeProgress() {
        for itemView in itemViews {
            (itemView as? TimelineProgressUpdatable)?.updateTimeProgress()
        }
    }
}
