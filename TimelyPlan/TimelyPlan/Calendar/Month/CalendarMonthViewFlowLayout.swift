//
//  CalendarMonthViewFlowLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/5.
//

import Foundation
import UIKit

class CalendarMonthViewFlowLayout: UICollectionViewFlowLayout {
    
    var collectionSize: CGSize = .zero {
        didSet {
            if collectionSize != oldValue {
                updateItemSize()
            }
        }
    }

    var preferredRowsCount = 5 {
        didSet {
            if preferredRowsCount != oldValue {
                updateItemSize()
            }
        }
    }
    
    var minimumItemHeight = 120.0
    
    /// 更新条目尺寸
    private func updateItemSize() {
        guard collectionSize != .zero else {
            return
        }
        
        let itemWidth = collectionSize.width
        var itemHeight = collectionSize.height / CGFloat(preferredRowsCount)
        itemHeight = max(itemHeight, minimumItemHeight)
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.invalidateLayout()
    }
    
    override func prepare() {
        super.prepare()
        scrollDirection = .vertical
        sectionInset = .zero
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // 计算最近的单元格顶部位置
        let offsetY = proposedContentOffset.y
        let nearestPage = round(offsetY / itemSize.height)
        var targetY = nearestPage * itemSize.height
        let contentHeight = collectionView?.contentSize.height ?? .greatestFiniteMagnitude
        if targetY + collectionSize.height > contentHeight {
            targetY = CGFloat(Int(offsetY / itemSize.height)) * itemSize.height
        }
        
        // 返回调整后的偏移量
        return CGPoint(x: proposedContentOffset.x, y: targetY)
    }
    
    /// 启用实时布局更新
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
