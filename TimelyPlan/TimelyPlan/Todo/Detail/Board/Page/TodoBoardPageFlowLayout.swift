//
//  TodoBoardPageFlowLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/1.
//

import Foundation

class TodoBoardPageFlowLayout: UICollectionViewFlowLayout {
    
    // 是否启用吸顶 header
    var stickyHeaderEnabled: Bool = true
    // 是否启用吸底 footer
    var stickyFooterEnabled: Bool = true
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }
        
        var allAttributes = super.layoutAttributesForElements(in: rect) ?? []
        
        let visibleHeight = collectionView.bounds.height
        let offsetY = collectionView.contentOffset.y
        let contentInset = collectionView.contentInset
        
        // 用于追踪是否已经处理过 header 和 footer
        var hasHeader = false
        var hasFooter = false
        
        // 处理已有的 attributes
        for (index, attr) in allAttributes.enumerated() {
            if attr.representedElementKind == UICollectionView.elementKindSectionHeader {
                hasHeader = true
                if stickyHeaderEnabled {
                    let headerAttr = attr.copy() as! UICollectionViewLayoutAttributes
                    updateHeaderPosition(headerAttr, offsetY: offsetY, contentInset: contentInset)
                    allAttributes[index] = headerAttr
                }
            } else if attr.representedElementKind == UICollectionView.elementKindSectionFooter {
                hasFooter = true
                if stickyFooterEnabled {
                    let footerAttr = attr.copy() as! UICollectionViewLayoutAttributes
                    updateFooterPosition(footerAttr, offsetY: offsetY, visibleHeight: visibleHeight)
                    allAttributes[index] = footerAttr
                }
            }
        }
        
        // 补充缺失的 header
        if stickyHeaderEnabled && !hasHeader {
            let numberOfSections = collectionView.numberOfSections
            for section in 0..<numberOfSections {
                let headerIndexPath = IndexPath(item: 0, section: section)
                if let headerAttr = super.layoutAttributesForSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    at: headerIndexPath
                ) {
                    let headerAttrCopy = headerAttr.copy() as! UICollectionViewLayoutAttributes
                    updateHeaderPosition(headerAttrCopy, offsetY: offsetY, contentInset: contentInset)
                    allAttributes.append(headerAttrCopy)
                }
            }
        }
        
        // 补充缺失的 footer
        if stickyFooterEnabled && !hasFooter {
            let numberOfSections = collectionView.numberOfSections
            for section in 0..<numberOfSections {
                let footerIndexPath = IndexPath(item: 0, section: section)
                if let footerAttr = super.layoutAttributesForSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    at: footerIndexPath
                ) {
                    let footerAttrCopy = footerAttr.copy() as! UICollectionViewLayoutAttributes
                    updateFooterPosition(footerAttrCopy, offsetY: offsetY, visibleHeight: visibleHeight)
                    allAttributes.append(footerAttrCopy)
                }
            }
        }
        
        return allAttributes
    }
    
    // MARK: - Header 吸顶逻辑
    private func updateHeaderPosition(_ headerAttr: UICollectionViewLayoutAttributes,
                                      offsetY: CGFloat,
                                      contentInset: UIEdgeInsets) {
        let headerHeight = headerAttr.frame.height
        let originalHeaderTop = headerAttr.frame.minY
        
        // 吸顶目标位置：contentInset.top 处
        let stickyHeaderTop = offsetY + contentInset.top
        
        // 当 header 原始顶部超出吸顶位置时，固定在顶部
        if originalHeaderTop < stickyHeaderTop {
            headerAttr.frame.origin.y = stickyHeaderTop
        }
        // 否则保持原始位置（跟随内容滚动）
        
        // 设置较高的 zIndex，确保 header 在其他元素上方
        headerAttr.zIndex = 1024
    }
    
    // MARK: - Footer 吸底逻辑
    private func updateFooterPosition(_ footerAttr: UICollectionViewLayoutAttributes,
                                      offsetY: CGFloat,
                                      visibleHeight: CGFloat) {
        let footerHeight = footerAttr.frame.height
        let originalFooterBottom = footerAttr.frame.maxY
        
        // 吸底目标位置：屏幕底部
        let stickyFooterBottom = offsetY + visibleHeight
        
        // 当 footer 原始底部超出屏幕底部时，固定在底部
        if originalFooterBottom > stickyFooterBottom {
            footerAttr.frame.origin.y = stickyFooterBottom - footerHeight
        }
        // 否则保持原始位置（跟随内容滚动）
        
        // 设置较高的 zIndex，确保 footer 在其他元素上方
        footerAttr.zIndex = 1024
    }
}

/*
class StickyFooterFlowLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }
        
        var allAttributes = super.layoutAttributesForElements(in: rect) ?? []
        
        let visibleHeight = collectionView.bounds.height
        let offsetY = collectionView.contentOffset.y
        
        // 检查 footer 是否已经在 allAttributes 中
        var hasFooter = false
        for attr in allAttributes {
            if attr.representedElementKind == UICollectionView.elementKindSectionFooter {
                hasFooter = true
                let footerAttr = attr.copy() as! UICollectionViewLayoutAttributes
                let footerHeight = footerAttr.frame.height
                let originalFooterBottom = footerAttr.frame.maxY
                let stickyFooterBottom = offsetY + visibleHeight
                
                if originalFooterBottom > stickyFooterBottom {
                    footerAttr.frame.origin.y = stickyFooterBottom - footerHeight
                }
                // 替换原来的
                if let index = allAttributes.firstIndex(of: attr) {
                    allAttributes[index] = footerAttr
                }
                break
            }
        }
        
        // 如果 footer 不在数组中（因为原始位置超出 rect），手动获取
        if !hasFooter {
            let footerIndexPath = IndexPath(item: 0, section: 0)
            if let footerAttr = super.layoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                at: footerIndexPath
            ) {
                let footerAttrCopy = footerAttr.copy() as! UICollectionViewLayoutAttributes
                let footerHeight = footerAttrCopy.frame.height
                let originalFooterBottom = footerAttrCopy.frame.maxY
                let stickyFooterBottom = offsetY + visibleHeight
                
                // 如果原始位置在屏幕下方，固定在底部并添加到数组中
                if originalFooterBottom > stickyFooterBottom {
                    footerAttrCopy.frame.origin.y = stickyFooterBottom - footerHeight
                }
                
                allAttributes.append(footerAttrCopy)
            }
        }
        
        return allAttributes
    }
}
*/
