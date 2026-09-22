//
//  CountdownEventViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation

/// 倒数日事项列表变更（用于列表刷新时定位变化的事项）
enum CountdownEventListChange {
    case create(CountdownEvent)
    case update(CountdownEvent)
}

/// 倒数日事项分组
class CountdownEventGroup: NSObject, GroupRepresentable {
    
    /// 分组唯一标识
    let identifier: String
    
    /// 分组标题
    var name: String?
    
    /// 分组内倒数日事项
    var events: [ListDiffable]?
    
    convenience override init() {
        self.init(identifier: UUID().uuidString)
    }
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: - GroupRepresentable
    var items: [ListDiffable]? {
        return self.events
    }
    
    @discardableResult
    func moveEvent(fromIndex:Int, toIndex:Int) -> Bool {
        guard var events = events else {
            return false
        }
        
        let bMoved = events.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        self.events = events
        return bMoved
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CountdownEventGroup else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}

class CountdownEventViewModel: CountdownEventProcessorDelegate,
                                TPMidnightUpdatable {
    
    private(set) var groups: [CountdownEventGroup]?
    
    private(set) var events: [CountdownEvent]?
    
    /// 分组唯一标识
    var groupIdentifier: String {
        return "CountdownEventGroup"
    }
    
    /// 倒数日事项改变
    var eventsDidChange: ((CountdownEventListChange?) -> Void)?
    
    /// 筛选类型
    var filterType: CountdownTypeFilterType = .all
    
    /// 筛选类型改变回调
    var filterTypeDidChange: (() -> Void)?
    
    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            self.placeholderProvider.state = state
        }
    }
    
    private var needsRefresh = true
    
    private let requestManager = TPRequestManager()
    
    var placeholderProvider = TPLoadableListPlaceholderProvider()
    
    init() {
        self.placeholderProvider.state = self.state
        self.placeholderProvider.emptyTitle = resGetString("No Countdown")
        CountdownRepository.addUpdater(self)
        TPMidnightScheduler.shared.addUpdater(self)
    }
    
    func setNeedsRefresh(_ refresh: Bool = true) {
        self.needsRefresh = refresh
    }
    
    // MARK: - 加载数据
    func loadEvents(with change: CountdownEventListChange? = nil, completion: (() -> Void)? = nil) {
        let change = change
        let requestID = requestManager.executeRequest()
        loadEventsIfNeeded { [weak self] events in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion?()
                return
            }
            
            self.events = events
            
            /// 分组
            self.updateGroups()
            
            self.needsRefresh = false
            self.state = .loaded
            self.eventsDidChange?(change)
            completion?()
        }
    }
    
    /// 按筛选类型过滤后的事项
    var filteredEvents: [CountdownEvent]? {
        guard let events = events else {
            return nil
        }

        return events.filter { filterType.matches($0) }
    }
    
    /// 指定筛选类型对应的事项数目
    func numberOfEvents(for filterType: CountdownTypeFilterType) -> Int {
        guard let events = events else {
            return 0
        }

        return events.filter { filterType.matches($0) }.count
    }
    
    /// 更新筛选类型
    func updateFilterType(_ filterType: CountdownTypeFilterType) {
        guard self.filterType != filterType else {
            return
        }
        
        self.filterType = filterType
        updateGroups()
        filterTypeDidChange?()
    }
    
    /// 更新分组
    private func updateGroups() {
        guard events != nil else {
            groups = nil
            return
        }
        
        let group = CountdownEventGroup(identifier: groupIdentifier)
        group.events = filteredEvents
        groups = [group]
    }
    
    private func loadEventsIfNeeded(completion: @escaping ([CountdownEvent]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.events)
            return
        }
        
        fetchEvents(completion: completion)
    }
    
    func fetchEvents(completion: @escaping ([CountdownEvent]?) -> Void) {
        CountdownRepository.fetchActiveEvents(completion: completion)
    }
    
    // MARK: - 排序
    func moveEvent(at sourceIndexPath: IndexPath,
                   to targetIndexPath: IndexPath) -> Bool {
        guard var events = events, sourceIndexPath.section == targetIndexPath.section else {
            return false
        }

        let bMoved = events.moveObject(fromIndex: sourceIndexPath.item,
                                       toIndex: targetIndexPath.item)
        self.events = events
        return bMoved
    }
    
    /// 保存有序事项
    func didEndReorderEvents(with orderedEvents: [CountdownEvent]) {
        /// 排序结束，分组内事项顺序会改变，需更新分组
        updateGroups()
        CountdownRepository.didEndReorderEvents(with: orderedEvents)
    }
    
    // MARK: - CountdownEventProcessorDelegate
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        setNeedsRefresh()
        loadEvents()
    }
    
    func didCreateCountdownEvent(_ event: CountdownEvent) {
        setNeedsRefresh()
        loadEvents(with: .create(event))
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent, with change: CountdownEventChange) {
        setNeedsRefresh()
        loadEvents(with: .update(event))
    }
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {
        setNeedsRefresh()
        loadEvents()
    }
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {
        setNeedsRefresh()
        loadEvents(with: .update(event))
    }
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {
        setNeedsRefresh()
        loadEvents(with: .update(event))
    }
    
    func didReorderCountdownEvent(in events: [CountdownEvent], fromIndex: Int, toIndex: Int) {
        setNeedsRefresh()
        loadEvents()
    }
    
    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        setNeedsRefresh()
        loadEvents()
    }
}
