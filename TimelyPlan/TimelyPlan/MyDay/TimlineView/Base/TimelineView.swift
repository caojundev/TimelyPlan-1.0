//
//  TimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

// MARK: - TimelineView

protocol TimelineViewDelegate: AnyObject {
    func timelineViewEvents(_ timelineView: TimelineView) -> [MyDayEvent]
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent)

    func timelineViewWillBeginDragging(_ timelineView: TimelineView)
}

extension TimelineViewDelegate {
    func timelineView(_ timelineView: TimelineView, didSelectEvent event: MyDayEvent) {}
    
    func timelineViewWillBeginDragging(_ timelineView: TimelineView) {}
}

// MARK: - TimelineView

class TimelineView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        backgroundColor = .systemBackground
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

