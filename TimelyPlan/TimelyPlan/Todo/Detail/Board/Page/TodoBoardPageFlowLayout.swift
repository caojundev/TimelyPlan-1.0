//
//  TodoBoardPageFlowLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/1.
//

import Foundation

class TodoBoardPageFlowLayout: UICollectionViewFlowLayout {
    
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
        
        // 用于追踪是否已经处理过 header 和 footer
        var hasFooter = false
        
        // 处理已有的 attributes
        for (index, attr) in allAttributes.enumerated() {
            if attr.representedElementKind == UICollectionView.elementKindSectionFooter {
                hasFooter = true
                let footerAttr = attr.copy() as! UICollectionViewLayoutAttributes
                updateFooterPosition(footerAttr, offsetY: offsetY, visibleHeight: visibleHeight)
                allAttributes[index] = footerAttr
            }
        }
    
        // 补充缺失的 footer
        if !hasFooter {
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
