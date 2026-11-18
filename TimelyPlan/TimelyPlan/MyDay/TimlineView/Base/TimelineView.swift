//
//  TimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

// MARK: - 布局管理器

struct TimelineLayoutManager {
    
    static let footerHeight: CGFloat = 44.0
    
    static func cellHeight(for item: TimelineItem) -> CGFloat {
        switch item.type {
        case .long: return TimelineConfig.longCellHeight
        case .point: return TimelineConfig.pointCellHeight
        case .short: return TimelineConfig.shortCellHeight
        }
    }
    
    static func height(for item: TimelineDataItem) -> CGFloat {
        if let item = item as? TimelineItem {
            return cellHeight(for: item)
        }
        
        if let item = item as? TimelineConnectionItem {
            return item.height
        }
        
        return 0.0
    }
}

// MARK: - TimelineViewDelegate

protocol TimelineViewDelegate: AnyObject {
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent)
    func timelineViewWillBeginDragging(_ timelineView: TimelineView)
}

extension TimelineViewDelegate {
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent) {}
    func timelineViewWillBeginDragging(_ timelineView: TimelineView) {}
}

// MARK: - TimelineView

class TimelineView: UIView,
                    TPCollectionViewAdapterDataSource,
                    TPCollectionViewAdapterDelegate,
                    TimelineProgressUpdatable {
    
    // MARK: - Properties
    
    /// 集合视图适配器
    let adapter: TPCollectionViewAdapter = TPCollectionViewAdapter()
    
    weak var delegate: TimelineViewDelegate?
    
    /// 提供占位视图
    var placeholderProvider: TPPlaceholderProviding? {
        didSet {
            updatePlaceholderView()
        }
    }
    
    private(set) var dataSource: TimelineDataSource = TimelineDataSource(events: [])
    
    private let timerUpdater = TPMinuteUpdater()
    
    /// 全天事项显示配置（可自定义）
    var allDayEventsDisplayOption: TimelineAllDayEventsDisplayOption = .defaultValue {
        didSet {
            guard oldValue != allDayEventsDisplayOption else { return }
            reloadAllDaySection()
        }
    }

    /// 全天区块是否已展开
    /// - Note: 由分页单元格在出队时赋值为状态中的值，避免各分页状态不一致
    var isAllDayExpanded: Bool = false {
        didSet {
            guard oldValue != isAllDayExpanded else { return }
            
            /// 通知子类（例如持久化状态）
            allDayExpandedStateDidChange()
            
            /// 刷新全天事项 section
            reloadAllDaySection()
        }
    }
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = .zero
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds,
                                              collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.isPrefetchingEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(bottom: 80.0)
        return collectionView
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
        collectionView.frame = layoutFrame()
        
        adapter.dataSource = self
        adapter.delegate = self
        adapter.collectionView = collectionView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = layoutFrame()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        adapter.reloadDataIfNeeded()
    }
    
    // MARK: - 更新计时器
    func startUpdateTimer() {
        timerUpdater.start { [weak self] in
            self?.updateTimeProgress()
        }
    }
    
    func stopUpdateTimer() {
        timerUpdater.stop()
    }
    
    // MARK: - 子类重写方法
    /// 时间线事项（子类重写以提供数据）
    func timelineViewEvents() -> [MyDayEvent] {
        return []
    }
    
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
        fatalError("Subclasses must override eventCellClass(for:)")
    }
    
    /// 配置事件 Cell（子类可重写以进行额外配置）
    func configureEventCell(_ cell: TimelineEventCell, with item: TimelineItem) {
        cell.configure(with: item)
    }
    
    /// 配置连接线 Cell（子类可重写以进行额外配置）
    func configureConnectionCell(_ cell: TimelineConnectionCell, with item: TimelineConnectionItem) {
        cell.configure(with: item)
    }
    
    // MARK: - TimelineProgressUpdatable
    func updateTimeProgress() {
        guard let cells = adapter.visibleCells as? [TimelineProgressUpdatable] else {
            return
        }
        
        cells.forEach { cell in
            cell.updateTimeProgress()
        }
    }
    
    private func updateDataSource() {
        let events = timelineViewEvents()
        dataSource = TimelineDataSource(events: events,
                                        isAllDayExpanded: isAllDayExpanded,
                                        allDayMaxVisibleCount: allDayEventsDisplayOption.maxVisibleCount)
    }
    
    // MARK: - Public Methods
    func performUpdate() {
        updateDataSource()
        adapter.performUpdate()
        updatePlaceholderView()
    }
    
    func reloadData() {
        updateDataSource()
        adapter.reloadData()
        updatePlaceholderView()
    }
    
    /// 更新占位视图
    func updatePlaceholderView() {
        collectionView.placeholderView = placeholderProvider?.placeholderView()
    }
    
    /// 刷新全天事项区块（保持当前的展开状态）
    func reloadAllDaySection() {
        let section = dataSource.allDaySection
        section.isExpanded = isAllDayExpanded
        section.maxVisibleCount = allDayEventsDisplayOption.maxVisibleCount
        
        /// 条目数量或 Footer 高度变化后重新布局
        adapter.performSectionUpdate(forSectionObject: section) { [weak self] _ in
            self?.collectionViewLayout.invalidateLayout()
        }
    }
    
    /// 全天区块展开状态变化（子类可重写，用于持久化状态等）
    func allDayExpandedStateDidChange() {
        
    }
}

// MARK: - TPCollectionViewAdapterDataSource

extension TimelineView {
    
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return dataSource.sections
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let section = sectionObject as? TimelineSectionObject else {
            return nil
        }
        
        return section.visibleItems().map { $0 as ListDiffable }
    }
}

// MARK: - TPCollectionViewAdapterDelegate

extension TimelineView {
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        guard let item = adapter.item(at: indexPath) as? TimelineItem else {
            return
        }
        
        delegate?.timelineView(self, didSelectEvent: item.event)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        guard let item = adapter.item(at: indexPath) as? TimelineDataItem else {
            return nil
        }
        
        switch item {
        case let item as TimelineItem:
            return eventCellClass(for: item)
        case let item as TimelineConnectionItem:
            return connectionCellClass(for: item)
        default:
            return nil
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let item = adapter.item(at: indexPath) as? TimelineDataItem else {
            return
        }
        
        if let cell = cell as? TimelineEventCell, let item = item as? TimelineItem {
            cell.delegate = self
            configureEventCell(cell, with: item)
        } else if let cell = cell as? TimelineConnectionCell, let item = item as? TimelineConnectionItem {
            cell.delegate = self
            configureConnectionCell(cell, with: item)
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = adapter.item(at: indexPath) as? TimelineDataItem else {
            return .zero
        }
        
        return CGSize(width: adapter.collectionViewSize().width,
                      height: TimelineLayoutManager.height(for: item))
    }
    
    // MARK: - Footer
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForFooterInSection section: Int) -> AnyClass? {
        guard let object = adapter.object(at: section) as? TimelineSectionObject,
              object.kind == .allDay else {
            return nil
        }
        
        return TimelineAllDayFooterView.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForFooterInSection section: Int) -> CGSize {
        guard let object = adapter.object(at: section) as? TimelineSectionObject,
              object.shouldShowFooter else {
            return .zero
        }
        
        return CGSize(width: adapter.collectionViewSize().width,
                      height: TimelineLayoutManager.footerHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeFooter footerView: UICollectionReusableView, inSection section: Int) {
        configureFooter(footerView, inSection: section)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, updateFooterInSection section: Int) {
        guard let footerView = adapter.footerView(in: section) else {
            return
        }
        
        configureFooter(footerView, inSection: section)
    }
    
    private func configureFooter(_ footerView: UICollectionReusableView, inSection section: Int) {
        guard let footerView = footerView as? TimelineAllDayFooterView,
              let object = adapter.object(at: section) as? TimelineSectionObject else {
            return
        }
        
        footerView.configure(hiddenCount: object.hiddenItemCount, isExpanded: object.isExpanded)
        footerView.onToggleTapped = { [weak self] in
            self?.isAllDayExpanded.toggle()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.timelineViewWillBeginDragging(self)
    }
}

// MARK: - 数据源

struct TimelineDataSource {
    
    /// 全天事项区块
    let allDaySection: TimelineSectionObject
    
    /// 按时间排列的事项区块
    let timedSection: TimelineSectionObject
    
    init(events: [MyDayEvent],
         isAllDayExpanded: Bool = false,
         allDayMaxVisibleCount: Int? = nil) {
        let allDaySection = TimelineSectionObject(kind: .allDay,
                                                  items: TimelineAllDayEventConverter.convert(events: events))
        allDaySection.isExpanded = isAllDayExpanded
        allDaySection.maxVisibleCount = allDayMaxVisibleCount
        self.allDaySection = allDaySection
        
        self.timedSection = TimelineSectionObject(kind: .timed,
                                                  items: TimelineTimedEventConverter.convert(events: events))
    }
    
    /// 区块对象数组
    var sections: [ListDiffable] {
        return [allDaySection, timedSection]
    }
}
