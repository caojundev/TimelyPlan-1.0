//
//  HabitDatePeriodsView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/23.
//

import Foundation
import UIKit

protocol HabitDatePeriodsViewDelegate: AnyObject {
    
    /// 获取统计周期数组
    func periodsInDatePeriodsView(_ view: HabitDatePeriodsView) -> [HabitDatePeriod]?
    
    /// 时间段对应单元格类
    func datePeriodsView(_ view: HabitDatePeriodsView,
                         cellClassForPeriod period: HabitDatePeriod) -> AnyClass
    
    /// 单元格出队列
    func datePeriodsView(_ view: HabitDatePeriodsView,
                         didDequeCell cell: UICollectionViewCell,
                         forPeriod period: HabitDatePeriod)
    
    /// 选中一个时间段
    func datePeriodsView(_ view: HabitDatePeriodsView,
                         didSelectPeriod period: HabitDatePeriod)
    
    /// 点击是否高亮时间段对应的单元格
    func datePeriodsView(_ view: HabitDatePeriodsView,
                         shouldHighlightPeriod period: HabitDatePeriod) -> Bool
}

class HabitDatePeriodsView: TPCollectionWrapperView,
                            TPCollectionSingleSectionListDataSource,
                            TPCollectionViewAdapterDataSource,
                            TPCollectionViewAdapterDelegate {

    /// 代理对象
    weak var delegate: HabitDatePeriodsViewDelegate?
     
    /// 单元格最小宽度
    var minCellWidth = 40.0
    
    /// 时间段数组
    private(set) var periods: [HabitDatePeriod] = []
    
    var visibleCells: [UICollectionViewCell] {
        return collectionView.visibleCells
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.hideScrollIndicator()
        self.scrollDirection = .horizontal
        self.collectionView.bounces = false
        self.adapter.dataSource = self
        self.adapter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重新加载与特定时间段相交的所有单元格
    func reloadPeriods(intersects otherPeriod: HabitDatePeriod) {
        var periodsToUpdate = [HabitDatePeriod]()
        for period in periods {
            if period.intersects(otherPeriod) {
                periodsToUpdate.append(period)
            }
        }
        
        if periodsToUpdate.count > 0 {
            adapter.reloadCell(forItems: periodsToUpdate)
        }
    }
    
    func cells(intersect period: HabitDatePeriod) -> [UICollectionViewCell] {
        var cells = [UICollectionViewCell]()
        for aPeriod in periods {
            guard aPeriod.intersects(period) else {
                continue
            }
            
            if let cell = cellForPeriod(aPeriod) {
                cells.append(cell)
            }
        }
        
        return cells
    }
    
    func cellForPeriod(_ period: HabitDatePeriod) -> UICollectionViewCell? {
        if let indexPath = adapter.indexPath(of: period) {
            return adapter.cellForItem(at: indexPath)
        }
        
        return nil
    }
    
    // MARK: - CollectionListDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        self.periods = delegate?.periodsInDatePeriodsView(self) ?? []
        return self.periods
    }
   
    // MARK: - CollectionListDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        let period = adapter.item(at: indexPath) as! HabitDatePeriod
        return delegate?.datePeriodsView(self, cellClassForPeriod: period)
    }

    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let period = adapter.item(at: indexPath) as! HabitDatePeriod
        delegate?.datePeriodsView(self, didDequeCell: cell, forPeriod: period)
    }

    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = adapter.collectionViewSize()
        let count = adapter.itemsCount(at: indexPath.section)
        var itemWidth = collectionViewSize.width / CGFloat(max(count, 1))
        itemWidth = max(itemWidth, minCellWidth)
        return CGSize(width: itemWidth, height: collectionViewSize.height)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let period = adapter.item(at: indexPath) as! HabitDatePeriod
        let shouldHighlight = delegate?.datePeriodsView(self, shouldHighlightPeriod: period) ?? true
        return shouldHighlight
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        let period = adapter.item(at: indexPath) as! HabitDatePeriod
        delegate?.datePeriodsView(self, didSelectPeriod: period)
    }
}
