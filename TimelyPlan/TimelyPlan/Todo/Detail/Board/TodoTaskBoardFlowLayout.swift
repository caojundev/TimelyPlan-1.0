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
    
    /// 当前显示的页码
    var currentPage: Int {
        guard itemSize.width > 0, let collectionView = collectionView else {
            return 0
        }
        
        let offsetX = collectionView.contentOffset.x + itemSpacing
        return max(0, Int(round(offsetX / pageWidth)))
    }
    
    /// 滚动到指定页
    /// - Parameters:
    ///   - page: 目标页码（从0开始）
    ///   - animated: 是否动画
    func scrollToPage(_ page: Int, animated: Bool) {
        guard isPagingEnabled, let collectionView = collectionView else {
            return
        }
        
        let maxPage = max(0, Int(ceil(collectionView.contentSize.width / pageWidth)) - 1)
        let targetPage = max(0, min(page, maxPage))
        let targetOffsetX = CGFloat(targetPage) * pageWidth - itemSpacing
        collectionView.setContentOffset(CGPoint(x: targetOffsetX, y: collectionView.contentOffset.y), animated: animated)
    }
    
    /// 修正内容偏移，确保当前页有效
    /// 页数减少后集合视图可能仍停留在已不存在的页面，此时内容尺寸变小但偏移量超出有效范围，
    /// 会导致当前页空白且无法滚动回有效页面，因此需要将偏移量拉回最后一页
    /// - Parameter pageCount: 有效页数
    func adjustContentOffset(forPageCount pageCount: Int, animated: Bool) {
        guard itemSize.width > 0, pageCount > 0, let collectionView = collectionView else {
            return
        }
        
        let lastPage = pageCount - 1
        guard currentPage > lastPage else {
            return
        }
        
        /// 参照 scrollToPage 计算目标偏移，最终由滚动视图约束到有效范围内
        let targetOffsetX = CGFloat(lastPage) * pageWidth - itemSpacing
        collectionView.setContentOffset(CGPoint(x: targetOffsetX, y: collectionView.contentOffset.y), animated: animated)
    }
    
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
