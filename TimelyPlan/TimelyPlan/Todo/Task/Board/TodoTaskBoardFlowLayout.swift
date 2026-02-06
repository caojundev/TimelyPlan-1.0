//
//  TodoTaskBoardFlowLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/14.
//

import Foundation
import UIKit

class TodoTaskBoardFlowLayout: UICollectionViewFlowLayout {
    
    var collectionSize: CGSize = .zero {
        didSet {
            updateItemSize()
        }
    }

    private var pageWidth: CGFloat {
        return itemSize.width + itemSpacing
    }
    
    /// 是否允许翻页
    private var isPagingEnabled: Bool = false
    
    /// 看板间距
    private let itemSpacing: CGFloat = 4.0
    
    /// 两侧预览部分的宽度
    private let peekWidth: CGFloat = 24
    
    /// iPad regular 模式下条目宽度
    private let regularItemWidth: CGFloat = 300.0
    
    /// 更新条目
    private func updateItemSize() {
        var itemWidth: CGFloat
        if UIDevice.current.isPhone || UITraitCollection.isCompactMode() {
            itemWidth = collectionSize.width - peekWidth - 2 * itemSpacing
            isPagingEnabled = true
        } else {
            itemWidth = regularItemWidth
            isPagingEnabled = false
        }

        var itemHeight = collectionSize.height - itemSpacing
        if let collectionView = collectionView {
            itemHeight -= collectionView.adjustedContentInset.verticalLength
        }
        
        itemSize = CGSize(width: itemWidth, height: itemHeight)
        invalidateLayout()
    }
    
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = itemSpacing
        sectionInset = UIEdgeInsets(horizontal: peekWidth / 2.0)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard isPagingEnabled, let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }
        
        // 计算当前页面的索引
        let currentPageOffset = collectionView.contentOffset.x
        let nearestPageOffset = round(currentPageOffset / pageWidth) * pageWidth - itemSpacing
        
        // 根据滑动速度决定是否切换到下一页
        let flickVelocityThreshold: CGFloat = 0.3
        var nextPageOffset: CGFloat = nearestPageOffset
        if velocity.x > flickVelocityThreshold {
            nextPageOffset = nearestPageOffset + pageWidth
        } else if velocity.x < -flickVelocityThreshold {
            nextPageOffset = nearestPageOffset - pageWidth
        }
        
        // 确保偏移量在有效范围内
        nextPageOffset = max(0, min(nextPageOffset, collectionView.contentSize.width - collectionView.bounds.width))
        // 返回目标偏移量
        return CGPoint(x: nextPageOffset, y: proposedContentOffset.y)
    }
    
    // 启用实时布局更新
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
