//
//  WSPluginGalleryFlowLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/16.
//

import Foundation
import UIKit

/// 组件画廊布局。
///
/// 与仪表盘的网格布局不同，画廊在水平方向上「一页一个条目」：
/// - 页宽等于集合视图宽度，因此配合 `isPagingEnabled` 即可整页翻动；
/// - 条目尺寸由 `itemSizeProvider` 按组件尺寸（小 / 中 / 大）给出，并在其所在页内水平、垂直居中；
/// - 只负责条目的摆放，不提供区块头 / 脚视图属性。
///
/// 页宽与集合视图宽度一致，所以不要在集合视图上设置左右方向的 `contentInset`，
/// 否则内容偏移与页码的换算会与翻页栅格错位。
class WSPluginGalleryFlowLayout: UICollectionViewFlowLayout {
    
    /// 条目尺寸提供者。布局阶段按索引查询条目尺寸。
    var itemSizeProvider: ((IndexPath) -> CGSize)?
    
    /// 页数
    private(set) var pageCount: Int = 0
    
    /// 页宽。与集合视图宽度保持一致，用于整页翻动与页码换算。
    var pageWidth: CGFloat {
        return collectionView?.bounds.width ?? 0.0
    }
    
    /// 当前页码（从 0 开始），由内容偏移量换算而来
    var currentPage: Int {
        guard pageCount > 0, pageWidth > 0.0, let collectionView = collectionView else {
            return 0
        }
        
        let page = Int(round(collectionView.contentOffset.x / pageWidth))
        return min(max(page, 0), pageCount - 1)
    }
    
    /// 页内容区域高度。以滚动视图的额外内边距为界，保证条目在可见区域内垂直居中
    private var pageHeight: CGFloat {
        guard let collectionView = collectionView else {
            return 0.0
        }
        
        return max(0.0, collectionView.bounds.height - collectionView.adjustedContentInset.verticalLength)
    }
    
    /// 缓存的布局属性
    private var attributesList: [UICollectionViewLayoutAttributes] = []
    private var attributesMap: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    
    /// 内容尺寸
    private var contentSize: CGSize = .zero
    
    /// 上一次布局使用的集合视图尺寸。滚动只改变 bounds 的原点，尺寸变化才需要重新布局
    private var lastLayoutSize: CGSize = .zero
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    // MARK: - Layout
    override func prepare() {
        /// 保留父类的内部状态初始化，条目的摆放则完全由下面的分页规则决定
        super.prepare()
        scrollDirection = .horizontal
        minimumLineSpacing = 0.0
        minimumInteritemSpacing = 0.0
        sectionInset = .zero
        
        updateAttributes()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesMap[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        /// 滚动只改变 bounds 的原点，只有尺寸变化才重新布局
        return newBounds.size != lastLayoutSize
    }
    
    // MARK: - 翻页
    /// 滚动到指定页
    /// - Parameters:
    ///   - page: 目标页码（从 0 开始），超出范围时会收敛到有效页
    ///   - animated: 是否动画
    func scrollToPage(_ page: Int, animated: Bool) {
        guard let collectionView = collectionView, pageWidth > 0.0, pageCount > 0 else {
            return
        }
        
        let targetPage = min(max(page, 0), pageCount - 1)
        let targetOffset = CGPoint(x: CGFloat(targetPage) * pageWidth,
                                   y: collectionView.contentOffset.y)
        collectionView.setContentOffset(targetOffset, animated: animated)
    }
    
    // MARK: - 布局计算
    /// 逐条目生成分页布局属性
    private func updateAttributes() {
        attributesList.removeAll()
        attributesMap.removeAll()
        
        guard let collectionView = collectionView else {
            pageCount = 0
            contentSize = .zero
            lastLayoutSize = .zero
            return
        }
        
        lastLayoutSize = collectionView.bounds.size
        
        let pageWidth = collectionView.bounds.width
        let pageHeight = self.pageHeight
        guard pageWidth > 0.0, pageHeight > 0.0 else {
            pageCount = 0
            contentSize = .zero
            return
        }
        
        var pageIndex = 0
        for section in 0..<collectionView.numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: section)
                let attributes = makeAttributes(at: indexPath,
                                                pageIndex: pageIndex,
                                                pageSize: CGSize(width: pageWidth, height: pageHeight))
                attributesList.append(attributes)
                attributesMap[indexPath] = attributes
                pageIndex += 1
            }
        }
        
        pageCount = pageIndex
        contentSize = CGSize(width: CGFloat(pageIndex) * pageWidth, height: pageHeight)
    }
    
    /// 索引处条目的布局属性：独占一页并在页内居中
    private func makeAttributes(at indexPath: IndexPath,
                                pageIndex: Int,
                                pageSize: CGSize) -> UICollectionViewLayoutAttributes {
        let itemSize = size(at: indexPath, pageSize: pageSize)
        let pageMinX = CGFloat(pageIndex) * pageSize.width
        let frame = CGRect(x: pageMinX + (pageSize.width - itemSize.width) / 2.0,
                           y: (pageSize.height - itemSize.height) / 2.0,
                           width: itemSize.width,
                           height: itemSize.height)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = frame
        
        return attributes
    }
    
    /// 索引处条目的尺寸。未提供或超出页内容区域时收敛到可用范围内
    private func size(at indexPath: IndexPath, pageSize: CGSize) -> CGSize {
        var size = itemSizeProvider?(indexPath) ?? itemSize
        if size.width <= 0.0 || size.height <= 0.0 {
            size = itemSize
        }
        
        size.width = min(size.width, pageSize.width)
        size.height = min(size.height, pageSize.height)
        
        return size
    }
}
