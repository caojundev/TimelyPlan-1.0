//
//  TimelineLayout.swift
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
