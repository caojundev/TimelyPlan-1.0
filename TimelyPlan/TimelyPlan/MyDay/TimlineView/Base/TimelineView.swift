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
    static func cellHeight(for item: TimelineItem) -> CGFloat {
        switch item.type {
        case .long: return TimelineConfig.longCellHeight
        case .point: return TimelineConfig.pointCellHeight
        case .short: return TimelineConfig.shortCellHeight
        }
    }
    
    static let footerHeight: CGFloat = 44.0
}


// MARK: - TimelineView

protocol TimelineViewDelegate: AnyObject {
    func timelineViewEvents(_ timelineView: TimelineView) -> [MyDayEvent]?
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent)
    func timelineViewWillBeginDragging(_ timelineView: TimelineView)
}

extension TimelineViewDelegate {
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent) {}
    func timelineViewWillBeginDragging(_ timelineView: TimelineView) {}
}


// MARK: - TimelineView

class TimelineView: UIView,
                    UICollectionViewDataSource,
                    UICollectionViewDelegate,
                    UICollectionViewDelegateFlowLayout,
                    TimelineProgressUpdatable {
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    
    weak var delegate: TimelineViewDelegate?
    
    var dataSource: TimelineDataSource = TimelineDataSource(events: [])
    
    /// 已注册的 Cell 类名集合
    private var registeredCellClassNames: Set<String> = []
    
    /// 已注册的 SupplementaryView 类名集合
    private var registeredSupplementaryViewClassNames: Set<String> = []
    
    private let timerUpdater = TPMinuteUpdater()
    
    /// 全天事项显示配置（可自定义）
    var allDayEventsDisplayOption: TimelineAllDayEventsDisplayOption = .defaultValue {
        didSet {
            guard oldValue != allDayEventsDisplayOption else { return }
            reloadAllDaySection()
        }
    }

    /// 全天事项是否已展开
    private var isAllDayExpanded = false
    
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
        backgroundColor = .systemBackground
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: bounds,
                                          collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(bottom: 80.0)
        addSubview(collectionView)
        
        // 注册 Footer View
        registerSupplementaryViewIfNeeded(TimelineAllDayFooterView.self, forKind: UICollectionView.elementKindSectionFooter)
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
    
    // MARK: - Cell 注册
    
    /// 根据类名注册 Cell（自动去重）
    private func registerCellIfNeeded(_ cellClass: AnyClass) {
        let className = String(describing: cellClass)
        guard !registeredCellClassNames.contains(className) else { return }
        
        collectionView.register(cellClass, forCellWithReuseIdentifier: className)
        registeredCellClassNames.insert(className)
    }
    
    /// 根据类名注册 SupplementaryView（自动去重）
    private func registerSupplementaryViewIfNeeded(_ viewClass: AnyClass, forKind kind: String) {
        let className = String(describing: viewClass)
        let key = "\(kind)_\(className)"
        guard !registeredSupplementaryViewClassNames.contains(key) else { return }
        
        collectionView.register(viewClass,
                               forSupplementaryViewOfKind: kind,
                               withReuseIdentifier: className)
        registeredSupplementaryViewClassNames.insert(key)
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
    func configureEventCell(_ cell: TimelineEventCell, with item: TimelineItem) {
        cell.configure(with: item)
    }
    
    /// 配置连接线 Cell（子类可重写以进行额外配置）
    func configureConnectionCell(_ cell: TimelineConnectionCell, with item: TimelineConnectionItem) {
        cell.configure(with: item)
    }
     
    // MARK: - TimelineProgressUpdatable
    func updateTimeProgress() {
        guard let cells = collectionView.visibleCells as? [TimelineProgressUpdatable] else {
            return
        }
        
        cells.forEach { cell in
            cell.updateTimeProgress()
        }
    }
    
    // MARK: - Public Methods
    
    func reloadData() {
        guard let delegate = delegate else { return }
        let events = delegate.timelineViewEvents(self) ?? []
        dataSource = TimelineDataSource(events: events)
        
        // 重置展开状态
        isAllDayExpanded = false
        
        collectionView.reloadData()
    }
    
    func reloadAllDaySection() {
        // 重置展开状态
        isAllDayExpanded = false

        // 刷新全天事项 section
        let allDaySection = TimelineSection.allDay.rawValue
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: allDaySection))
        }, completion: nil)
    }
    
    // MARK: - Private Methods
    
    /// 获取最大可见全天事项数量
    private var maxVisibleAllDayEvents: Int? {
        return allDayEventsDisplayOption.maxVisibleCount
    }
    
    /// 判断是否需要显示全天事项 Footer
    private func shouldShowAllDayFooter() -> Bool {
        guard let maxCount = maxVisibleAllDayEvents else { return false }
        let allDayCount = dataSource.numberOfItems(in: TimelineSection.allDay.rawValue)
        return allDayCount > maxCount
    }
    
    /// 获取当前显示的全天事项数量
    private func visibleAllDayEventsCount() -> Int {
        let totalCount = dataSource.numberOfItems(in: TimelineSection.allDay.rawValue)
        
        if isAllDayExpanded {
            return totalCount
        }
        
        guard let maxCount = maxVisibleAllDayEvents else {
            return totalCount  // Show all
        }
        
        return min(totalCount, maxCount)
    }
    
    /// 获取隐藏的全天事项数量
    private func hiddenAllDayEventsCount() -> Int {
        let totalCount = dataSource.numberOfItems(in: TimelineSection.allDay.rawValue)
        return max(0, totalCount - visibleAllDayEventsCount())
    }
    
    /// 处理展开/收起按钮点击
    @objc private func toggleAllDayEvents() {
        isAllDayExpanded.toggle()
        
        // 重新加载全天事项 section
        let allDaySection = TimelineSection.allDay.rawValue
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: allDaySection))
        }, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == TimelineSection.allDay.rawValue {
            return visibleAllDayEventsCount()
        }
        return dataSource.numberOfItems(in: section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataSource.dataItem(at: indexPath)
        switch item {
        case .event(let eventItem):
            let cellClass: AnyClass = self.eventCellClass(for: eventItem)
            let identifier = reuseIdentifier(for: cellClass)
            
            // 动态注册（自动去重）
            registerCellIfNeeded(cellClass)
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? TimelineEventCell else {
                fatalError("Cell with identifier \(identifier) is not a TimelineCell subclass")
            }
            
            cell.delegate = self
            configureEventCell(cell, with: eventItem)
            return cell
            
        case .connection(let connectionItem):
            let cellClass: AnyClass = self.connectionCellClass(for: connectionItem)
            let identifier = reuseIdentifier(for: cellClass)

            registerCellIfNeeded(cellClass)

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? TimelineConnectionCell else {
                fatalError("Cell with identifier \(identifier) is not a TimelineConnectionCell subclass")
            }

            cell.delegate = self
            configureConnectionCell(cell, with: connectionItem)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              indexPath.section == TimelineSection.allDay.rawValue,
              shouldShowAllDayFooter() else {
            return UICollectionReusableView()
        }
        
        let identifier = reuseIdentifier(for: TimelineAllDayFooterView.self)
        registerSupplementaryViewIfNeeded(TimelineAllDayFooterView.self, forKind: kind)
        
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? TimelineAllDayFooterView else {
            fatalError("Failed to dequeue TimelineAllDayFooterView")
        }
        
        let hiddenCount = hiddenAllDayEventsCount()
        footerView.configure(hiddenCount: hiddenCount, isExpanded: isAllDayExpanded)
        footerView.onToggleTapped = { [weak self] in
            self?.toggleAllDayEvents()
        }
        
        return footerView
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let event = dataSource.event(at: indexPath) else { return }
        delegate?.timelineView(self, didSelectEvent: event)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.timelineViewWillBeginDragging(self)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        var height = 0.0
        let item = dataSource.dataItem(at: indexPath)
        switch item {
        case .event(let eventItem):
            height = TimelineLayoutManager.cellHeight(for: eventItem)
        case .connection(let connectionItem):
            height = connectionItem.height
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == TimelineSection.allDay.rawValue && shouldShowAllDayFooter() {
            return CGSize(width: collectionView.bounds.width,
                         height: TimelineLayoutManager.footerHeight)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
}

enum TimelineSection: Int {
    case allDay = 0
    case timed
}

struct TimelineDataSource {
    
    private var allDayItems: [TimelineDataItem] = []
    
    private var timedItems: [TimelineDataItem] = []
    
    init(events: [MyDayEvent]) {
        self.allDayItems = TimelineAllDayEventConverter.convert(events: events)
        self.timedItems = TimelineTimedEventConverter.convert(events: events)
    }
    
    func numberOfItems(in section: Int) -> Int {
        if section == TimelineSection.allDay.rawValue {
            return allDayItems.count
        } else {
            return timedItems.count
        }
    }
    
    func dataItem(at indexPath: IndexPath) -> TimelineDataItem {
        if indexPath.section == TimelineSection.allDay.rawValue {
            return allDayItems[indexPath.row]
        } else {
            return timedItems[indexPath.row]
        }
    }
    
    func event(at indexPath: IndexPath) -> MyDayEvent? {
        let dataItem = dataItem(at: indexPath)
        if case .event(let item) = dataItem {
            return item.event
        }
        
        return nil
    }
}

/*
import Foundation
import UIKit

// MARK: - 布局管理器

struct TimelineLayoutManager {
    static func cellHeight(for item: TimelineItem) -> CGFloat {
        switch item.type {
        case .long: return TimelineConfig.longCellHeight
        case .point: return TimelineConfig.pointCellHeight
        case .short: return TimelineConfig.shortCellHeight
        }
    }
    
    static let footerHeight: CGFloat = 44.0
}


// MARK: - TimelineView

protocol TimelineViewDelegate: AnyObject {
    func timelineViewEvents(_ timelineView: TimelineView) -> [MyDayEvent]?
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent)
    func timelineViewWillBeginDragging(_ timelineView: TimelineView)
}

extension TimelineViewDelegate {
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent) {}
    func timelineViewWillBeginDragging(_ timelineView: TimelineView) {}
}


// MARK: - TimelineView

class TimelineView: UIView,
                    UICollectionViewDataSource,
                    UICollectionViewDelegate,
                    UICollectionViewDelegateFlowLayout,
                    TimelineProgressUpdatable {
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    
    weak var delegate: TimelineViewDelegate?
    
    var dataSource: TimelineDataSource = TimelineDataSource(events: [])
    
    /// 已注册的 Cell 类名集合
    private var registeredCellClassNames: Set<String> = []
    
    /// 已注册的 SupplementaryView 类名集合
    private var registeredSupplementaryViewClassNames: Set<String> = []
    
    private let timerUpdater = TPMinuteUpdater()
    
    /// 全天事项最大显示数量
    private let maxVisibleAllDayEvents = 3
    
    /// 全天事项是否已展开
    private var isAllDayExpanded = false
    
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
        backgroundColor = .systemBackground
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: bounds,
                                          collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(bottom: 80.0)
        addSubview(collectionView)
        
        // 注册 Footer View
        registerSupplementaryViewIfNeeded(TimelineAllDayFooterView.self, forKind: UICollectionView.elementKindSectionFooter)
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
    
    // MARK: - Cell 注册
    
    /// 根据类名注册 Cell（自动去重）
    private func registerCellIfNeeded(_ cellClass: AnyClass) {
        let className = String(describing: cellClass)
        guard !registeredCellClassNames.contains(className) else { return }
        
        collectionView.register(cellClass, forCellWithReuseIdentifier: className)
        registeredCellClassNames.insert(className)
    }
    
    /// 根据类名注册 SupplementaryView（自动去重）
    private func registerSupplementaryViewIfNeeded(_ viewClass: AnyClass, forKind kind: String) {
        let className = String(describing: viewClass)
        let key = "\(kind)_\(className)"
        guard !registeredSupplementaryViewClassNames.contains(key) else { return }
        
        collectionView.register(viewClass,
                               forSupplementaryViewOfKind: kind,
                               withReuseIdentifier: className)
        registeredSupplementaryViewClassNames.insert(key)
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
    func configureEventCell(_ cell: TimelineEventCell, with item: TimelineItem) {
        cell.configure(with: item)
    }
    
    /// 配置连接线 Cell（子类可重写以进行额外配置）
    func configureConnectionCell(_ cell: TimelineConnectionCell, with item: TimelineConnectionItem) {
        cell.configure(with: item)
    }
     
    // MARK: - TimelineProgressUpdatable
    func updateTimeProgress() {
        guard let cells = collectionView.visibleCells as? [TimelineProgressUpdatable] else {
            return
        }
        
        cells.forEach { cell in
            cell.updateTimeProgress()
        }
    }
    
    // MARK: - Public Methods
    
    func reloadData() {
        guard let delegate = delegate else { return }
        let events = delegate.timelineViewEvents(self) ?? []
        dataSource = TimelineDataSource(events: events)
        collectionView.reloadData()
    }
    
    // MARK: - Private Methods
    
    /// 判断是否需要显示全天事项 Footer
    private func shouldShowAllDayFooter() -> Bool {
        let allDayCount = dataSource.numberOfItems(in: TimelineSection.allDay.rawValue)
        return allDayCount > maxVisibleAllDayEvents
    }
    
    /// 获取当前显示的全天事项数量
    private func visibleAllDayEventsCount() -> Int {
        let totalCount = dataSource.numberOfItems(in: TimelineSection.allDay.rawValue)
        if isAllDayExpanded {
            return totalCount
        }
        return min(totalCount, maxVisibleAllDayEvents)
    }
    
    /// 获取隐藏的全天事项数量
    private func hiddenAllDayEventsCount() -> Int {
        let totalCount = dataSource.numberOfItems(in: TimelineSection.allDay.rawValue)
        return max(0, totalCount - visibleAllDayEventsCount())
    }
    
    /// 处理展开/收起按钮点击
    @objc private func toggleAllDayEvents() {
        isAllDayExpanded.toggle()
        
        // 重新加载全天事项 section
        let allDaySection = TimelineSection.allDay.rawValue
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: allDaySection))
        }, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == TimelineSection.allDay.rawValue {
            return visibleAllDayEventsCount()
        }
        return dataSource.numberOfItems(in: section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataSource.dataItem(at: indexPath)
        switch item {
        case .event(let eventItem):
            let cellClass: AnyClass = self.eventCellClass(for: eventItem)
            let identifier = reuseIdentifier(for: cellClass)
            
            // 动态注册（自动去重）
            registerCellIfNeeded(cellClass)
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? TimelineEventCell else {
                fatalError("Cell with identifier \(identifier) is not a TimelineCell subclass")
            }
            
            cell.delegate = self
            configureEventCell(cell, with: eventItem)
            return cell
            
        case .connection(let connectionItem):
            let cellClass: AnyClass = self.connectionCellClass(for: connectionItem)
            let identifier = reuseIdentifier(for: cellClass)

            registerCellIfNeeded(cellClass)

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? TimelineConnectionCell else {
                fatalError("Cell with identifier \(identifier) is not a TimelineConnectionCell subclass")
            }

            cell.delegate = self
            configureConnectionCell(cell, with: connectionItem)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              indexPath.section == TimelineSection.allDay.rawValue,
              shouldShowAllDayFooter() else {
            return UICollectionReusableView()
        }
        
        let identifier = reuseIdentifier(for: TimelineAllDayFooterView.self)
        registerSupplementaryViewIfNeeded(TimelineAllDayFooterView.self, forKind: kind)
        
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? TimelineAllDayFooterView else {
            fatalError("Failed to dequeue TimelineAllDayFooterView")
        }
        
        let hiddenCount = hiddenAllDayEventsCount()
        footerView.configure(hiddenCount: hiddenCount, isExpanded: isAllDayExpanded)
        footerView.onToggleTapped = { [weak self] in
            self?.toggleAllDayEvents()
        }
        
        return footerView
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let event = dataSource.event(at: indexPath) else { return }
        delegate?.timelineView(self, didSelectEvent: event)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.timelineViewWillBeginDragging(self)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        var height = 0.0
        let item = dataSource.dataItem(at: indexPath)
        switch item {
        case .event(let eventItem):
            height = TimelineLayoutManager.cellHeight(for: eventItem)
        case .connection(let connectionItem):
            height = connectionItem.height
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == TimelineSection.allDay.rawValue && shouldShowAllDayFooter() {
            return CGSize(width: collectionView.bounds.width,
                         height: TimelineLayoutManager.footerHeight)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
}

enum TimelineSection: Int {
    case allDay = 0
    case timed
}

struct TimelineDataSource {
    
    private var allDayItems: [TimelineDataItem] = []
    
    private var timedItems: [TimelineDataItem] = []
    
    init(events: [MyDayEvent]) {
        self.allDayItems = TimelineAllDayEventConverter.convert(events: events)
        self.timedItems = TimelineTimedEventConverter.convert(events: events)
    }
    
    func numberOfItems(in section: Int) -> Int {
        if section == TimelineSection.allDay.rawValue {
            return allDayItems.count
        } else {
            return timedItems.count
        }
    }
    
    func dataItem(at indexPath: IndexPath) -> TimelineDataItem {
        if indexPath.section == TimelineSection.allDay.rawValue {
            return allDayItems[indexPath.row]
        } else {
            return timedItems[indexPath.row]
        }
    }
    
    func event(at indexPath: IndexPath) -> MyDayEvent? {
        let dataItem = dataItem(at: indexPath)
        if case .event(let item) = dataItem {
            return item.event
        }
        
        return nil
    }
}
*/
