//
//  CountdownEventViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation

/// 倒数日事项变更
enum CountdownEventChange {
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

class CountdownEventViewModel: CountdownEventProcessorDelegate {
    
    private(set) var groups: [CountdownEventGroup]?

    private(set) var events: [CountdownEvent]?
    
    /// 倒数日事项改变
    var eventsDidChange: ((CountdownEventChange?) -> Void)?
    
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
    }
    
    func setNeedsRefresh(_ refresh: Bool = true) {
        self.needsRefresh = refresh
    }
    
    // MARK: - 加载数据
    func loadEvents(with change: CountdownEventChange? = nil, completion: (() -> Void)? = nil) {
        let change = change
        let requestID = requestManager.executeRequest()
        loadEventsIfNeeded { [weak self] events in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion?()
                return
            }
            
            self.events = events
            
            /// 分组
            let group = CountdownEventGroup(identifier: "CountdownEventGroup")
            group.events = events
            self.groups = [group]
            
            self.needsRefresh = false
            self.state = .loaded
            self.eventsDidChange?(change)
            completion?()
        }
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
        guard let groups = groups, sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        let section = sourceIndexPath.section
        guard section < groups.count else {
            return false
        }
        
        let group = groups[section]
        return group.moveEvent(fromIndex: sourceIndexPath.item, toIndex: targetIndexPath.item)
    }
    
    /// 保存有序事项
    func didEndReorderEvents(with orderedEvents: [CountdownEvent]) {
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
    
    func didUpdateCountdownEvent(_ event: CountdownEvent) {
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
}
